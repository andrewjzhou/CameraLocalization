//
//  UpdatePasswordViewController.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/11/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class UpdatePasswordViewController: UIViewController {
    
    // UI
    var confirmationCode: UITextField?
    var password: UITextField?
    var updateButton: UIButton?
    
    // AWS
    var user: AWSCognitoIdentityUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Configure Username
        let confirmationCodeLabel = UILabel()
        confirmationCodeLabel.text = "Confirmation Code"
        view.addSubview(confirmationCodeLabel)
        confirmationCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmationCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05).isActive = true
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
        
        // Configure Password
        let passwordLabel = UILabel()
        passwordLabel.text = "New Password"
        view.addSubview(passwordLabel)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.topAnchor.constraint(equalTo: confirmationCode!.bottomAnchor, constant: view.bounds.height * 0.05).isActive = true
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
        password!.placeholder = "Confirmation Code"
        password!.backgroundColor = .orange
        
        // Configure Confirm Button
        updateButton = UIButton()
        view.addSubview(updateButton!)
        updateButton!.translatesAutoresizingMaskIntoConstraints = false
        updateButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height * -0.01).isActive = true
        updateButton!.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.05).isActive = true
        updateButton!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width * 0.05).isActive = true
        updateButton!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.bounds.width * -0.05).isActive = true
        updateButton!.setTitle("Update Button", for: .normal)
        updateButton!.backgroundColor = .gray
        updateButton!.addTarget(self, action: #selector(onUpdateButton), for: .touchUpInside)
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // Update Action
    @objc func onUpdateButton (sender: UITapGestureRecognizer) {
        guard let confirmationCodeValue = self.confirmationCode!.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Password Field Empty",
                                                    message: "Please enter a password of your choice.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue, password: self.password!.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        }
    }
    
}
