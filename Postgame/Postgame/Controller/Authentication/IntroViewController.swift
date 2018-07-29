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
import AWSCognitoIdentityProvider


final class IntroViewController: UIViewController {
    let disposeBag = DisposeBag()
    var usernameText: String?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    var signUpInfo = SignUpInfo()
    struct SignUpInfo {
        var username: String?
        var password: String?
        var email: String?
        var phone: String?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white

        // configure sign-in button
        let signInButton = UIButton()
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setLeadingConstraint(equalTo: view.centerXAnchor, offset: 0)
        signInButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        signInButton.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        signInButton.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font =  UIFont(name: "Montserrat-Bold", size: 25)
        signInButton.titleLabel?.textColor = .flatWhite
        signInButton.backgroundColor = .flatGreen
        signInButton.rx.tap.bind {
            let signInVC = SignInViewController()
            signInVC.introVC = self
            self.navigationController?.pushViewController(signInVC, animated: true)
        }.disposed(by: disposeBag)
        
        // configure sign-up button
        let signUpButton = UIButton()
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        signUpButton.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        signUpButton.setTrailingConstraint(equalTo: view.centerXAnchor, offset: 0)
        signUpButton.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font =  UIFont(name: "Montserrat-Bold", size: 25)
        signUpButton.titleLabel?.textColor = .flatWhite
        signUpButton.backgroundColor = .flatRed
        signUpButton.rx.tap.bind {
            let usernameVC = UsernameViewController()
            usernameVC.introVC = self
            self.navigationController?.pushViewController(usernameVC, animated: true)
        }.disposed(by: disposeBag)
        
        // logo
        let logoView = UIImageView(image: UIImage(named: "launchscreen")!)
        view.addSubview(logoView)
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        logoView.setTopConstraint(equalTo: view.topAnchor, offset: 0)
        logoView.setTrailingConstraint(equalTo: view.trailingAnchor,
                                       offset: -0.02 * UIScreen.main.bounds.width)
        logoView.setBottomConstraint(equalTo: signInButton.topAnchor,
                                     offset: -0.03 * UIScreen.main.bounds.height)
    }
    
    func clearUserInfo() {
        signUpInfo = SignUpInfo()
    }
    
    

}

extension IntroViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        print("SignIn: getDetails()")
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
//                self.usernameField.text = nil
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
