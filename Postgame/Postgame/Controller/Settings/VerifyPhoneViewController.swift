//
//  VerifyPhoneViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class VerifyPhoneViewController: ConfirmCodeViewController {
    
    let messageLabel = MessageLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        button.isActive = false
        user?.verifyAttribute("phone_number", code: textField.text!).continueWith(block: { [messageLabel, button] (task) -> Any? in
            DispatchQueue.main.async {
                if let _ = task.error {
                    button.isActive = true
                    messageLabel.display(.tryAgain)
                }
        
                messageLabel.display(.phoneVerified)
            }
            return nil
        })
    }
    
    override func resendConfirmationCode() {
        user?.getAttributeVerificationCode("phone_number")
    }
}
