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
import Crashlytics
import AWSUserPoolsSignIn
import ChameleonFramework


class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    fileprivate let trackingConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        return config
    }()
    
    
    let geolocationService = GeolocationService.instance
    var lastLocation: (Double, Double)?
    
    lazy var descriptorCache = DescriptorCache(geolocationService)

    // UI Elements
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let screenshotButton = UIButton()
    let createButton = CreateButton()
    let resetButton = UIButton()
    let userButton = UIButton()
    let indicatorButton = IndicatorButton()
    let longPressIndicator = LongPressIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    let userView = UserView()

    // For debugging
    var highlightedRectangleOutlineLayers = [CAShapeLayer]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUILayout()
        
        setupScreenshoButtonRx()

        setupResetButtonRx()
        
        setupCreateButtonRx()

        setupIndicatorButtonRx()
        
        setupUserButtonRx()
        
        setupPostRx() // Setup AR Post Discovery / Placement
        
        setuplongPress()
        
        setupPostNodeInteractions()
        
        handleWakeFromBackground()
    
//        AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.signOut()
        
        geolocationService.location.drive(onNext: { [weak self] (coordinates) in
            if self == nil { return }
            self!.lastLocation = coordinates
        })
        
    }
    
    func handleWakeFromBackground() {
        NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .subscribe(onNext: { [sceneView, disposeBag] _ in
                // Run the view's session
                sceneView.session.run(self.trackingConfiguration)
                sceneView.showsStatistics = true // For debugging
                
                // Reset tracking state when interruption ends
                let _ =
                sceneView.session.rx.sessionInterruptionEnded
                    .subscribe{ (_) in
                        self.resetSession()
                    }
                    .disposed(by: disposeBag)
                
                // Authenticate user
                AWSCognitoIdentityUserPool.default().currentUser()?.getDetails()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func resetSession() {
        // Remove exising plane anchors (and their children nodes) and reset session coordinate system
        self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
        // Refresh long press indicator animation
        self.longPressIndicator.refresh()
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
                self.resetSession()
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
                        
                        if image != nil {
                            self.createButton.animation = "zoomIn"
                            self.createButton.duration = 0.3
                            self.createButton.animate()
                        }
                    })
                    .disposed(by: self.disposeBag)
                
                
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

              self.createButton.clear()
            
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
    
    private func setupUserButtonRx() {
        // Show userview
        userButton.rx.tap
            .subscribe(onNext: { (_) in
                self.userView.alpha = 1
                UIView.animate(withDuration: 0.5) {
                    self.userView.transform = .identity
                    self.userView.countView.refresh()
                }
            })
            .disposed(by: disposeBag)
        
    }
}

extension ViewController {
    func setupPostRx() {
        
        /// 1. Slow down number of frames read and detect retangles
        let rectDetector = RectDetector()
        let _ =
            sceneView.session.rx.didUpdateFrame
                // slow down frame rate
                .throttle(0.05, scheduler:  MainScheduler.instance)
                .filter { _ in
                    return AWSCognitoUserPoolsSignInProvider.sharedInstance().isLoggedIn()
                } // quick fix.
                .subscribe(onNext: { (frame) in
                    self.removeRectOutlineLayers()
                    rectDetector.detectRectangle(in: frame)
                })
                .disposed(by: disposeBag)
        
        /// 2. Find rectangles attached to vertical surfaces in the real world
        let rectObservable = rectDetector.rectDriver
            .filter({ [sceneView] (observation)  in
                // check that rectangle is attached to a vertical plane
                let center = sceneView.convertFromCamera(observation.center)
                if !sceneView.isPointOnPlane(center) { return false }
                
                // check that point is not on a confirmed node
                // if point is on a confirmed node, eliminate unconfirmed nodes found by the same hit-test
                return !sceneView.isPointOnConfirmed(center, eliminateRest: true)
                
            })
            .filter({ [createButton, longPressIndicator, sceneView] (observation) in
                 // continue if one of two requirements are met
                if createButton.post == nil {
                    // a. if user is not posting
                    return true
                } else if longPressIndicator.isOnPlane {
                    // b. if user is posting and long pressing
                    let convertedRect = sceneView.convertFromCamera(observation.boundingBox)
                    return convertedRect.contains(longPressIndicator.center)
                }
                return false
            })
            .do(onNext: { (observation) in
                self.highlightObservation(observation)
            })
        
        /// 3. Compute geometric information and descriptor for each vertical rectangle observered previously
        let geometryObservable =
            rectObservable.asObservable()
                .debug("Get vertical rect info")
                .map({ (observation) -> RectInfo? in
                    var info = RectInfo(for: observation, in: self.sceneView) // Compute geometric information
                    if let _ = info {
                        info!.post = self.createButton.post
                    }
                    return info
                })
                .filter({ (info) -> Bool in
                    guard let geometry = info?.geometry else { return false }
                    // check if info is just an update
                    for child in info!.anchorNode.childNodes as! [PostNodeNew] {
                        if geometry.isVariation(of: child.geometryUpdater.currGeometry) {
                            // update geometry and stop creating new post node
                            child.updateGeometry(geometry)
                            return false
                        }
                    }
                    return true
                })
                .debug("Compute descriptor")
        
        /// 4. Compute and match descriptor
        let descriptorComputer = DescriptorComputer()
        let infoObservable =
            geometryObservable
                .flatMap { descriptorComputer.compute(info: $0!) } // Compute descriptor
                .filter { $0 != nil }
                .map { [weak self](info) -> RectInfo? in
                    if self == nil { return nil }
                    var info = info!
                    let match = self!.descriptorCache.findMatch(info.descriptor!)
                    if match != nil {
                        info.key.status = .used
                        info.key.identifier = match!
                    } else if self!.createButton.post != nil {
                        info.key.status = .new
                        guard let key = self!.getKey() else { return nil }
                        info.key.identifier = key
                    } else {
                        info.key.status = .inactive
                    }
                    return info
                }
                .filter { $0 != nil }
        


        /// 5. Generate PostNode
        let _ =
            infoObservable
                .observeOn(MainScheduler.instance) // Return to main queue
                .subscribe(onNext: { (info) in
                    PostNodeNew(info!)
                })
                .disposed(by: disposeBag)
        
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
    
    // Sign out current user
    func signOut() {

        AWSCognitoIdentityUserPool.default().currentUser()?.signOut()
        AWSCognitoIdentityUserPool.default().currentUser()?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                var response = task.result
            })
            return nil
        }
    }
    
    func getKey() -> String? {
        guard let location = lastLocation else { return nil }
        let locationString = location.0.format(f: "0.4") + "/" + location.1.format(f: "0.4")
        let date = recordDate()
        let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!
        let key = locationString + "/" + date + "/" + username
        
        return key
    }
    
    func recordDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.string(from: Date())
    }


}

