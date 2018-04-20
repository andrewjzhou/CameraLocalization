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
    private lazy var isPostingSubject = BehaviorSubject<Bool>(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup buttons design on the main screen
        setupUILayout()
        
        /**
         Take a screenshot - React to screenshotButton tap gesture
         */
        screenshotButton.rx.tap
            .subscribe(onNext: {_ in
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            })
            .disposed(by: disposeBag)
       
        
        /**
         Reset ARScnView - React to resetButton tap gesture
         */
        resetButton.rx.tap
            .subscribe(onNext: {_ in
                self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
            })
            .disposed(by: disposeBag)
        
        
        /**
         Activate CreationView - React to createButton tap gesture
         */
        createButton.rx.tap
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
                            creationView.animateExit()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Run the view's session
        sceneView.session.run(trackingConfiguration)
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
