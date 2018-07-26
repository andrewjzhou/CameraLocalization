//
//  VerificationModalViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/26/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import TextFieldEffects
import AWSCognitoIdentityProvider
import RxSwift
import RxCocoa
import PhoneNumberKit

final class VerificationModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurBackground()
        
        let nav = UINavigationController(rootViewController: VerificationModalPhoneViewController())
        addChildViewController(nav)
        nav.isNavigationBarHidden = true
        nav.hidesNavigationBarHairline = true
        
        let containerView = nav.view!
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        containerView.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.1 * UIScreen.main.bounds.height)
        containerView.setWidthConstraint(0.8 * view.bounds.width)
        containerView.setHeightConstraint(0.5 * view.bounds.height)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.flatBlack.withAlphaComponent(0.8).cgColor
        containerView.layer.borderWidth = 2.0
        containerView.backgroundColor = .flatWhite
        
       

        // Do any additional setup after loading the view.
        
    }
    

    private func blurBackground() {
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView =  UIVisualEffectView(effect: blurEffect)
        
        // add vibrancy
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.contentView.addSubview(vibrancyView)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.setTopConstraint(equalTo: effectView.topAnchor, offset: 0)
        vibrancyView.setBottomConstraint(equalTo: effectView.bottomAnchor, offset: 0)
        vibrancyView.setLeadingConstraint(equalTo: effectView.leadingAnchor, offset: 0)
        vibrancyView.setTrailingConstraint(equalTo: effectView.trailingAnchor, offset: 0)
        
        // add blur
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.setTopConstraint(equalTo: view.topAnchor, offset: 0)
        effectView.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        effectView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        effectView.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
    }

}
