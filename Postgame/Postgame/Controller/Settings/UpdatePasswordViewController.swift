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
                    } else {
                        self?.messageLabel.display(.passwordUpdated)
                    }
                    
                })
                return nil
            }
        }
    }

    override func backButtonAction() {
        dismiss(animated: true) {
            self.textField.text! = ""
            self.textField2.text! = ""
        }
    }

}
