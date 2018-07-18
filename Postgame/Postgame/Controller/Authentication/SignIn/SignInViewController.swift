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
import TextFieldEffects

final class SignInViewController: UIViewController, UITextFieldDelegate {
    private let disposeBag = DisposeBag()
    private var buttonsShouldReactToKeyboard = true
    
    var introVC: IntroViewController?
    
    var usernameText: String?
    
    var usernameField = IsaoTextField(frame: CGRect(x: UIScreen.main.bounds.width * 0.15,
                                                     y: UIScreen.main.bounds.height * 0.1,
                                                     width: UIScreen.main.bounds.width * 0.7,
                                                     height: UIScreen.main.bounds.height * 0.075))
    var passwordField = IsaoTextField(frame: CGRect(x: UIScreen.main.bounds.width * 0.15,
                                                    y: UIScreen.main.bounds.height * 0.25,
                                                    width: UIScreen.main.bounds.width * 0.7,
                                                    height: UIScreen.main.bounds.height * 0.075))
    let signInButton = UIButton()
    let fpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .flatWhite
        
        setupUsernameInput()
        setupPasswordInput()
        setupSignInButton()
        setupBackButton()
        setupForgotPasswordButton()
        configureKeyboardDisplayAnimations()
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func setupUsernameInput() {
        view.addSubview(usernameField)
        usernameField.placeholder = "Username"
        usernameField.activeColor = .flatSkyBlue
        usernameField.inactiveColor = .flatGrayDark
        usernameField.autocorrectionType = .no
        usernameField.autocapitalizationType = .none
        usernameField.delegate = self
    }
    
    func setupPasswordInput() {
        view.addSubview(passwordField)
        passwordField.placeholder = "Password"
        passwordField.activeColor = .flatSkyBlue
        passwordField.inactiveColor = .flatGrayDark
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
    }
    
    func setupSignInButton() {
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
        backButton.setTopConstraint(equalTo: view.topAnchor, offset: 0.02 * UIScreen.main.bounds.height)
        backButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0.02 * UIScreen.main.bounds.width)
        backButton.tintColor = .flatGray
        backButton.rx.tap.bind {
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    func setupForgotPasswordButton() {
        view.addSubview(fpButton)
        let fpWidth = UIScreen.main.bounds.width * 0.35
        let fpHeight = UIScreen.main.bounds.height * 0.05
        fpButton.translatesAutoresizingMaskIntoConstraints = false
        fpButton.setWidthConstraint(fpWidth)
        fpButton.setHeightConstraint(fpHeight)
        fpButton.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        fpButton.setBottomConstraint(equalTo: signInButton.topAnchor, offset: -0.05 * UIScreen.main.bounds.height)
        fpButton.layer.cornerRadius = 0.12 * fpWidth
        fpButton.setTitle("Forgot Password", for: .normal)
        fpButton.backgroundColor = .flatGray
        fpButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        fpButton.titleLabel?.textColor = .flatWhite
        fpButton.rx.tap.bind {
            self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
        }.disposed(by: disposeBag)
        
    }
    
    func configureKeyboardDisplayAnimations() {
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [fpButton, signInButton](notification) in
                if let userInfo = notification.userInfo {
                    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                    let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: {
                                    let transform = CGAffineTransform(translationX: 0, y: -(endFrame?.size.height ?? 0.0))
                                    fpButton.transform = transform
                                    signInButton.transform = transform
                    },
                                   completion: nil)
                }
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [weak self](notification) in
                if self == nil { return }
                if self!.buttonsShouldReactToKeyboard {
                    if let userInfo = notification.userInfo {
                        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                        UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: {
                                        self?.fpButton.transform = .identity
                                        self?.signInButton.transform = .identity
                        },
                                       completion: nil)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            buttonsShouldReactToKeyboard = false
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            buttonsShouldReactToKeyboard = true
            textField.resignFirstResponder()
            signInButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
    
}

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
