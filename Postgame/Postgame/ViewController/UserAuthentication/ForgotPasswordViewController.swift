////
////  ForgotPasswordViewController.swift
////  project
////
////  Created by Andrew Jay Zhou on 3/11/18.
////  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
////
//
//import UIKit
//import AWSCognitoIdentityProvider
//
//class ForgotPasswordViewController: UIViewController {
//    // UI
//    var username: UITextField?
//    var forgotPasswordButton: UIButton?
//    
//    // AWS
//    var pool: AWSCognitoIdentityUserPool?
//    var user: AWSCognitoIdentityUser?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        self.pool = AWSCognitoIdentityUserPool(forKey: "us-east-2_a0pr7d57s")
//        
//        // Configure Username
//        let usernameLabel = UILabel()
//        usernameLabel.text = "Username"
//        view.addSubview(usernameLabel)
//        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
//        usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05).isActive = true
//        usernameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        usernameLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
//        usernameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
//        
//        username = UITextField()
//        view.addSubview(username!)
//        username!.translatesAutoresizingMaskIntoConstraints = false
//        username!.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
//        username!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
//        username!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        username!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        username!.placeholder = "Username"
//        username!.backgroundColor = .orange
//        
//        
//        // Configure Confirm Button
//        forgotPasswordButton = UIButton()
//        view.addSubview(forgotPasswordButton!)
//        forgotPasswordButton!.translatesAutoresizingMaskIntoConstraints = false
//        forgotPasswordButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height * -0.01).isActive = true
//        forgotPasswordButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
//        forgotPasswordButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
//        forgotPasswordButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
//        forgotPasswordButton!.setTitle("Confirm", for: .normal)
//        forgotPasswordButton!.backgroundColor = .gray
//        forgotPasswordButton!.addTarget(self, action: #selector(onForgotPasswordButton), for: .touchUpInside)
//        
//        // Dismiss keyboard with tap
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
//    }
//    
//    // Tap to dismiss Keyboard
//    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
//        view.endEditing(true)
//    }
//    
//    // ForgotPasswordButton Action
//    @objc func onForgotPasswordButton (sender: UITapGestureRecognizer) {
//        
//        // Handle forgot password
//        guard let username = self.username!.text, !username.isEmpty else {
//            
//            let alertController = UIAlertController(title: "Missing UserName",
//                                                    message: "Please enter a valid user name.",
//                                                    preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alertController.addAction(okAction)
//            
//            self.present(alertController, animated: true, completion:  nil)
//            return
//        }
//        
//        self.user = self.pool?.getUser(self.username!.text!)
//        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
//            guard let strongSelf = self else {return nil}
//            DispatchQueue.main.async(execute: {
//                if let error = task.error as NSError? {
//                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
//                                                            message: error.userInfo["message"] as? String,
//                                                            preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                    alertController.addAction(okAction)
//                    
//                    self?.present(alertController, animated: true, completion:  nil)
//                } else {
//                    // Segue
//                    let updatePasswordViewController = UpdatePasswordViewController()
//                    updatePasswordViewController.user = strongSelf.user
//                    strongSelf.navigationController?.pushViewController(updatePasswordViewController, animated: true)
//                }
//            })
//            return nil
//        }
//        
//        
//    }
//    
//    
//    
//}
