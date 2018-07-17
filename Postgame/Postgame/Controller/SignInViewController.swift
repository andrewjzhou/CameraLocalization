//
//  SignInViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import RxCocoa
import RxSwift

class SignInViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var introVC: IntroViewController?
    
    var usernameText: String?
    
    var usernameField = UITextField()
    var passwordField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .flatWhite
        
        setupUsernameInput()
        setupPasswordInput()
        setupSignInButton()
        setupBackButton()
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func setupUsernameInput() {
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setLeadingConstraint(equalTo: view.leadingAnchor, offset: UIScreen.main.bounds.width * 0.2)
        label.setTopConstraint(equalTo: view.topAnchor, offset: UIScreen.main.bounds.height * 0.18)
        label.setWidthConstraint(UIScreen.main.bounds.width * 0.25)
        label.text = "Username:"
        label.textColor = .flatBlack
        
        view.addSubview(usernameField)
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.autocorrectionType = .no
        usernameField.setLeadingConstraint(equalTo: label.leadingAnchor, offset: 0)
        usernameField.setTopConstraint(equalTo: label.bottomAnchor,
                                       offset: UIScreen.main.bounds.height * 0.025)
        usernameField.setTrailingConstraint(equalTo: view.trailingAnchor,
                                            offset: -UIScreen.main.bounds.width * 0.25)
        usernameField.contentVerticalAlignment = .bottom
        addUnderline(for: usernameField)
        
    }
    
    func setupPasswordInput() {
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setLeadingConstraint(equalTo: view.leadingAnchor, offset: UIScreen.main.bounds.width * 0.2)
        label.setTopConstraint(equalTo: view.topAnchor, offset: UIScreen.main.bounds.height * 0.35)
        label.setWidthConstraint(UIScreen.main.bounds.width * 0.25)
        label.text = "Password:"
        label.textColor = .flatBlack
        
        view.addSubview(passwordField)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.setLeadingConstraint(equalTo: label.leadingAnchor, offset: 0)
        passwordField.setTopConstraint(equalTo: label.bottomAnchor,
                                       offset: UIScreen.main.bounds.height * 0.025)
        passwordField.setTrailingConstraint(equalTo: view.trailingAnchor,
                                            offset: -UIScreen.main.bounds.width * 0.25)
        passwordField.contentVerticalAlignment = .bottom
        addUnderline(for: passwordField)
        passwordField.isSecureTextEntry = true
    }
    
    func setupSignInButton() {
        let signInButton = UIButton()
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        signInButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        signInButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        signInButton.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font =  UIFont(name: "Catatan Perjalanan", size: 25)
        signInButton.titleLabel?.textColor = .flatWhite
        signInButton.backgroundColor = .flatSkyBlue
        
        // tapped
        signInButton.rx.tap.bind {
            if (self.usernameField.text != nil && self.passwordField.text != nil) {
                let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameField.text!,
                                                                                  password: self.passwordField.text! )
                self.introVC?.passwordAuthenticationCompletion?.set(result: authDetails)
                print("SignIn: button clicked")
                
            } else {
                let alertController = UIAlertController(title: "Missing information",
                                                        message: "Please enter a valid user name and password",
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
            }
        }.disposed(by: disposeBag)
    }
    
    func setupBackButton() {
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.setImage(UIImage(named: "ic_baseline_keyboard_arrow_left_black_24pt"), for: .normal)
        backButton.backgroundColor = .clear
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setWidthConstraint(64)
        backButton.setHeightConstraint(64)
        backButton.setTopConstraint(equalTo: view.topAnchor, offset: 15)
        backButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 15)
        backButton.tintColor = .flatGray
        backButton.rx.tap.bind {
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    
}

//extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
//
//    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
//        print("SignIn: getDetails()")
//        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
//
//        DispatchQueue.main.async {
//            if (self.usernameText == nil) {
//                self.usernameText = authenticationInput.lastKnownUsername
//            }
//        }
//    }
//
//    public func didCompleteStepWithError(_ error: Error?) {
//        print("Error found")
//        DispatchQueue.main.async {
//            if let error = error as NSError? {
//                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
//                                                        message: error.userInfo["message"] as? String,
//                                                        preferredStyle: .alert)
//                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
//                alertController.addAction(retryAction)
//
//                self.present(alertController, animated: true, completion:  nil)
//            } else {
//                self.usernameField.text = nil
//                self.navigationController?.dismiss(animated: true, completion: nil)
////                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
//}

func addUnderline(for textField: UITextField) {
    let underline = UIView()
    textField.addSubview(underline)
    underline.translatesAutoresizingMaskIntoConstraints = false
    underline.backgroundColor = .flatGray
    underline.setLeadingConstraint(equalTo: textField.leadingAnchor, offset: 0)
    underline.setTrailingConstraint(equalTo: textField.trailingAnchor, offset: 0)
    underline.setBottomConstraint(equalTo: textField.bottomAnchor, offset: 0)
    underline.setHeightConstraint(2.0)
}
