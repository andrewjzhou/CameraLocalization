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
import RxSwift
import RxCocoa
import CoreLocation
import AWSCognitoIdentityProvider

class ViewController: UIViewController, ARSCNViewDelegate {
    fileprivate let disposeBag = DisposeBag()
    fileprivate let trackingConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        return config
    }()

    // MARK:- UI Elements
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
    
    // AWS Cognito
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup buttons design on the main screen
        setupUILayout()
        
        // Setup Rx functions
        setupScreenshoButtonRx()
        setupResetButtonRx()
        setupCreateButtonRx()
        
        // Setup Location
        setupLocationServiceAndDescriptorCache()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Run the view's session
        sceneView.session.run(trackingConfiguration)
        
        // AWS Cognito
        fetchUserAttributes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        sceneView.session.run(trackingConfiguration, options: .removeExistingAnchors)
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
 Rx for ViewDidLoad Buttons
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
 Location Service.
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
        let geolocationService = GeolocationService.instance
        
        geolocationService.location
            .map{
                // Convert CLLocation coordinates to 4 decimal places
                (self.roundToDecimal4($0.latitude as Double), self.roundToDecimal4($0.longitude as Double))
            }
            .distinctUntilChanged({ (location1, location2) -> Bool in
                if abs(location1.0 - location2.0) < 0.0002 && abs(location1.1 - location2.1) < 0.0002{
                    return true
                } else {
                    return false
                }
            })
            .drive(onNext: { (location) in
                // Request URL list here
            })
            .disposed(by: disposeBag)
      
    }
    
    fileprivate func roundToDecimal4(_ value: Double) -> Double{
        return Double(round(10000*value)/10000)
    }
}


/**
 AWS Cognito.
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
