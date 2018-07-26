//
//  UpdatePasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class UpdatePasswordViewController: UpdateNameViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.placeholder = "Current password"
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
       
        textField2.placeholder = "New password"
        textField2.isSecureTextEntry = true
        textField2.autocorrectionType = .no
        textField2.autocapitalizationType = .none
    }
    
    override func buttonAction() {
        button.isActive = false
        if let user = AWSCognitoIdentityUserPool.default().currentUser() {
            user.changePassword(textField.text!, proposedPassword: textField2.text!).continueWith { [weak self ](task) -> Any? in
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                message: error.userInfo["message"] as? String,
                                                                preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        alertController.addAction(retryAction)
                        self?.present(alertController, animated: true, completion:  nil)
                         self?.button.isActive = true
                    } else {
                        self?.messageLabel.display(.passwordUpdated)
                    }
                    
                })
                return nil
            }
        } else {
            let alertController = UIAlertController(title: "Oops",
                                                    message: "Something went wrong. Please try again. We apologize for the inconvenience.",
                                                    preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Exit", style: .cancel, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(exitAction)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            present(alertController, animated: true, completion:  nil)
            button.isActive = true
        }
    }

}
