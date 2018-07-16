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

        label.text = "Email:"
        if let text = introVC?.signUpInfo.email {
            textField.text = text
        }
    }
    
    override func buttonAction() {
        introVC?.signUpInfo.email = textField.text!
        
        let phoneVC = PhoneViewController()
        phoneVC.introVC = self.introVC
        self.navigationController?.pushViewController(phoneVC, animated: true)
    }
    
    override func buttonActionCondition() -> Bool {
        // set input field requirements
        return true
    }


}
