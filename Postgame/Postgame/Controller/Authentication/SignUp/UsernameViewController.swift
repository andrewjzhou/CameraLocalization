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
import RxSwift
import RxCocoa
import TextFieldEffects

final class UsernameViewController: SignUpBaseViewController {
    private let db = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.placeholder = "Username"
        
        if let text = introVC?.signUpInfo.username {
            textField.text = text
        }
        
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0)
        }.disposed(by: disposeBag)
    }
    
    override func buttonAction() {
        
        checkUser(textField.text!) {[weak self] (notExist) in // check if
            if notExist {
                self?.introVC?.signUpInfo.username = self?.textField.text!
                
                let passwordVC = PasswordViewController()
                passwordVC.introVC = self?.introVC
                self?.navigationController?.pushViewController(passwordVC, animated: true)
            } else {
                let alertController = UIAlertController(title: "Username Already Exists",
                                                        message: "",
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self?.present(alertController, animated: true, completion:  nil)
            }
        }

    }
    
    override func buttonActionCondition() -> Bool {
        if !button.isActive { return false }
        
        // Check if valid
        if !textField.text!.isValidUsername() {
            let alertController = UIAlertController(title: "Invalid Character(s)",
                                                    message: "Only alphabet, number, and underscore are allowed.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            
            self.present(alertController, animated: true, completion:  nil)
        }
        
        // Check if username is too long
        if textField.text!.length > 15 {
            alertTooLong()
            return false
        }
        
        if textField.text!.length == 0 {
            let alertController = UIAlertController(title: "Empty Field",
                                                    message: "",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            
            self.present(alertController, animated: true, completion:  nil)
        }
       return true
    }
    
    func alertTooLong() {
        let alertController = UIAlertController(title: "Username Is Too Long",
                                                message: "Maximum 15 characters.",
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
        alertController.addAction(retryAction)
        
        self.present(alertController, animated: true, completion:  nil)
    }
  

}

func checkUser(_ loginName: String, completion: @escaping (Bool) -> Void) {
    let pool = AWSCognitoIdentityUserPool.default()
    let proposedUser = pool.getUser(loginName)
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    proposedUser.getSession(loginName, password: "ThisIsAnIncorrectPassword", validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (awsTask) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let error = awsTask.error as NSError? {
            // Error implies login failed. Check reason for failure
            let exceptionString = error.userInfo["__type"] as! String
            if let exception = ExceptionString(rawValue: exceptionString) {
                switch exception {
                case .notAuthorizedException, .resourceConflictException:
                    // Account with this email does exist.
                    if proposedUser.confirmedStatus == AWSCognitoIdentityUserStatus.confirmed {
                        completion(true)
                    } else {
                         completion(false)
                    }
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
            // is linked with an account which has password 'ThisIsAnIncorrectPassword').
            if proposedUser.confirmedStatus == AWSCognitoIdentityUserStatus.confirmed {
                completion(true)
            } else {
                completion(false)
            }
        }
        return nil
    })
}

fileprivate extension String {
    func isValidUsername() -> Bool {
        // Minimum 8 characters at least 1 Alphabet and 1 Number
        let passwordRegex = "^[a-zA-Z0-9_-]*$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}
