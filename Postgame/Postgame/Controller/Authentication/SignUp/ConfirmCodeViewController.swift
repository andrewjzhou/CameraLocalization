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
    let resendButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.placeholder = "Confirmation Code"
        button.setTitle("Confirm", for: .normal)
        button.backgroundColor = .flatRed
        
        setupResendButton()
        
        backButton.isHidden = true
    }
    
    func setupResendButton() {
        view.addSubview(resendButton)
        let rbWidth = UIScreen.main.bounds.width * 0.35
        let rbHeight = UIScreen.main.bounds.height * 0.05
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        resendButton.setWidthConstraint(rbWidth)
        resendButton.setHeightConstraint(rbHeight)
        resendButton.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        resendButton.setBottomConstraint(equalTo: button.topAnchor, offset: -0.05 * UIScreen.main.bounds.height)
        resendButton.layer.cornerRadius = 0.12 * rbWidth
        resendButton.setTitle("Resend Code", for: .normal)
        resendButton.backgroundColor = .flatGray
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        resendButton.titleLabel?.textColor = .flatWhite
        resendButton.rx.tap.bind {
            self.resendConfirmationCode()
        }.disposed(by: disposeBag)
    }
    
    override func backButtonAction() {
         self.navigationController?.popToRootViewController(animated: true)
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
    
    override func configureKeyboardDisplayAnimations() {
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [button, resendButton](notification) in
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
                                    let transform = CGAffineTransform(translationX: 0, y: -(endFrame?.size.height ?? 0.0))
                                    button.transform = transform
                                    resendButton.transform = transform
                    },
                                   completion: nil)
                }
            }).disposed(by: db)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [button, resendButton](notification) in
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
                                    resendButton.transform = .identity
                    },
                                   completion: nil)
                }
                
            }).disposed(by: db)
    }

    
}
