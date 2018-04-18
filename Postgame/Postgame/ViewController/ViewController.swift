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
    private let disposeBag = DisposeBag()

    // MARK:- UI Elements
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let screenshotButton = UIButton()
    let createButton = UIButton()
    let resetButton = UIButton()
    let userButton = UIButton()
    let indicatorButton = IndicatorButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
        
        // Take a screenshot - react to screenshotButton tap gesture
        screenshotButton.rx.tap
            .subscribe(onNext: {_ in
                let screenshot = self.sceneView.snapshot()
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        sceneView.session.run(configuration, options: .removeExistingAnchors)
    }
}
