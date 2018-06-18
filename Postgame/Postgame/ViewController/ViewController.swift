//
//  ViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/17/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import SceneKit
import ARKit
import Vision
import RxSwift
import RxCocoa
import CoreLocation
import AWSMobileClient
import AWSAuthCore
import AWSAuthUI

class ViewController: UIViewController {
    
    fileprivate let trackingConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        return config
    }()
    
    let geolocationService = GeolocationService.instance
    
    lazy var descriptorCache = DescriptorCache(geolocationService)
    
    let longPressSubject = BehaviorSubject<UILongPressGestureRecognizer>(value: UILongPressGestureRecognizer())

    // UI Elements
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let screenshotButton = UIButton()
    let createButton = CreateButton()
    let resetButton = UIButton()
    let userButton = UIButton()
    let indicatorButton = IndicatorButton()
    let longPressIndicator = LongPressIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    // For debugging
    var highlightedRectangleOutlineLayers = [CAShapeLayer]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUILayout()
        
        setupScreenshoButtonRx()

        setupResetButtonRx()
        
        setupCreateButtonRx()

        setupIndicatorButtonRx()
        
        setupPostRx() // Setup AR Post Discovery / Placement
        
        setuplongPressSubject()
        
        setupPostNodeInteractions()

        // SignIn View Controllers
        // Customie UI by following: https://docs.aws.amazon.com/aws-mobile/latest/developerguide/add-aws-mobile-user-sign-in-customize.html
        // Get rid of email field in sign-up
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            showSignIn()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run(trackingConfiguration)
        sceneView.showsStatistics = true // For debugging
        
        // Reset tracking state when interruption ends
        let _ =
        sceneView.session.rx.sessionInterruptionEnded
            .subscribe{ (_) in
                self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
            }
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}


/// MARK: ViewDidLoad Buttons Interaction Setup
extension ViewController {

    private func setupScreenshoButtonRx() {
        screenshotButton.rx.tap
            .bind {
                // Take screenshot and save to photo album
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupResetButtonRx() {
        resetButton.rx.tap
            .bind {
                // Remove exising plane anchors (and their children nodes) and reset session coordinate system
                self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setupCreateButtonRx() {
        let createButtonTapObservable = createButton.rx.tap.share()
        
        // Activate CreationView and setup reaction to creationView exit
        createButtonTapObservable
            .filter({ _ -> Bool in
                return self.createButton.post == nil
            })
            .subscribe(onNext: {_ in
                // Create new CreationView
                let creationView = CreationView()
                self.view.addSubview(creationView) // sets layout inside didMoveToSuperview()
                
                
                // Handle exit of creationView - React to createView exitSubject, which returns nil (cancelled) or uiimage (finnished)
                creationView.exitSubject
                    .asDriver(onErrorJustReturn: nil)
                    .drive(onNext: { (image) in
                        self.createButton.post = image
                    
                        // Remove creationView
                        creationView.removeFromSuperview()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.screenshotButton.alpha = 1
                            self.createButton.alpha = 1
                            self.resetButton.alpha = 1
                            self.userButton.alpha = 1
                            self.indicatorButton.alpha = 1
                        })
                    })
                    .disposed(by: disposeBag)
                
                
                // Hide main UIButtons
                UIView.animate(withDuration: 0.3, animations: {
                    // Hide UI Buttons
                    self.screenshotButton.alpha = 0
                    self.createButton.alpha = 0
                    self.resetButton.alpha = 0
                    self.userButton.alpha = 0
                    self.indicatorButton.alpha = 0
                })
            })
            .disposed(by: disposeBag)
        
        // Deactivate posting interactions by setting createButton.post to nil
        createButtonTapObservable
            .filter({ _ -> Bool in
                return self.createButton.post != nil
            })
            .subscribe(onNext: {_ in
                self.createButton.post = nil // default image
            })
            .disposed(by: disposeBag)
    }
    
    private func setupIndicatorButtonRx() {
        // Count number of descriptors cached
        descriptorCache.counter
            .drive(onNext: { (count) in
                self.indicatorButton.setLabel(count)
            })
            .disposed(by: disposeBag)
        
        // Refresh descriptor cache
        indicatorButton.rx.tap.subscribe(onNext: { _ in
            self.descriptorCache.refresh()
        }).disposed(by: disposeBag)
        
    }
}

extension ViewController {
    func setupPostRx() {
        
        // 1. Slow down number of frames read
        let arFrameObservable =
            sceneView.session.rx.didUpdateFrame
                // slow down frame rate
                .throttle(0.1, scheduler:  MainScheduler.instance)
        
        // 2. Detect rectangles attached to vertical surfaces in the real world
        let verticalRectObservable =
            arFrameObservable
                .flatMap{ detectVerticalRect(frame: $0, in: self.sceneView) }
                .withLatestFrom(longPressSubject) { (observation, sender) -> VNRectangleObservation? in
                    // Continue PostNode creation/discovery process only if either of the two requirements are met
                    if self.createButton.post == nil { // a. if user is not posting
                        return observation
                    } else if sender.state.isActive { // b. if user is posting and long pressing
                        let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
                        let currTouchLocation = sender.location(in: self.sceneView)
                        if convertedRect.contains(currTouchLocation) { // user select observation through long press
                            return observation
                        }
                    }
                    
                    return nil
                }
                .filter{ $0 != nil }
        
        // 3. Compute geometric information and descriptor for each vertical rectangle observered previously
        let descriptorComputer = DescriptorComputer()
        let infoObservable =
            verticalRectObservable
                .map({ (observation) -> VerticalRectInfo? in
                    let info = VerticalRectInfo(for: observation!, in: self.sceneView) // Compute geometric information
                    info?.post = self.createButton.post
                    return info
                })
                .filter { $0 != nil }
                .flatMap { descriptorComputer.compute(info: $0!) } // Compute descriptor
                .filter { $0 != nil }

        // 4. Generate PostNode
        let _ =
            infoObservable
                .map { PostNode(info: $0!, cache: self.descriptorCache) }
                .subscribe(onNext: { (postNode) in
                    print("PostNode created: ", postNode)
                })
        
    }
}


// Highlighting Rectangle Observations for debugging
extension ViewController {
    
    // Outline selected rectangle observation.
    fileprivate func highlightObservation(_ observation: VNRectangleObservation) {
        let points = [observation.topLeft, observation.topRight, observation.bottomRight, observation.bottomLeft]
        let convertedPoints = points.map { self.sceneView.convertFromCamera($0) }
        let layer = drawPolygon(convertedPoints, color: .red)
        self.highlightedRectangleOutlineLayers.append(layer)
        self.sceneView.layer.addSublayer(layer)
    }
    

    // Draw outline given set of points and color.
    fileprivate func drawPolygon(_ points: [CGPoint], color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = 5
        let path = UIBezierPath()
        path.move(to: points.last!)
        points.forEach { point in
            path.addLine(to: point)
        }
        layer.path = path.cgPath
        return layer
    }
    
    // Remove outlines drawn for selected rectangles.
    fileprivate func removeRectOutlineLayers() {
        // Remove outline for observed rectangles
        for layer in self.highlightedRectangleOutlineLayers {
            layer.removeFromSuperlayer()
        }
        self.highlightedRectangleOutlineLayers.removeAll()
    }

}


extension ViewController {
    // Show sign-in view controller
    func showSignIn() {
        // Customize Sign-In UI
        let config = AWSAuthUIConfiguration()
//        config.enableUserPoolsUI = true
//        config.backgroundColor = UIColor.blue
//        config.font = UIFont (name: "Helvetica Neue", size: 20)
//        config.isBackgroundColorFullScreen = true
//        config.canCancel = true

        
        AWSAuthUIViewController
            .presentViewController(with: self.navigationController!,
                                   configuration: config,
                                   completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                    if error != nil {
                                        print("Error occurred: \(String(describing: error))")
                                    } else {
                                        // Sign in successful.
                                    }
            })
    }
    
    // Sign out current user
    func signOut() {
        AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
            self.showSignIn()
        })
    }
}

fileprivate let disposeBag = DisposeBag()
