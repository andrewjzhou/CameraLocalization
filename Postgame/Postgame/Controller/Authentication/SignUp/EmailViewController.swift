//
//  EmailViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class EmailViewController: SignUpBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress

        if let text = introVC?.signUpInfo.email {
            textField.text = text
        }
        
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0)
            }.disposed(by: disposeBag)
    }
    
    override func buttonAction() {
        checkUser(textField.text!) {[weak self] (notExist) in // only work if i change current user pool to must have email login
            if self == nil { return }
            if notExist {
                self!.introVC?.signUpInfo.email = self!.textField.text!
                
                let phoneVC = PhoneViewController()
                phoneVC.introVC = self!.introVC
                self!.navigationController?.pushViewController(phoneVC, animated: true)
            } else {
                let alertController = UIAlertController(title: "Email Taken",
                                                        message: "Email you entered is used for another account.",
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self!.present(alertController, animated: true, completion:  nil)
            }
        }
    }
    
    override func buttonActionCondition() -> Bool {
        if !textField.text!.isValidEmail() {
            let alertController = UIAlertController(title: "Invalid Email",
                                                    message: "",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return false
        }
        return true
    }


}

fileprivate extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
