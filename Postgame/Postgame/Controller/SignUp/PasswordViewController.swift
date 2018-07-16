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

        label.text = "Password:"
        
        if let text = introVC?.signUpInfo.password {
            textField.text = text
        }
    }
    
    override func buttonAction() {
        introVC?.signUpInfo.password = textField.text!
        
        let emailVC = EmailViewController()
        emailVC.introVC = self.introVC
        self.navigationController?.pushViewController(emailVC, animated: true)
    }
    
    override func buttonActionCondition() -> Bool {
        // set input field requirements
        return true
    }
    
    

}
