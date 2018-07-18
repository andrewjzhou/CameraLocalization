//
//  PasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class PasswordViewController: SignUpBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.placeholder = "Password"
        
        if let text = introVC?.signUpInfo.password {
            textField.text = text
        }
        
        textField.isSecureTextEntry = true
    }
    
    override func buttonAction() {
        introVC?.signUpInfo.password = textField.text!
        
        let emailVC = EmailViewController()
        emailVC.introVC = self.introVC
        self.navigationController?.pushViewController(emailVC, animated: true)
    }
    
    override func buttonActionCondition() -> Bool {
        if !textField.text!.isValidPassword() {
            let alertController = UIAlertController(title: "Invalid Password.",
                                                    message: "Minimum 8 characters\n At least 1 Lowercase Alphabet\n At least 1 Number",
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
    func isValidPassword() -> Bool {
        // Minimum 8 characters at least 1 Alphabet and 1 Number
        let passwordRegex = "^(?=.*[a-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}
