//
//  VerifyPhoneViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class VerifyPhoneViewController: ConfirmCodeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func buttonAction() {
        user?.verifyAttribute("phone_number", code: textField.text!)
    }
    
    override func resendConfirmationCode() {
        user?.getAttributeVerificationCode("phone_number")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
