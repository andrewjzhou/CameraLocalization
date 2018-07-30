//
//  ForgotPasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import RxSwift

final class ForgotPasswordViewController: SignUpBaseViewController {
    
    private let db = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        textField.placeholder = "Username"
        textField.activeColor = .flatRed
        button.setTitle("Next", for: .normal)
        
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = self.textField.text!.count != 0
            }.disposed(by: db)
    }
    
    override func buttonAction() {
        // Handle forgot password
        guard let username = textField.text, !username.isEmpty else {
            
            let alertController = UIAlertController(title: "Missing Username",
                                                    message: "Please enter a valid user name.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        let user = AWSCognitoIdentityUserPool.default().getUser(username)
        user.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    // Segue
                    let resetPasswordViewController = ResetPasswordViewController()
                    resetPasswordViewController.user = user
                    strongSelf.navigationController?.pushViewController(resetPasswordViewController, animated: true)
                }
            })
            return nil
        }
    }
    
    override func backButtonAction() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}
