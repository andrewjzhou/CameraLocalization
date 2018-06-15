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
    fileprivate let disposeBag = DisposeBag()
    fileprivate let trackingConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        return config
    }()

    // UI Elements
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let screenshotButton = UIButton()
    let createButton = CreateButton()
    let resetButton = UIButton()
    let userButton = UIButton()
    let indicatorButton = IndicatorButton()
   
    
    // Location
    let geolocationService = GeolocationService.instance
    
    // Poster Rx
    
    private let longPressSubject = BehaviorSubject<UILongPressGestureRecognizer>(value: UILongPressGestureRecognizer())

    private var highlightedRectangleOutlineLayers = [CAShapeLayer]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup buttons design on the main screen
        setupUILayout()
        
        // Setup Button Rx functions
        setupScreenshoButtonRx()
        setupResetButtonRx()
        setupCreateButtonRx()
        
        // Setup Location
//        setupLocationServiceAndDescriptorCache()
        
        // Setup AR Poster Discovery and Placement Rx
//        setupARPosetrDiscoveryAndPlacementRx()
        setupPostRx()
        
        // Setup gesture
        setuplongPressSubject()
        setupPostNodeInteractions()
        
        // SignIn View Controllers
        // Customie UI by following: https://docs.aws.amazon.com/aws-mobile/latest/developerguide/add-aws-mobile-user-sign-in-customize.html
        // Get rid of email field in sign-up
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: nil,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                        }
                })
        }
        
        test()
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
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    /**
        Hide ViewDidLoad UIButtons
     */
    private func hideUIButtons() {
        screenshotButton.alpha = 0
        createButton.alpha = 0
        resetButton.alpha = 0
        userButton.alpha = 0
        indicatorButton.alpha = 0
    }
}

/**
 MARK:- Rx for ViewDidLoad Buttons
 */
extension ViewController {
    /**
     React to screenshotButton tap gesture - Take a screenshot
     */
    private func setupScreenshoButtonRx() {
        screenshotButton.rx.tap
            .bind {
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            }
            .disposed(by: disposeBag)
    }
    
    /**
     React to resetButton tap gesture - Reset ARScnView
     */
    private func setupResetButtonRx() {
        resetButton.rx.tap
            .bind {
                self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
            }
            .disposed(by: disposeBag)
        
    }
    
    /**
     React to createButton tap gesture
     */
    private func setupCreateButtonRx() {
        let createButtonTapObservable = createButton.rx.tap.share()
        
        // Activate CreationView and isPosting
        createButtonTapObservable
            .filter({ _ -> Bool in
                return self.createButton.post == nil
            })
            .subscribe(onNext: {_ in
                // Create new CreationView
                let creationView = CreationView()
                self.view.addSubview(creationView) // sets layout inside didMoveToSuperview()
                
                /**
                 Handle exit of creationView - React to createView exitSubject
                 */
                creationView.exitSubject
                    .asDriver(onErrorJustReturn: nil)
                    .drive(onNext: { (image) in
                        self.createButton.post = image
                        // Set createButton image depending on
                        if image == nil { // Either cancelButton was tapped or finishButton failed
                            creationView.removeFromSuperview()
                        } else {
                            creationView.removeFromSuperview()
                        }
                        
                        // Remove creationView
                        UIView.animate(withDuration: 0.3, animations: {
                            self.screenshotButton.alpha = 1
                            self.createButton.alpha = 1
                            self.resetButton.alpha = 1
                            self.userButton.alpha = 1
                            self.indicatorButton.alpha = 1
                        })
                    })
                    .disposed(by: self.disposeBag)
                
                
                // Hide ViewDidLoad UIButtons
                UIView.animate(withDuration: 0.3, animations: {
                    self.hideUIButtons()
                })
            })
            .disposed(by: disposeBag)
        
        // Deactivate CreationView
        createButtonTapObservable
            .filter({ _ -> Bool in
                return self.createButton.post != nil
            })
            .subscribe(onNext: {_ in
                self.createButton.post = nil // default image
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    func setupPostRx() {
        let arFrameObservable =
            sceneView.session.rx.didUpdateFrame
                // slow down frame rate
                .throttle(0.1, scheduler:  MainScheduler.instance)
        
        let verticalRectObservable =
            arFrameObservable
                .flatMap{ detectVerticalRect(frame: $0, in: self.sceneView) }
                .debug("Detect vertical rect")
                .withLatestFrom(longPressSubject) { (observation, sender) -> VNRectangleObservation? in
                    // Continue PostNode creation/discovery process only if either of the two requirements are met

                    if self.createButton.post == nil { // 1. if user is not posting
                        return observation
                    } else if sender.state.isActive { // 2. if user is posting and long pressing
                        let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
                        let currTouchLocation = sender.location(in: self.sceneView)
                        if convertedRect.contains(currTouchLocation) {
                            return observation
                        }
                    }
                    
                    return nil
                }
                .debug("After posting check")
                .filter{ $0 != nil }
        
        
       
        let verticalRectInfoObservable =
            verticalRectObservable
                .map({ (observation) -> VerticalRectInfo? in
                    var info = VerticalRectInfo(for: observation!, in: self.sceneView)
                    info?.post = self.createButton.post
                    return info
                })
                .filter { $0 != nil }
        
        
        
        
        let descriptorComputer = DescriptorComputer()
        let infoDescriptorPairObservable =
            verticalRectInfoObservable
                .flatMap { descriptorComputer.compute(info: $0!) }
                .filter { $0 != nil }
        

        
        let descriptorCache = DescriptorCache(geolocationService) // Check if this cache actually caches
        let postNodeObservable =
            infoDescriptorPairObservable
                .map { PostNode(info: $0!, cache: descriptorCache) }
                .subscribe(onNext: { (postNode) in
                    print("PostNode created: ", postNode)
                })

    
    }

}




// Highlighting Rectangle Observations
extension ViewController {
    /**
     Outline selected rectangle observation.
     */
    fileprivate func highlightObservation(_ observation: VNRectangleObservation) {
        let points = [observation.topLeft, observation.topRight, observation.bottomRight, observation.bottomLeft]
        let convertedPoints = points.map { self.sceneView.convertFromCamera($0) }
        let layer = drawPolygon(convertedPoints, color: .red)
        self.highlightedRectangleOutlineLayers.append(layer)
        self.sceneView.layer.addSublayer(layer)
    }
    
    /**
     Draw outline given set of points and color.
     */
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
    
    /**
     Remove outlines drawn for selected rectangles.
     */
    fileprivate func removeRectOutlineLayers() {
        // Remove outline for observed rectangles
        for layer in self.highlightedRectangleOutlineLayers {
            layer.removeFromSuperlayer()
        }
        self.highlightedRectangleOutlineLayers.removeAll()
    }
    
    func test() {
      
        
    }

    private func setuplongPressSubject() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(observeLongPress(sender:)))
        view.addGestureRecognizer(longPress)
    }
    @objc private func observeLongPress(sender: UILongPressGestureRecognizer) {
                longPressSubject.onNext(sender)
        
    }
    
    private func setupPostNodeInteractions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tap)
    }
    
     @objc func handleTap (sender: UILongPressGestureRecognizer) {
        // Perform hit-test at tapped location
        let point = sender.location(in: sceneView)
        let scnHitTestResults = sceneView.hitTest(point, options: nil)
        guard let postNode = scnHitTestResults.first?.node.parent as? PostNode else {return}
        
        if postNode.state == .prompt && createButton.post != nil {
            postNode.setContent(createButton.post!)
            createButton.sendActions(for: .touchUpInside)
            postNode.record() // Upload to S3
        } else if postNode.state == .prompt && createButton.post == nil {
            postNode.removeFromParentNode()
        } 
    }
    
}
