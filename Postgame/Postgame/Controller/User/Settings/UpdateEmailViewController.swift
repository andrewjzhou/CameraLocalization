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
    
    let messageLabel = MessageLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.keyboardType = .emailAddress
        button.setTitle("Update", for: .normal)
        
        // configure message label
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        messageLabel.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.15 * view.bounds.height)
        messageLabel.setWidthConstraint(view.bounds.width * 0.45)
        messageLabel.setHeightConstraint(view.bounds.height * 0.06)
        messageLabel.layer.cornerRadius = 12
    }
    
    override func buttonAction() {
        view.endEditing(true)
        button.isActive = false
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            let email = textField.text!
            // update UserTable
            cognitoUpdateEmail(email,
                               completion: {[messageLabel, button] success in
                                if success {
                                    // update cognito
                                    AppSyncService.sharedInstance.updateEmail(username: username,
                                                                              email: email,
                                                                              completion: { (success) in
                                                                                DispatchQueue.main.async {
                                                                                    if success {
                                                                                        messageLabel.display(.emailUpdated)
                                                                                        UserCache.shared["email"] = email as AnyObject
                                                                                    }
                                                                                    else {
                                                                                        messageLabel.display(.tryAgain)
                                                                                        button.isActive = true
                                                                                    }
                                                                                }
                                    })
                                } else {
                                    DispatchQueue.main.async {
                                        messageLabel.display(.tryAgain)
                                        button.isActive = true
                                    }
                                }
            })
            
            button.backgroundColor = .flatWhiteDark
        }
      
    }
    
    override func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
        textField.text = ""
    }
    
    override func configureKeyboardDisplayAnimations() {
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [button] (notification) in
                if let userInfo = notification.userInfo {
                    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                    let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: {
                                    let translation = CGAffineTransform(translationX: 0, y: -(endFrame?.size.height ?? 0.0))
                                    let scale = CGAffineTransform(scaleX: 0.8, y: 0.9)
                                    button.transform = translation.concatenating(scale)
                                    button.layer.cornerRadius = 10.0
                    },
                                   completion: nil)
                }
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [button] (notification) in
                if let userInfo = notification.userInfo {
                    let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: {
                                    button.transform = .identity
                                     button.layer.cornerRadius = 0
                    },
                                   completion: nil)
                }
                
            }).disposed(by: disposeBag)
    }

}
