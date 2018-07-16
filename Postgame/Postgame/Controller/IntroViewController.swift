//
//  IntroViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IntroViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .flatGray

        // configure sign-in button
        let signInButton = UIButton()
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        signInButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        signInButton.setTrailingConstraint(equalTo: view.centerXAnchor, offset: 0)
        signInButton.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font =  UIFont(name: "Catatan Perjalanan", size: 25)
        signInButton.titleLabel?.textColor = .flatWhite
        signInButton.backgroundColor = .flatBlue
        
        // configure sign-up button
        let signUpButton = UIButton()
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setLeadingConstraint(equalTo: view.centerXAnchor, offset: 0)
        signUpButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        signUpButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        signUpButton.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font =  UIFont(name: "Catatan Perjalanan", size: 25)
        signUpButton.titleLabel?.textColor = .flatWhite
        signUpButton.backgroundColor = .flatRed
        
    }
    

}
