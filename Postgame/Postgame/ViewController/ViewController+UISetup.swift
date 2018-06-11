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
     Setup UI layout for main screen.
     */
    func setupUILayout() {
        setupSceneView()
        setupScreenshotButton()
        setupCreateButton()
        setupIndicatorButton()
        setupResetButton()
        setupUserButton()
    }
    
    /**
     Setup ARScnView for ViewController.
     */
    private func setupSceneView() {
        view.addSubview(sceneView)
//        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
//        sceneView.showsStatistics = true
    }
    
    /**
     Setup screenshotButton located on bottom right of main screen.
     */
    private func setupScreenshotButton() {
        view.addSubview(screenshotButton)
        setButtonBasics(screenshotButton)
        screenshotButton.setImage(UIImage(named: "ic_camera_alt"), for: .normal)
        screenshotButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: screenHeight * -0.02)
        screenshotButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: screenWidth * -0.05)
    }
    
    /**
     Setup createButton located on top right of main screen.
     */
    private func setupCreateButton() {
        view.addSubview(createButton)
        setButtonBasics(createButton)
        createButton.setImage(UIImage(named: "ic_add"), for: .normal)
        createButton.setTopConstraint(equalTo: view.topAnchor, offset: screenHeight * 0.02)
        createButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: screenWidth * -0.05)
    }
    
    /**
     Setup createButton located on top right of main screen.
     */
    private func setupIndicatorButton() {
        view.addSubview(indicatorButton)
        setButtonBasics(indicatorButton)
        indicatorButton.setTopConstraint(equalTo: view.topAnchor, offset: screenHeight * 0.02)
        indicatorButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: screenWidth * 0.05)
    }
    
    /**
     Setup resetButton located on top right of main screen.
     */
    private func setupResetButton() {
        view.addSubview(resetButton)
        setButtonBasics(resetButton)
        resetButton.setImage(UIImage(named: "ic_refresh"), for: .normal)
        resetButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: screenHeight * -0.02)
        resetButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: screenWidth * 0.05)
    }
    
    /**
     Setup userButton located on top right of main screen.
     */
    private func setupUserButton() {
        view.addSubview(userButton)
        setButtonBasics(userButton)
        userButton.setImage(UIImage(named: "ic_perm_identity"), for: .normal)
        userButton.setTopConstraint(equalTo: view.topAnchor, offset: screenHeight * 0.02)
        userButton.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
    }
}

/**
 Tune button basics for buttons on main screen.
 */
fileprivate func setButtonBasics(_ button: UIButton) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.clipsToBounds = true
    button.layer.cornerRadius = 0.5 * buttonLength
    button.setBackgroundImage(.from(color: UIColor.white.withAlphaComponent(buttonAlpha)), for: .normal)
    button.setBackgroundImage(.from(color: UIColor.gray.withAlphaComponent(buttonAlpha)), for: .selected)
    button.setWidthConstraint(buttonLength)
    button.setHeightConstraint(buttonLength)
}


