//
//  ConfirmCodeViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import RxSwift

class ConfirmCodeViewController: SignUpBaseViewController {
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    
    private let db = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Confirmation Code: "
        button.setTitle("Confirm", for: .normal)
        button.backgroundColor = .flatRed
        
        // resend button
        let resend = UIButton()
        view.addSubview(resend)
        resend.translatesAutoresizingMaskIntoConstraints = false
        resend.setTitle("resend code", for: .normal)
        resend.setTitleColor(.flatBlue, for: .normal)
        resend.backgroundColor = .clear
        resend.setTopConstraint(equalTo: textField.bottomAnchor, offset: 0)
        resend.setTrailingConstraint(equalTo: textField.trailingAnchor, offset: 0)
        resend.setWidthConstraint(0.4 * UIScreen.main.bounds.width)
        resend.rx.tap.bind {
            self.resendConfirmationCode()
        }.disposed(by: db)
    }
    
    override func buttonAction() {
        guard let confirmationCodeValue = textField.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation code missing.",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user?.confirmSignUp(textField.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    print("Confirmed Sign up")
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    
                    // Register user in database
                    
                }
            })
            return nil
        }
    }
    
    func resendConfirmationCode() {
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Resent",
                                                            message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }

}
