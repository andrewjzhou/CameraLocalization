//
//  UpdatePasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ResetPasswordViewController: SignUpBaseViewController {
    var user: AWSCognitoIdentityUser?
    let passwordField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.placeholder = "Confirmation Code"
        button.setBackgroundColor(.flatRed)
        button.setTitle("Reset Password", for: .normal)
        
        setupPasswordInput()
    }
    
    func setupPasswordInput() {
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setLeadingConstraint(equalTo: view.leadingAnchor, offset: UIScreen.main.bounds.width * 0.2)
        label.setTopConstraint(equalTo: view.topAnchor, offset: UIScreen.main.bounds.height * 0.35)
        label.setWidthConstraint(UIScreen.main.bounds.width * 0.25)
        label.text = "New Password:"
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
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
    }
    
    override func buttonAction() {
        guard let confirmationCodeValue = textField.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation Code Field Empty",
                                                    message: "",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        guard let newPassword = passwordField.text, !newPassword.isEmpty else {
            let alertController = UIAlertController(title: "Password Field Empty",
                                                    message: "",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue, password: newPassword).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
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
