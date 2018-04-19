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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup buttons design on the main screen
        setupUILayout()
        
        // Take a screenshot - React to screenshotButton tap gesture
        screenshotButton.rx.tap
            .subscribe(onNext: {_ in
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            })
            .disposed(by: disposeBag)
        
        // Reset ARScnView - Rreact to resetButton tap gesture
        resetButton.rx.tap
            .subscribe(onNext: {_ in
                self.sceneView.session.run(self.trackingConfiguration, options: .removeExistingAnchors)
            })
            .disposed(by: disposeBag)
        
        view.addSubview(CreationView())
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
}
