//
//  UpdatePasswordViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import TextFieldEffects

final class ResetPasswordViewController: SignUpBaseViewController {
    var user: AWSCognitoIdentityUser?
    var passwordField = IsaoTextField(frame: CGRect(x: UIScreen.main.bounds.width * 0.15,
                                                    y: UIScreen.main.bounds.height * 0.25,
                                                    width: UIScreen.main.bounds.width * 0.7,
                                                    height: UIScreen.main.bounds.height * 0.075))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.placeholder = "Confirmation Code"
        textField.keyboardType = .numberPad
        button.setTitle("Reset Password", for: .normal)
        
        setupPasswordInput()
        
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0 && self.passwordField.text!.count != 0)
            }.disposed(by: disposeBag)
        
        passwordField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0 && self.passwordField.text!.count != 0)
            }.disposed(by: disposeBag)
    }
    
    func setupPasswordInput() {
        view.addSubview(passwordField)
        passwordField.placeholder = "Password"
        passwordField.activeColor = .flatSkyBlue
        passwordField.inactiveColor = .flatGrayDark
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
    }
    
    override func buttonAction() {
        button.isActive = false
        guard let confirmationCodeValue = textField.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation Code Is Missing",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            button.isActive = true
            return
        }
        
        guard let newPassword = passwordField.text, !newPassword.isEmpty else {
            let alertController = UIAlertController(title: "Password Field Empty",
                                                    message: "",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
             button.isActive = true
            return
        }
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue, password: newPassword).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {
                self?.button.isActive = true
                return nil
            }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                    self?.button.isActive = true
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        }
    }
   

}
