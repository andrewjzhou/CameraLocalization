//
//  ViewController+UISetup.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import ARKit

fileprivate let buttonLength : CGFloat = 54.0
fileprivate let buttonAlpha : CGFloat = 0.5
fileprivate let screenHeight = UIScreen.main.bounds.height
fileprivate let screenWidth = UIScreen.main.bounds.width

extension ViewController {
    /**
     Setup UI for main screen.
     */
    func setupUI() {
        setupSceneView()
        setupScreenshotButton()
    }
    
    /**
     Setup ARScnView for ViewController.
     */
    private func setupSceneView() {
        view.addSubview(sceneView)
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    /**
     Setup screenshotButton located on bottom right of main screen.
     */
    private func setupScreenshotButton() {
        view.addSubview(screenshotButton)
        setButtonBasics(screenshotButton)
        screenshotButton.setImage(UIImage(named: "ic_camera_alt"), for: .normal)
        screenshotButton.setBackgroundImage(.from(color: UIColor.white.withAlphaComponent(buttonAlpha)), for: .normal)
        screenshotButton.setBackgroundImage(.from(color: UIColor.gray.withAlphaComponent(buttonAlpha)), for: .selected)
        screenshotButton.setWidthConstraint(buttonLength)
        screenshotButton.setHeightConstraint(buttonLength)
        screenshotButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: screenHeight * -0.02)
        screenshotButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: screenWidth * -0.05)
//        screenshotButton.addTarget(self, action: #selector(onScreenshotButton), for: .touchUpInside)
    }
}

fileprivate func setButtonBasics(_ button: UIButton) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.clipsToBounds = true
    button.layer.cornerRadius = 0.5 * buttonLength
}


