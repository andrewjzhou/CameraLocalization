//
//  UsernameViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class UsernameViewController: SignUpBaseViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Username:"
        
        if let text = introVC?.signUpInfo.username {
            textField.text = text
        }
    }
    
    override func buttonAction() {
        introVC?.signUpInfo.username = textField.text!
        
        let passwordVC = PasswordViewController()
        passwordVC.introVC = self.introVC
        self.navigationController?.pushViewController(passwordVC, animated: true)
    }
    
    override func buttonActionCondition() -> Bool {
        // set input field requirements 
        return true
    }
   

}
