////
////  SignInViewController.swift
////  project
////
////  Created by Andrew Jay Zhou on 3/11/18.
////  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
////
//
//import UIKit
//import AWSCognitoIdentityProvider
//
//class SignInViewController: UIViewController {
//    
//    // UI
//    var logo: UIImageView?
//    var username: UITextField?
//    var password: UITextField?
//    var signInButton: UIButton?
//    var signUpButton: UIButton?
//    var fogotPasswordButton: UIButton?
//    
//    // AWS
//    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
//    var usernameText: String?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        //        // Configure Logo
//        //        logo = UIImageView(image: UIImage(named: "banksy")!)
//        //        view.addSubview(logo!)
//        //        logo!.translatesAutoresizingMaskIntoConstraints = false
//        //        logo!.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.2).isActive = true
//        //        logo!.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.6).isActive = true
//        //        logo!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.2).isActive = true
//        //        logo!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.2).isActive = true
//        
//        // Configure Username
//        username = UITextField()
//        view.addSubview(username!)
//        username!.translatesAutoresizingMaskIntoConstraints = false
//        username!.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.1).isActive = true
//        username!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
//        username!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        username!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        username!.placeholder = "Username"
//        //        username!.isUserInteractionEnabled = false
//        username!.backgroundColor = .orange
//        
//        // Configure Password
//        password = UITextField()
//        view.addSubview(password!)
//        password!.translatesAutoresizingMaskIntoConstraints = false
//        password!.topAnchor.constraint(equalTo: username!.bottomAnchor, constant: view.bounds.height * 0.012).isActive = true
//        password!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
//        password!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        password!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        password!.placeholder = "Password"
//        //        password!.isUserInteractionEnabled = false
//        password!.backgroundColor = .orange
//        
//        // Configure SignInButton
//        signInButton = UIButton()
//        view.addSubview(signInButton!)
//        signInButton!.translatesAutoresizingMaskIntoConstraints = false
//        signInButton!.topAnchor.constraint(equalTo: password!.bottomAnchor, constant: view.bounds.height * 0.012).isActive = true
//        signInButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
//        signInButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        signInButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        signInButton!.setTitle("Sign In", for: .normal)
//        signInButton!.backgroundColor = .gray
//        signInButton!.addTarget(self, action: #selector(onSignInButton), for: .touchUpInside)
//        
//        // Configure SignUpButton
//        signUpButton = UIButton()
//        view.addSubview(signUpButton!)
//        signUpButton!.translatesAutoresizingMaskIntoConstraints = false
//        signUpButton!.topAnchor.constraint(equalTo: signInButton!.bottomAnchor, constant: view.bounds.height * 0.02).isActive = true
//        signUpButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.03).isActive = true
//        signUpButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        signUpButton!.widthAnchor.constraint(equalToConstant: 64).isActive = true
//        signUpButton!.setTitle("Sign Up", for: .normal)
//        signUpButton!.backgroundColor = .gray
//        signUpButton!.addTarget(self, action: #selector(onSignUpButton), for: .touchUpInside)
//        
//        // Configure ForgotPasswordButton
//        fogotPasswordButton = UIButton()
//        view.addSubview(fogotPasswordButton!)
//        fogotPasswordButton!.translatesAutoresizingMaskIntoConstraints = false
//        fogotPasswordButton!.topAnchor.constraint(equalTo: signInButton!.bottomAnchor, constant: view.bounds.height * 0.02).isActive = true
//        fogotPasswordButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.03).isActive = true
//        fogotPasswordButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        fogotPasswordButton!.widthAnchor.constraint(equalToConstant: 160).isActive = true
//        fogotPasswordButton!.setTitle("Forgot Password", for: .normal)
//        fogotPasswordButton!.backgroundColor = .gray
//        fogotPasswordButton!.addTarget(self, action: #selector(onFogotPasswordButton), for: .touchUpInside)
//        
//    }
//    
//    // SignInButton Action
//    @objc func onSignInButton (sender: UITapGestureRecognizer) {
//        if (self.username!.text != nil && self.password!.text != nil) {
//            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.username!.text!, password: self.password!.text! )
//            self.passwordAuthenticationCompletion?.set(result: authDetails)
//            print("Sign-In Action")
//            
//        } else {
//            let alertController = UIAlertController(title: "Missing information",
//                                                    message: "Please enter a valid user name and password",
//                                                    preferredStyle: .alert)
//            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
//            alertController.addAction(retryAction)
//        }
//    }
//    
//    // SignUpButton Action
//    @objc func onSignUpButton (sender: UITapGestureRecognizer) {
//        navigationController?.pushViewController(SignUpViewController(), animated: true)
//    }
//    
//    // ForgotPasswordButton Action
//    @objc func onFogotPasswordButton (sender: UITapGestureRecognizer) {
//        navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
//    }
//    
//}
//
//extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
//    
//    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
//        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
//        
//        DispatchQueue.main.async {
//            if (self.usernameText == nil) {
//                self.usernameText = authenticationInput.lastKnownUsername
//            }
//        }
//        
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
//                self.username!.text = nil
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
//}
//
