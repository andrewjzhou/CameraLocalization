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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitle("Update", for: .normal)
    }
    
    override func buttonAction() {
        do {
            let phoneRaw = phoneNumberKit.format(try phoneNumberKit.parse(textField.text!), toType: .e164)
            
            if let user = AWSCognitoIdentityUserPool.default().currentUser() {
                cognitoUpdatePhoneNumber(phoneRaw)
                AppSyncService.sharedInstance.updatePhone(username: user.username!, phone: phoneRaw)
                
                
                let verifyVC = VerifyPhoneViewController()
                verifyVC.user = user
                navigationController?.pushViewController(verifyVC, animated: true)
                
                view.endEditing(true)
                
            }
            
        } catch {
            print("PhoneViewController: Error parsing phone number for raw string")
        }
        
        
    }
}
