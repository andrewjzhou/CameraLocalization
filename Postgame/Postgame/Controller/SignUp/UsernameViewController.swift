//
//  UsernameViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSUserPoolsSignIn

class UsernameViewController: SignUpBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Username:"
        
        if let text = introVC?.signUpInfo.username {
            textField.text = text
        }
    }
    
    override func buttonAction() {
        
        checkUser(textField.text!) {[weak self] (notExist) in // check if
            if notExist {
                self?.introVC?.signUpInfo.username = self?.textField.text!
                
                let passwordVC = PasswordViewController()
                passwordVC.introVC = self?.introVC
                self?.navigationController?.pushViewController(passwordVC, animated: true)
            } else {
                let alertController = UIAlertController(title: "Username already exists.",
                                                        message: "",
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self?.present(alertController, animated: true, completion:  nil)
            }
        }

    }
    
    override func buttonActionCondition() -> Bool {
        // Check if username is too long
        if textField.text!.length > 15 {
            let alertController = UIAlertController(title: "Username is too long.",
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

func checkUser(_ loginName: String, completion: @escaping (Bool) -> Void) {
    let pool = AWSCognitoIdentityUserPool.default()
    let proposedUser = pool.getUser(loginName)
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    proposedUser.getSession(loginName, password: "", validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (awsTask) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let error = awsTask.error as? NSError {
            // Error implies login failed. Check reason for failure
            let exceptionString = error.userInfo["__type"] as! String
            if let exception = ExceptionString(rawValue: exceptionString) {
                switch exception {
                case .notAuthorizedException, .resourceConflictException:
                    // Account with this email does exist.
                    completion(false)
                default:
                    // Some other exception (e.g., UserNotFoundException). Allow user to proceed.
                    completion(true)
                }
            } else {
                // Some error we did not recognize. Optimistically allow user to proceed.
                completion(true)
            }
        } else {
            // No error implies login worked (edge case where proposed email
            // is linked with an account which has password 'deadbeef').
            completion(false)
        }
        return nil
    })
}
