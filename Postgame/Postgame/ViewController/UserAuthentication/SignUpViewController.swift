//
//  SignUpViewController.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/11/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileClient
import AWSAuthCore

class SignUpViewController: UIViewController {
    
    var username: UITextField?
    var password: UITextField?
    var phone: UITextField?
    var email: UITextField?
    var signUpButton: UIButton?
    
    let pool = AppDelegate.defaultUserPool()
    var sentTo: String?
    
    override func viewWillAppear(_ animated: Bool) {
       //        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Configure Username
        let usernameLabel = UILabel()
        usernameLabel.text = "Username"
        view.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
        
        username = UITextField()
        view.addSubview(username!)
        username!.translatesAutoresizingMaskIntoConstraints = false
        username!.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
        username!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
        username!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        username!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        username!.placeholder = "Username"
        username!.backgroundColor = .orange
        
        // Configure Password
        let passwordLabel = UILabel()
        passwordLabel.text = "Password"
        view.addSubview(passwordLabel)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.topAnchor.constraint(equalTo: username!.bottomAnchor, constant: view.bounds.height * 0.05).isActive = true
        passwordLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
        passwordLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
        
        password = UITextField()
        view.addSubview(password!)
        password!.translatesAutoresizingMaskIntoConstraints = false
        password!.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
        password!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
        password!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        password!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        password!.placeholder = "Password"
        password!.backgroundColor = .orange
        
        // Configure Phone
        let phoneLabel = UILabel()
        phoneLabel.text = "Phone"
        view.addSubview(phoneLabel)
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.topAnchor.constraint(equalTo: password!.bottomAnchor, constant: view.bounds.height * 0.05).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        phoneLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
        phoneLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
        
        phone = UITextField()
        view.addSubview(phone!)
        phone!.translatesAutoresizingMaskIntoConstraints = false
        phone!.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
        phone!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
        phone!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        phone!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        phone!.placeholder = "Phone"
        phone!.backgroundColor = .orange
        
        // Configure Email
        let emailLabel = UILabel()
        emailLabel.text = "Email"
        view.addSubview(emailLabel)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.topAnchor.constraint(equalTo: phone!.bottomAnchor, constant: view.bounds.height * 0.05).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
        
        email = UITextField()
        view.addSubview(email!)
        email!.translatesAutoresizingMaskIntoConstraints = false
        email!.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
        email!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
        email!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        email!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        email!.placeholder = "Email"
        email!.backgroundColor = .orange
        
        // Configure SignUp Button
        signUpButton = UIButton()
        view.addSubview(signUpButton!)
        signUpButton!.translatesAutoresizingMaskIntoConstraints = false
        signUpButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height * -0.01).isActive = true
        signUpButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
        signUpButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        signUpButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        signUpButton!.setTitle("Sign Up", for: .normal)
        signUpButton!.backgroundColor = .gray
        signUpButton!.addTarget(self, action: #selector(onSignUpButton), for: .touchUpInside)
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // SignUpButton Action
    @objc func onSignUpButton (sender: UITapGestureRecognizer) {
        guard let userNameValue = self.username!.text, !userNameValue.isEmpty,
            let passwordValue = self.password!.text, !passwordValue.isEmpty else {
                let alertController = UIAlertController(title: "Missing Required Fields",
                                                        message: "Username / Password are required for registration.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
        }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let phoneValue = self.phone!.text, !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = phoneValue
            attributes.append(phone!)
        }
        
        if let emailValue = self.email!.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        
        
        //sign up the user
        self.pool.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        let confirmSignUpViewController = ConfirmSignUpViewController()
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        confirmSignUpViewController.sentTo = strongSelf.sentTo
                        confirmSignUpViewController.user = strongSelf.pool.getUser(strongSelf.username!.text!)
                        confirmSignUpViewController.userInfo = ["username": strongSelf.username!.text!,
                                                                "phone": strongSelf.phone!.text!,
                                                                "email": strongSelf.email!.text!]
                        
                        self?.navigationController?.pushViewController(confirmSignUpViewController, animated: true)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            return nil
        }
    }
    
    
    
}
