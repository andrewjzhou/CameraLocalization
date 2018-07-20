//
//  UpdatePasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class UpdatePasswordViewController: UpdateNameViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.placeholder = "Current password"
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
       
        textField2.placeholder = "New password"
        textField2.isSecureTextEntry = true
        textField2.autocorrectionType = .no
        textField2.autocapitalizationType = .none
    }
    
    override func buttonAction() {
        if let user = AWSCognitoIdentityUserPool.default().currentUser() {
            user.changePassword(textField.text!, proposedPassword: textField2.text!).continueWith { [weak self ](task) -> Any? in
      
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                message: error.userInfo["message"] as? String,
                                                                preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        alertController.addAction(retryAction)
                        
                        self?.present(alertController, animated: true, completion:  nil)
                    } else if let result = task.result  {
                        let alertController = UIAlertController(title:"Password Update Success",
                                                                message: "",
                                                                preferredStyle: .alert)
                        let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(retryAction)
                        
                        self?.present(alertController, animated: true, completion:  {
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                    
                })
                return nil
            }
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
