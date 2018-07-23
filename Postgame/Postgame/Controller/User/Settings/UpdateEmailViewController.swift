//
//  UpdateEmailViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

final class UpdateEmailViewController: EmailViewController {
    
    let messageLabel = MessageLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.keyboardType = .emailAddress
        button.setTitle("Update", for: .normal)
        
        // configure message label
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        messageLabel.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.15 * view.bounds.height)
        messageLabel.setWidthConstraint(view.bounds.width * 0.45)
        messageLabel.setHeightConstraint(view.bounds.height * 0.06)
        messageLabel.layer.cornerRadius = 12
    }
    
    override func buttonAction() {
        view.endEditing(true)
        button.isActive = false
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            let email = textField.text!
            // update UserTable
            cognitoUpdateEmail(email,
                               completion: {[messageLabel, button] success in
                                if success {
                                    // update cognito
                                    AppSyncService.sharedInstance.updateEmail(username: username,
                                                                              email: email,
                                                                              completion: { (success) in
                                                                                DispatchQueue.main.async {
                                                                                    if success {
                                                                                        messageLabel.display(.emailUpdated)
                                                                                    }
                                                                                    else {
                                                                                        messageLabel.display(.tryAgain)
                                                                                        button.isActive = true
                                                                                    }
                                                                                }
                                    })
                                } else {
                                    DispatchQueue.main.async {
                                        messageLabel.display(.tryAgain)
                                        button.isActive = true
                                    }
                                }
            })
            
            button.backgroundColor = .flatWhiteDark
        }
      
    }
    
    override func backButtonAction() {
        dismiss(animated: true) {
            self.textField.text! = ""
        }
    }

}
