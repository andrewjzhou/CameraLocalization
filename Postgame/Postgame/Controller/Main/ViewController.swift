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
    
    let trackingConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        return config
    }()
    
    
    let geolocationService = GeolocationService.instance
    var lastLocation: CLLocation?
    
    lazy var descriptorCache = DescriptorCache()

    // UI Elements
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let screenshotButton = UIButton()
    let createButton = CreateButton()
    let resetButton = UIButton()
    let userButton = UserButton()
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
        
        setupUserButtonRx()
        
        setupPostRx() // Setup AR Post Discovery / Placement
        
        setuplongPress()
        
        setupPostNodeInteractions()
        
        handleWakeFromBackground()
        
        handleGeolocationService()
        
//        signOut()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.post(Notification(name: NSNotification.Name.UIApplicationDidBecomeActive))
            
    }
    
    func handleGeolocationService() {
        geolocationService.location.drive(onNext: { [weak self] (location) in
            if self == nil { return }
            self?.lastLocation = location
            self?.descriptorCache.query(location)
        }).disposed(by: disposeBag)
    }
    
    func handleWakeFromBackground() {
        NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                // Authenticate user
                AWSCognitoIdentityUserPool.default().currentUser()?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
                    let user = AWSCognitoIdentityUserPool.default().currentUser()
                    user?.getSession().continueWith(block: { (task) -> Any? in
                        let getSessionResult = task.result
                        if let tokenString = getSessionResult?.idToken?.tokenString {
                            AppSyncService.sharedInstance.keychain.set(tokenString, forKey: CognitoAuthTokenStringKey)
                        }
                        return nil
                    })
                    return nil
                })
        
                guard let currUser = AWSCognitoIdentityUserPool.default().currentUser() else {return}
                if currUser.isSignedIn {
                    // Run the view's session
                    self?.resetSession()
                    self?.sceneView.showsStatistics = true // For debugging
                    self?.descriptorCache.refresh()
                    
                    // First check AV Authoirzation then check Location Authorization
                    guard let avAuth = self?.checkAVAuthoirzied() else { return }
                    if avAuth {
                        self?.checkLocationAuthorizationStatus()
                    }
                }
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
            .throttle(0.1, scheduler: MainScheduler.instance)
            .bind {
                // Take screenshot and save to photo album
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupResetButtonRx() {
        resetButton.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { self.resetSession() }
            .disposed(by: disposeBag)
    }
    
    private func setupCreateButtonRx() {
        let createButtonTapObservable = createButton.rx.tap.share()
        
        // Activate CreationView and setup reaction to creationView exit
        createButtonTapObservable
            .filter({ _ -> Bool in
                return self.createButton.post == nil
            })
            .subscribe(onNext: {[weak self, disposeBag] _ in
                let creationVC = CreationViewController()
                creationVC.modalPresentationStyle = .overCurrentContext
                creationVC.modalTransitionStyle = .crossDissolve
                self?.present(creationVC, animated: true, completion: nil)
            
                
                // Handle exit of creationView - React to createView exitSubject, which returns nil (cancelled) or uiimage (finnished)
                creationVC.exitSubject
                    .asDriver(onErrorJustReturn: nil)
                    .drive(onNext: { (image) in
                        self?.createButton.post = image
                        
                        creationVC.dismiss(animated: true, completion: {
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.1, animations: {
                                    self?.screenshotButton.alpha = 1
                                    self?.createButton.alpha = 1
                                    self?.resetButton.alpha = 1
                                    self?.userButton.alpha = 1
                                    self?.indicatorButton.alpha = 1
                                })
                            }
                            
                            if image != nil {
                                self?.createButton.animation = "zoomIn"
                                self?.createButton.duration = 0.1
                                self?.createButton.animate()
                                
                                self?.descriptorCache.refresh()
                            }
                        })
                    })
                    .disposed(by: disposeBag)
                
                
                // Hide main UIButtons
                UIView.animate(withDuration: 0.3, animations: {
                    // Hide UI Buttons
                    self?.screenshotButton.alpha = 0
                    self?.createButton.alpha = 0
                    self?.resetButton.alpha = 0
                    self?.userButton.alpha = 0
                    self?.indicatorButton.alpha = 0
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
        // Open Map
        indicatorButton.rx.tap.bind {
            self.checkLocationAuthorizationStatus()
            self.descriptorCache.refresh()
            let mapVC = MapViewController()
            mapVC.modalPresentationStyle = .overCurrentContext
            mapVC.modalTransitionStyle = .crossDissolve
            self.present(mapVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
    }
    
    private func setupUserButtonRx() {
        // Show userview
        userButton.rx.tap
            .subscribe(onNext: { (_) in
                let userVC = UserViewController()
                userVC.modalPresentationStyle = .overCurrentContext
                userVC.modalTransitionStyle = .crossDissolve
                self.present(userVC, animated: true, completion: nil)
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
                .throttle(0.05, scheduler:  MainScheduler.asyncInstance)
                .do(onNext: { [userButton, sceneView] (frame) in
                    let fpCount = frame.rawFeaturePoints?.points.count ?? 0
                    if fpCount > 100 { userButton.publishPerceptionStatus(.highFP) }
                    else { userButton.publishPerceptionStatus(.lowFP) }
                    
                    let center = sceneView.center
                    let top = CGPoint(x: center.x,
                                      y: center.y + sceneView.frame.size.height * 0.3)
                    let bottom = CGPoint(x: center.x,
                                         y: center.y - sceneView.frame.size.height * 0.3)
                    if sceneView.arePointsOnConfirmed([center, top, bottom], eliminateRest: true) {
                        userButton.publishPerceptionStatus(.node)
                    } else if sceneView.arePointsOnPlane([center, top, bottom]) {
                        userButton.publishPerceptionStatus(.plane)
                    }
                })
                .filter { _ in
                    return AWSCognitoUserPoolsSignInProvider.sharedInstance().isLoggedIn()
                } // quick fix.
                .subscribe(onNext: { (frame) in
//                    self.removeRectOutlineLayers()
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
            .do(onNext: { [userButton] (observation) in
//                self.highlightObservation(observation)
                userButton.publishPerceptionStatus(.rect)
            })
        
        /// 3. Compute geometric information and descriptor for each vertical rectangle observered previously
        let geometryObservable =
            rectObservable.asObservable()
                .map({ [createButton, sceneView] (observation) -> RectInfo? in
                    var info = RectInfo(for: observation, in: sceneView) // Compute geometric information
                    if let _ = info {
                        info!.post = createButton.post
                    }
                    return info
                })
                .filter({ (info) -> Bool in
                    guard let geometry = info?.geometry else { return false }
                    // check if info is just an update
                    for child in info!.anchorNode.childNodes as! [PostNode] {
                        if geometry.isVariation(of: child.geometryUpdater.currGeometry) {
                            // update geometry and stop creating new post node
                            child.updateGeometry(geometry)
                            // append new image
                            child.recorder.realImages.append(info!.realImage)
                            return false
                        }
                    }
                    return true
                })
        
        /// 4. Generate Post Node
        let nodeObservable =
            geometryObservable.observeOn(MainScheduler.instance)
                .flatMap{ PostNode($0!).confirmObservable }
                .filter{ $0 != nil }
        
        /// 5. Render
        let descriptorComputer = DescriptorComputer()
        let _ =
        nodeObservable
            .flatMap { descriptorComputer.computeDescriptors(node: $0!, count: 4) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (node) in
                if self == nil { return }
                let match = self!.descriptorCache.findMatch(node)
                if match != nil { // Post already exists
                    // deactivate in future if user updates image
                    node.recorder.idToDeactivate = match!.id
                    
                    // display image
                    if let image = ImageCache.shared[match!.parentPostInfo.s3Key] {
                        node.setContent(image)
                    } else {
                        node.downloadAndSetContent(match!.parentPostInfo.s3Key)
                    
                        // increment viewCount
                        AppSyncService.sharedInstance.incrementViewCount(id: match!.id)
                    }
                    
                    DispatchQueue.main.async{ vibrate(.light) }
                } else if self!.createButton.post != nil { // Post to be added
                    node.prompt()
                } else { // Placeholder
                    node.deactivate()
                }
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

    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            geolocationService.locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            break
        case .denied, .restricted:
            let alertController = UIAlertController(title: "Location Service",
                                                    message: "Monocle needs you to authoirze location services to work!",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            geolocationService.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkAVAuthoirzied() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) != AVAuthorizationStatus.authorized {
            AVCaptureDevice.requestAccess(for: .video) { (authorized) in
                if !authorized {
                    let alertController = UIAlertController(title: "Camera",
                                                            message: "Monocle needs you to authoirze camera to work!",
                                                            preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            return false
        } else {
            return true
        }
        
    }
}

