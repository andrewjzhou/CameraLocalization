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
    let createButton = UIButton()
    let resetButton = UIButton()
    let userButton = UIButton()
    let indicatorButton = IndicatorButton()
    
    // Variables for posting
    private var currImageToPost: UIImage?
    private var isPostingSubject = BehaviorSubject<Bool>(value: false)
    
    // Location
    private var location: CLLocationCoordinate2D?
    
    // Poster Rx
    private let frameSubject = PublishSubject<ARFrame>()
    private let longPressSubject = BehaviorSubject<UILongPressGestureRecognizer?>(value: nil)
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Run the view's session
        sceneView.session.run(trackingConfiguration)
        
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
            .withLatestFrom(isPostingSubject)
            .filter { $0 == false }
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
                        // Set createButton image depending on
                        if image == nil { // Either cancelButton was tapped or finishButton failed
                            self.createButton.setImage(UIImage(named: "ic_add"), for: .normal) // default image
                            creationView.removeFromSuperview()
                        } else {
                            self.createButton.setImage(image!, for: .normal)
                            creationView.removeFromSuperview()
                            self.isPostingSubject.onNext(true)
                        }
                        
                        // Set currImageToPost
                        self.currImageToPost = image
                        
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
        
        // Deactivate CreationView and isPosing
        createButtonTapObservable
            .withLatestFrom(isPostingSubject)
            .filter { $0 == true }
            .subscribe(onNext: {_ in
                self.createButton.setImage(UIImage(named: "ic_add"), for: .normal) // default image
                self.isPostingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}


/**
 MARK:- Location Service.
 */
extension ViewController {
    // Note on GPS coordinates:
    // The third decimal place of coordinate is worth up to 110 m: it can identify a large agricultural field or institutional campus.
    // The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It is comparable to the typical accuracy of an uncorrected GPS unit with no interference.
    // The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. Accuracy to this level with commercial GPS units can only be achieved with differential correction.
    
    /**
     React to GeolocationService Updates
     */
    private func setupLocationServiceAndDescriptorCache() {
        // FOR TESTING: Change prefix in urlList() and change return value in first map function
        
        let geolocationService = GeolocationService.instance
        
        // Get the current user coordinate
        let userLocation = geolocationService.location
//            .debug("Descriptor Cache: Before map1")
            .map{ // test -> (Double, Double) in
                // Convert CLLocation coordinates to 4 decimal places
                (self.roundToDecimal4($0.latitude as Double), self.roundToDecimal4($0.longitude as Double))
            }
//            .debug("Descriptor Cache: After map1")
            .distinctUntilChanged({ (location1, location2) -> Bool in
                // Only send request if output changed
                let precision = 0.0002
                if abs(location1.0 - location2.0) < precision && abs(location1.1 - location2.1) < precision {
                    return true
                } else {
                    return false
                }
            })
//            .do(onNext: { (location) in
//                // Refresh cache. Remove descriptors that are not inside user region
//                for key in self.descriptorCache.keys {
//                    if !self.keyCloseToLocation(key: key, location: location) {
//                        self.descriptorCache.removeValue(forKey: key)
//                    }
//                }
//            })
//            .debug("After distinct until changed")
//            .asObservable()
    
        
        // Cache descritpors based on user location
        // Switch out S3 function with mobilehub version
//        userLocation
//            .map { coordinate in
//                // Get surrounding coordinates
//                return self.surroundingCoordinates(for: coordinate)
//            }
//            .debug("Descriptor Cache: After map2")
//            .flatMap { locations in
//                // Get list or URLs asscossiated with coordinates
//                return self.s3.urlList(for: locations)
//            }
//            .debug("Descriptor Cache: After flat-map")
//            .flatMap({ (url) in
//                // Download descriptors
//                return self.s3.downloadDescriptor(url)
//            })
//            .subscribe(onNext: { (descriptor) in
//                // Cache descriptors
//                self.descriptorCache.updateValue(descriptor.value, forKey: descriptor.key)
//            }, onError: { (error) in
//                print("Descriptor Cache Error: ", error)
//            })
//            .disposed(by: disposeBag)
    }
    
    /**
     Round double to 4 decimal digits
     */
    fileprivate func roundToDecimal4(_ value: Double) -> Double{
        return Double(round(10000*value)/10000)
    }
    
    /**
     Get coordinates surrounding estimated coordinate
     */
    fileprivate func surroundingCoordinates(for coordinate: (Double, Double)) -> [(Double, Double)]{
        var coordinates = [(Double, Double)]()
        let lattitude = coordinate.0,
            longitude = coordinate.1
    
        // +/- 0.0002
        let lats = [lattitude-0.0002, lattitude-0.0001, lattitude, lattitude+0.0001, lattitude+0.0002]
        let longs = [longitude-0.0002, longitude-0.0001, longitude, longitude+0.0001, longitude+0.0002]
        
        for lat in lats {
            for long in longs {
                coordinates.append((lat, long))
            }
        }
       
        return coordinates
    }
    
    /**
     Check if descriptor is in the approximate region that the user is in by checking descriptor key.
     */
    fileprivate func keyCloseToLocation(key: String, location: (Double, Double)) -> Bool {
        let keyArr = key.split(separator: "/")
        guard let lat = Double(keyArr[0]),
            let long = Double(keyArr[1]) else {
                print("keyCloseToLocation: Conversion Error")
                return false
        }
    
        let precision = 0.0003
        return (abs(lat - location.0) < precision) && (abs(long - location.1) < precision)
    }
}

extension ViewController {
    func setupPostRx() {
        let arFrameObservable = sceneView.session.rx.didUpdateFrame
        let verticalRectsObservable = VerticalRectsObservable.create(arFrameObservable,
                                                                     in: sceneView)
        verticalRectsObservable
            .subscribe(onNext: { (observations) in
                self.removeRectOutlineLayers()
                // Highlight detected rectangles
                for observation in observations {
                    self.highlightObservation(observation)
                }
               
            }).disposed(by: disposeBag)

    }
    
    
    
  

}



/**
 MARK:- Setup Poster Rx, main per-frame opertaions.
 */

//extension ViewController {
//    /**
//     Setup Poster Rx, main per-frame opertaions.
//     */
//    private func setupARPosetrDiscoveryAndPlacementRx() {
//        // Start observing long press gesture on view
//        setupLongPressSubject()
//
//
//        // Observe Detected Rectangles per ARFrame. Slow down frame rate. Remove drawn outlines for selected rectangles, if any exist
//        let rectObservable =
//            frameSubject.asObservable()
////                .debug("Poster: Before Throttle")
//                .throttle(0.1, scheduler:  MainScheduler.instance) // slow down requests
////                .debug("Poster: After Throttle")
//                .do(onNext: { (_) in
//                    self.removeRectOutlineLayers() // clean up drawings, if there is any
//                })
//                .flatMap { self.detectRectangles(in: $0) }
//                .share()
//
//
//        // Stream 1: Not Posting + Long Press began/changed + rects
//        let stream1 = rectObservable
//            .withLatestFrom(isPostingSubject.asObservable()) { (observations, bool) -> [VNRectangleObservation]? in
//                if bool == false { return observations }
//                else { return nil }
//            }
////            .debug("After Post")
//            .filter{ $0 != nil }
//            .withLatestFrom(longPressSubject.asObservable()) { (observations, sender) -> VNRectangleObservation? in
//                if sender == nil { return nil }
//                else if sender!.state == .began || sender!.state == .ended {
//                    return self.selectRectangle(observations: observations, sender: sender)
//                }
//                else { return nil }
//            }
////            .debug("After selction")
//            .filter{ $0 != nil }
//
//        stream1.asDriver(onErrorJustReturn: nil)
//            .drive(onNext: { (observation) in
//                self.highlightObservation(observation!)
//            })
//            .disposed(by: disposeBag)
//
////        let stream1 = isPostingSubject.asObservable()
////            .debug("Is Posting")
////            .filter { $0 == false }
////            .withLatestFrom(longPressSubject.asObservable())
////            .debug("Long Press")
////            .filter { (sender) -> Bool in
////                // Sender state is began or changed
////                if sender == nil {
////                    return false
////                } else if sender!.state == .began || sender!.state == .changed {
////                    return true
////                } else {
////                    return false
////                }
////            }
////            .debug("Debug: Before")
////            .withLatestFrom(rectObservable) { (sender, observations) -> VNRectangleObservation? in
////                if (observations == nil) { return nil }
////                // Select rectangle observation that contains current touch location, return nil if no selected rectangle available
////                let currTouchLocation = sender!.location(in: self.sceneView)
////                for observation in observations! {
////                    let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
////                    if convertedRect.contains(currTouchLocation) {
////                        return observation
////                    }
////                }
////                return nil
////            }
////            .debug("Debug: After")
////            .filter{ $0 != nil }
////
////        stream1
////            .subscribe(onNext: { (observation) in
////                // Outline selected observation
////                if let _ = observation {
////                    self.highlightObservation(observation!)
////                }
////            })
//
//
//
//
//
//
////        // 2) Pre-conditions (isPositing/LongPressGesture)
////        // Observe dectected rectangle observations for each frame, when isPosting == false
////        let notPostingRectObservable = frameObservable
////            .filter { _ -> Bool in
////                if !self.isPosting {
////                    return true
////                } else {
////                    return false
////                }
////            }
////            .debug("Poster: After Not Posting Filter")
////            .flatMap{ self.detectRectangles(in: $0) }
////            .debug("Poster: After Rectangle Detection (Not Posting)")
////            .share()
////
////        // Observe dectected rectangle observations for each frame, when isPosting == true
////        let isPostingRectObservable =
////            isPostingSubject.asObservable().filter( $ == true)
//////            frameObservable
//////                .withLatestFrom(isPostingSubject, resultSelector: { (frame, bool) -> ARFrame in
//////                    if bool == true {
//////                        return frame
//////                    } else {
//////                        return
//////                    }
//////                })
////                .filter { _ -> Bool in
////                    if self.isPosting {
////                        return true
////                    } else {
////                        return false
////                    }
////                }
////                .flatMap{ self.detectRectangles(in: $0) }
////                .share()
////
////        // Observe long press gestures. Filter gestures that are not on a vertical plane.
////        let longPressObservable =
////            longPressSubject.asObserver()
////                .debug("Poster-Press: Before OnPlane Filter")
////                .filter { (sender) -> Bool in
////                    // sender location must be on a plane
////                    let currTouchLocation = sender.location(in: self.sceneView)
////                    return self.isOnVerticalPlane(currTouchLocation)
////                }
////                .debug("Poster-Press: After OnPlane Filter")
////                .share()
////
////        // Observe long press that have state began or changed
////        let longPressActiveObservable =
////            longPressObservable
////                .filter { (sender) -> Bool in
////                    if sender.state == .began || sender.state == .changed{
////                        return true
////                    } else {
////                        return false
////                    }
////                }
////                .debug("Poster-Press: after Active Filter")
////                .share()
////
////        // Observe long press that have state ended
////        let longPressEndedObservable =
////            longPressObservable
////                .filter { (sender) -> Bool in
////                    if sender.state == .ended {
////                        return true
////                    } else {
////                        return false
////                    }
////                }
////                .debug("Poster-Press: after Ended Filter")
////                .share()
////
////
////        // 3) Choose rectangles to feed through descriptor / Highlight if necessary
////        // longPressActive + Not Posting --> user select rectangle. Highlight
////        let userSelectNotPostingObservable = longPressActiveObservable
////            .withLatestFrom(notPostingRectObservable) { (sender, observations) -> VNRectangleObservation? in
////                if (observations == nil) { return nil }
////                // Select rectangle observation that contains current touch location
////                let currTouchLocation = sender.location(in: self.sceneView)
////                for observation in observations! {
////                    let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
////                    if convertedRect.contains(currTouchLocation) {
////                        return observation
////                    }
////                }
////                return nil
////            }
////            .debug("Poster: after (longPressActive + Not Posting) withLatestFrom")
////            .filter{ $0 != nil }
////            .do(onNext: { (observation) in
////                // Outline selected observation
////                if let _ = observation {
////                    self.highlightObservation(observation!)
////                }
////            })
////
////
//
//    }
//
//    /**
//     Return rectangle that contains user touch.
//     */
//    fileprivate func selectRectangle(observations: [VNRectangleObservation]?, sender: UILongPressGestureRecognizer?) -> VNRectangleObservation? {
//        if sender == nil || observations == nil {
//            return nil
//        }
//        let currTouchLocation = sender!.location(in: self.sceneView)
//
//        // Check if currTouchLocation is on a vertical plane
//        if !isOnVerticalPlane(currTouchLocation) {
//            return nil
//        }
//
//        // Select rectangle
//        for observation in observations! {
//            let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
//            if convertedRect.contains(currTouchLocation) {
//                return observation
//            }
//        }
//
//        return nil
//    }
//
//    /**
//     Observe long press gesture to facilitate user interaction with poster discovery and placement.
//     */
//    private func setupLongPressSubject() {
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(observeLongPress(sender:)))
//        view.addGestureRecognizer(longPress)
//    }
//    @objc private func observeLongPress(sender: UILongPressGestureRecognizer) {
//        longPressSubject.onNext(sender)
//    }
//
//
//
//}

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
    
}
