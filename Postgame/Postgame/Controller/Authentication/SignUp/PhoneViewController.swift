//
//  PhoneViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import RxSwift
import RxCocoa
import PhoneNumberKit
import TextFieldEffects

class PhoneViewController: SignUpBaseViewController {
    let pool = AWSCognitoIdentityUserPool.default()
    var sentTo: String?
    
    let db = DisposeBag()
    let phoneNumberKit = PhoneNumberKit()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let text = introVC?.signUpInfo.phone {
            textField.text = text
        }
        
        textField.placeholder = "Phone"
        textField.keyboardType = .phonePad
        
        button.color = .flatForestGreen
        button.highlightedColor = .flatForestGreenDark
        button.setTitle("Sign Up", for: .normal)

        
        let formatter = PartialFormatter()
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0)
            self.textField.text =  formatter.formatPartial(self.textField.text!)
        }.disposed(by: db)
    }
    
    override func buttonAction() {
        do {
            let phoneRaw = phoneNumberKit.format(try phoneNumberKit.parse(textField.text!), toType: .e164)
            introVC?.signUpInfo.phone = phoneRaw
        }
        catch {
            print("PhoneViewController: Error parsing phone number for raw string")
        }
        
        guard let signUpInfo = introVC?.signUpInfo else { return }
      
        guard let userNameValue = signUpInfo.username, !userNameValue.isEmpty,
            let passwordValue = signUpInfo.password, !passwordValue.isEmpty else {
                let alertController = UIAlertController(title: "Missing Required Fields",
                                                        message: "Username / Password are required for registration.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
        }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let phoneValue = signUpInfo.phone, !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = phoneValue
            attributes.append(phone!)
        }
        
        if let emailValue = signUpInfo.email, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        // Assume verified or else cannot reset password
//        let emailVerified = AWSCognitoIdentityUserAttributeType()
//        emailVerified?.name = "email_verified"
//        emailVerified?.value = "true"
//        attributes.append(emailVerified!)
//        let phoneVerified = AWSCognitoIdentityUserAttributeType()
//        phoneVerified?.name = "phone_verified"
//        phoneVerified?.value = "true"
//        attributes.append(phoneVerified!)
        
        //sign up the user
        pool.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    print("System is signing up new user")
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        let confirmVC = ConfirmCodeViewController()
                        confirmVC.introVC = self?.introVC
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        confirmVC.sentTo = strongSelf.sentTo
                        confirmVC.user = strongSelf.pool.getUser(signUpInfo.username!)
                        
                        
                        self?.navigationController?.pushViewController(confirmVC, animated: true)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            return nil
        }
    }
    
    override func buttonActionCondition() -> Bool {
        if !button.isActive { return false }
        
        do {
            let _ = try phoneNumberKit.parse(textField.text!, withRegion: "US", ignoreType: true)
            return true
        }
        catch {
            let alertController = UIAlertController(title: "Phone Number",
                                                    message: "Incorrect.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return false
        }
    }


}
