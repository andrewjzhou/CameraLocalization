//
//  VerificationModalConfirmationCodeViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/26/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

final class VerificationModalConfirmationCodeViewController: VerifyPhoneViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resendButton.setTitle("Send Code", for: .normal)
    }
    
    override func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
        textField.text = ""
    }
    
    override func buttonAction() {
        view.endEditing(true)
        button.isActive = false
        guard let currUser = AWSCognitoIdentityUserPool.default().currentUser() else {
            button.isActive = true
            messageLabel.display(.tryAgain)
            return
        }
        currUser.verifyAttribute("phone_number", code: textField.text!).continueWith(block: { [messageLabel, button] (task) -> Any? in
            DispatchQueue.main.async {
                print("verifying")
                if let _ = task.error {
                    button.isActive = true
                    messageLabel.display(.tryAgain)
                } else {
                     self.dismiss(animated: true, completion: nil)
                }
                
            }
            return nil
        })
    }
    
    override func resendConfirmationCode() {
        print("should be sent")
        user?.getAttributeVerificationCode("phone_number")
    }
    

    
    override func configureKeyboardDisplayAnimations() {}

}
