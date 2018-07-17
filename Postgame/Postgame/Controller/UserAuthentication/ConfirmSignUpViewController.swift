//
//  ConfirmSignUpViewController.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/11/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ConfirmSignUpViewController: UIViewController {
    var username: UITextField?
    var confirmationCode: UITextField?
    var confirmButton: UIButton?
    var resendButton: UIButton?
    
    var user: AWSCognitoIdentityUser?
    var sentTo: String?
    
    var userInfo: [String: String]?
    
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
        let confirmationCodeLabel = UILabel()
        confirmationCodeLabel.text = "Confirmation Code"
        view.addSubview(confirmationCodeLabel)
        confirmationCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmationCodeLabel.topAnchor.constraint(equalTo: username!.bottomAnchor, constant: view.bounds.height * 0.05).isActive = true
        confirmationCodeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        confirmationCodeLabel.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.04).isActive = true
        confirmationCodeLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.5).isActive = true
        
        confirmationCode = UITextField()
        view.addSubview(confirmationCode!)
        confirmationCode!.translatesAutoresizingMaskIntoConstraints = false
        confirmationCode!.topAnchor.constraint(equalTo: confirmationCodeLabel.bottomAnchor, constant: view.bounds.height * 0.001).isActive = true
        confirmationCode!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.07).isActive = true
        confirmationCode!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        confirmationCode!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        confirmationCode!.placeholder = "Confirmation Code"
        confirmationCode!.backgroundColor = .orange
        
        // Configure Confirm Button
        confirmButton = UIButton()
        view.addSubview(confirmButton!)
        confirmButton!.translatesAutoresizingMaskIntoConstraints = false
        confirmButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height * -0.01).isActive = true
        confirmButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
        confirmButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        confirmButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        confirmButton!.setTitle("Confirm", for: .normal)
        confirmButton!.backgroundColor = .gray
        confirmButton!.addTarget(self, action: #selector(onConfirmButton), for: .touchUpInside)
        
        // Configure Resend Button
        resendButton = UIButton()
        view.addSubview(resendButton!)
        resendButton!.translatesAutoresizingMaskIntoConstraints = false
        resendButton!.bottomAnchor.constraint(equalTo: confirmButton!.topAnchor, constant: view.bounds.height * -0.05).isActive = true
        resendButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
        resendButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        resendButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        resendButton!.setTitle("Resend", for: .normal)
        resendButton!.backgroundColor = .gray
        resendButton!.addTarget(self, action: #selector(onResendButton), for: .touchUpInside)
        
        // Set username
        self.username!.text = self.user!.username
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // ConfirmButton Action
    @objc func onConfirmButton (sender: UITapGestureRecognizer) {
        guard let confirmationCodeValue = self.confirmationCode!.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation code missing.",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
    
        self.user?.confirmSignUp(self.confirmationCode!.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    print("Confirmed Sign up")
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                
                }
            })
            return nil
        }
    }
    
    // ResendButton Action
    @objc func onResendButton (sender: UITapGestureRecognizer) {
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Resent",
                                                            message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }
    
    
}
