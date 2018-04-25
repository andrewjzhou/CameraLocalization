//
//  ViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/17/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import RxSwift
import RxCocoa
import CoreLocation
import AWSCognitoIdentityProvider

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
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
    private var isPosting: Bool = false
    
    // Location
    private var location: CLLocationCoordinate2D?
    private let s3 = AWSS3Service()
    
    // AWS Cognito
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    private var descriptorCache = [String: [UInt8]]()
    
    // Poster Rx
    private let frameSubject = PublishSubject<ARFrame>()
    private let longPressSubject = PublishSubject<UILongPressGestureRecognizer>()
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
        setupLocationServiceAndDescriptorCache()
        
        // AWS S3
//        setupAWSS3Service()
//        let key = "40.3496/-74.6574/2018-04-09@10:28:26/surface"
//        s3.download(for: key)
        
        // Setup AR Poster Discovery and Placement Rx
        setupARPosetrDiscoveryAndPlacementRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Run the view's session
        sceneView.session.run(trackingConfiguration)
        sceneView.session.delegate = self
        
        // AWS Cognito
        fetchUserAttributes()
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
            .filter { self.isPosting == false }
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
                            self.isPosting = true
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
            .filter { self.isPosting == true }
            .subscribe(onNext: {_ in
                self.createButton.setImage(UIImage(named: "ic_add"), for: .normal) // default image
                self.isPosting = false
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
            .debug("Descriptor Cache: Before map1")
            .map{ // test -> (Double, Double) in
                // Convert CLLocation coordinates to 4 decimal places
                (self.roundToDecimal4($0.latitude as Double), self.roundToDecimal4($0.longitude as Double))
//                return (40.3496, -74.6574)
            }
            .debug("Descriptor Cache: After map1")
            .distinctUntilChanged({ (location1, location2) -> Bool in
                // Only send request if output changed
                let precision = 0.0002
                if abs(location1.0 - location2.0) < precision && abs(location1.1 - location2.1) < precision {
                    return true
                } else {
                    return false
                }
            })
            .do(onNext: { (location) in
                // Refresh cache. Remove descriptors that are not inside user region
                for key in self.descriptorCache.keys {
                    if !self.keyCloseToLocation(key: key, location: location) {
                        self.descriptorCache.removeValue(forKey: key)
                    }
                }
            })
            .debug("After distinct until changed")
            .asObservable()
    
        
        // Cache descritpors based on user location
        userLocation
            .map { coordinate in
                // Get surrounding coordinates
                return self.surroundingCoordinates(for: coordinate)
            }
            .debug("Descriptor Cache: After map2")
            .flatMap { locations in
                // Get list or URLs asscossiated with coordinates
                return self.s3.urlList(for: locations)
            }
            .debug("Descriptor Cache: After flat-map")
            .flatMap({ (url) in
                // Download descriptors
                return self.s3.downloadDescriptor(url)
            })
            .subscribe(onNext: { (descriptor) in
                // Cache descriptors
                self.descriptorCache.updateValue(descriptor.value, forKey: descriptor.key)
            }, onError: { (error) in
                print("Descriptor Cache Error: ", error)
            })
            .disposed(by: disposeBag)
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

/**
 MARK:- AWS S3.
 */
extension ViewController {
//    func setupAWSS3Service() {
//
//        let s3 = AWSS3Service()
//        let key = "40.3496/-74.6574/2018-04-09@10:28:26/surface"
//        s3.download(for: key)
//
////        AppDelegate.defaultUserPool().currentUser()?.signOut()
//
//
//    }
}

/**
 MARK:- AWS Cognito.
 */
extension ViewController {
    func fetchUserAttributes() {
        
        user = AppDelegate.defaultUserPool().currentUser()
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                
                return nil
            }
            
            self.userAttributes = task.result?.userAttributes
            self.userAttributes?.forEach({ (attribute) in
                
            })
            return nil
        })
    }
}

/**
 MARK:- ARSession Controls.
 */
extension ViewController {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameSubject.onNext(frame)
    }
    
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("ARSession: Session Was Interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("ARSession: Session Interruption Ended")
        self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
    }
    
   
}

/**
 MARK:- Setup Poster Rx, main per-frame opertaions.
 */

extension ViewController {
    /**
     Setup Poster Rx, main per-frame opertaions.
     */
    private func setupARPosetrDiscoveryAndPlacementRx() {
        // Start observing long press gesture on view
        setupLongPressSubject()
        
        // Observe ARFrame. Slow down frame rate. Remove drawn outlines for selected rectangles, if any exist
        let frameObservable =
            frameSubject.asObservable()
                .debug("Poster: Before Throttle")
                .throttle(0.1, scheduler:  MainScheduler.instance) // slow down requests
                .debug("Poster: After Throttle")
                .do(onNext: { (_) in
                    self.removeRectOutlineLayers() // clean up drawings, if there is any
                })
       
        // Observe dectected rectangle observations for each frame, when isPosting == false
        let notPostingRectObservable = frameObservable
            .filter { _ -> Bool in
                if !self.isPosting {
                    return true
                } else {
                    return false
                }
            }
            .debug("Poster: After Not Posting Filter")
            .flatMap{ self.detectRectangles(in: $0) }
            .debug("Poster: After Rectangle Detection (Not Posting)")
    
        // Observe dectected rectangle observations for each frame, when isPosting == true
        let isPostingRectObservable =
            frameObservable
                .filter { _ -> Bool in
                    if self.isPosting {
                        return true
                    } else {
                        return false
                    }
                }
                .flatMap{ self.detectRectangles(in: $0) }
        
        // Observe long press gestures. Filter gestures that are not on a vertical plane.
        let longPressObservable =
            longPressSubject.asObserver()
                .debug("Poster-Press: Before OnPlane Filter")
                .filter { (sender) -> Bool in
                    // sender location must be on a plane
                    let currTouchLocation = sender.location(in: self.sceneView)
                    return self.isOnVerticalPlane(currTouchLocation)
                }
                .debug("Poster-Press: After OnPlane Filter")
       
        // Observe long press that have state began or changed
        let longPressActiveObservable =
            longPressObservable
                .filter { (sender) -> Bool in
                    if sender.state == .began || sender.state == .changed{
                        return true
                    } else {
                        return false
                    }
                }
                .debug("Poster-Press: after Active Filter")
        
        // Observe long press that have state ended
        let longPressEndedObservable =
            longPressObservable
                .filter { (sender) -> Bool in
                    if sender.state == .ended {
                        return true
                    } else {
                        return false
                    }
                }
                .debug("Poster-Press: after Ended Filter")
        
        
        // longPressActive + Not Posting --> highlight selected rectangles
        longPressActiveObservable
            .withLatestFrom(notPostingRectObservable) { (sender, observations) -> VNRectangleObservation? in
                if (observations == nil) { return nil }
                // Select rectangle observation that contains current touch location
                let currTouchLocation = sender.location(in: self.sceneView)
                for observation in observations! {
                    let convertedRect = self.sceneView.convertFromCamera(observation.boundingBox)
                    if convertedRect.contains(currTouchLocation) {
                        return observation
                    }
                }
                return nil
            }
            .debug("Poster: after (longPressActive + Not Posting) withLatestFrom")
            .filter{ $0 != nil }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { (observation) in
                // Outline selected observation
                if let _ = observation {
                    self.highlightObservation(observation!)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    /**
     Observe long press gesture to facilitate user interaction with poster discovery and placement.
     */
    private func setupLongPressSubject() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(observeLongPress(sender:)))
        view.addGestureRecognizer(longPress)
    }
    @objc private func observeLongPress(sender: UILongPressGestureRecognizer) {
        longPressSubject.onNext(sender)
    }
    
    /**
     Detect rectangles in a frame.
     */
    private func detectRectangles(in frame: ARFrame) -> Observable<[VNRectangleObservation]?>{
        return Observable.create({ observer in
            let request = VNDetectRectanglesRequest(completionHandler: { (request, error) in
                // Filter observations and observe detected results
                guard let observations = request.results as? [VNRectangleObservation],
                    let _ = observations.first else {
                        observer.onNext(nil)
                        observer.onCompleted()
                        return
                }
                
                let filteredObservations = self.filterContainedRects(observations)
                observer.onNext(filteredObservations)
                observer.onCompleted()
            })
            
            // Don't limit resulting number of observations
            request.maximumObservations = 1
            request.quadratureTolerance = 5
            request.minimumConfidence   = 0.6
            //            request.minimumAspectRatio  = 0.5
            //            request.maximumAspectRatio  = 2.0
            
            // Perform request
            let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
            try? handler.perform([request])
            return Disposables.create()
        })
    }
    
    /**
     Filter out rectangle observations that are contained by another rectangle observation.
     */
    fileprivate func filterContainedRects(_ observations: [VNRectangleObservation]) -> [VNRectangleObservation]{
        // Sort in increasing order
        var filtered = [VNRectangleObservation]()
        let sorted = observations.sorted(by: { (o1, o2) -> Bool in
            if o1.boundingBox.size.smaller(than: o2.boundingBox.size) {
                return true
            }
            return false
        })
        
        // Check if observation is contained
        let length = sorted.count
        for i in 0..<length{
            let currObservation = sorted[i]
            
            var contained = false
            for j in (i+1)..<length {
                if sorted[j].boundingBox.contains(currObservation.boundingBox) {
                    contained = true
                    break
                }
            }
            
            // Appened uncontained observation
            if !contained {
                filtered.append(currObservation)
            }
        }
        return filtered
    }
    
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
    
    
    /**
     Check if touch location is on a vertical plane.
     */
    fileprivate func isOnVerticalPlane(_ point: CGPoint) -> Bool {
        let results = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        if let _ = results.first{
        return true
        }
        return false
    }
}
