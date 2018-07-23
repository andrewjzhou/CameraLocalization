//
//  UpdatePhoneViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class UpdatePhoneViewController: PhoneViewController {

    let messageLabel = MessageLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        do {
            let phoneRaw = phoneNumberKit.format(try phoneNumberKit.parse(textField.text!), toType: .e164)
            
            if let user = AWSCognitoIdentityUserPool.default().currentUser() {
                // update in cognito
                cognitoUpdatePhoneNumber(phoneRaw) { [weak self] (success) in
                    if success {
                        // update phone in UserTable
                        AppSyncService.sharedInstance.updatePhone(username: user.username!,
                                                                  phone: phoneRaw,
                                                                  completion: { success in
                                                                    DispatchQueue.main.async {
                                                                        if success {
                                                                            // verify on success
                                                                            let verifyVC = VerifyPhoneViewController()
                                                                            verifyVC.user = user
                                                                            self?.navigationController?.pushViewController(verifyVC,
                                                                                                                           animated: true)
                                                                        } else {
                                                                            self?.messageLabel.display(.tryAgain)
                                                                            self?.button.isActive = true
                                                                        }
                                                                    }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self?.messageLabel.display(.tryAgain)
                            self?.button.isActive = true
                        }
                    }
                }
            }
            
        } catch {
            print("PhoneViewController: Error parsing phone number for raw string")
        }
        
        
    }
}
