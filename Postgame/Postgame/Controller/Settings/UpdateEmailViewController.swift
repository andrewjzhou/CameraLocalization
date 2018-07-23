//
//  UpdateEmailViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

final class UpdateEmailViewController: EmailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        button.backgroundColor = .flatRed
        button.setTitle("Update", for: .normal)
    }
    
    override func buttonAction() {
        view.endEditing(true)
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            // update UserTable
            AppSyncService.sharedInstance.updateEmail(username: username, email: textField.text!, completion: {result in
                print(result)
            })
            // update Cognito
            cognitoUpdateEmail(textField.text!)
            
            button.isUserInteractionEnabled = false
            button.backgroundColor = .flatWhiteDark
        }
      
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
