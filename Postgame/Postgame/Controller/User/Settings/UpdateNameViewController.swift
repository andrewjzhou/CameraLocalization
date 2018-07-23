//
//  UpdateNameViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import TextFieldEffects
import AWSUserPoolsSignIn
import RxSwift

class UpdateNameViewController: SignUpBaseViewController {

    private let db = DisposeBag()
    private var buttonsShouldReactToKeyboard = false
    let textField2 = IsaoTextField()
    
    let messageLabel = MessageLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure top textField
        textField.placeholder = "First name"
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .words
        
        // configure bottom textField
        view.addSubview(textField2)
        textField2.placeholder = "Last name"
        textField2.activeColor = .flatSkyBlue
        textField2.inactiveColor = .flatGrayDark
        textField2.autocapitalizationType = .words
        textField2.delegate = self
        textField2.translatesAutoresizingMaskIntoConstraints = false
        textField2.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        textField2.setTopConstraint(equalTo: view.topAnchor, offset: view.bounds.height * 0.25)
        textField2.setWidthConstraint(view.bounds.width * 0.7)
        textField2.setHeightConstraint(view.bounds.height * 0.075)
    
        // configure button
        button.color = .flatRed
        button.highlightedColor = .flatRedDark
        button.setTitle("Update", for: .normal)
        
        // button becomes active when both textFields are written in
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0 && self.textField2.text!.count != 0)
            }.disposed(by: db)
        
        textField2.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0 && self.textField2.text!.count != 0)
            }.disposed(by: db)
        
        // configure message label
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        messageLabel.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.15 * view.bounds.height)
        messageLabel.setWidthConstraint(view.bounds.width * 0.45)
        messageLabel.setHeightConstraint(view.bounds.height * 0.06)
        messageLabel.layer.cornerRadius = 12
    }
    
    @objc override func dismissKeyboard(_: UITapGestureRecognizer) {
        buttonsShouldReactToKeyboard = true
        view.endEditing(true)
    }
    
    override func buttonAction() {
        buttonsShouldReactToKeyboard = true
        view.endEditing(true)
        button.isActive = false
        let first = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = textField2.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = first + " " + last
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            AppSyncService.sharedInstance.updateName(username: username, name: name) { [messageLabel, button] (success) in
                if success {
                    messageLabel.display(.nameUpdated)
                    UserCache.shared["name"] = name as AnyObject
                } else {
                    messageLabel.display(.tryAgain)
                    button.isActive = true
                }
            }
            
        }
        
    }
    
    override func buttonActionCondition() -> Bool {
        if !button.isActive { return false }
        if textField.text?.count == 0 || textField2.text?.count == 0 {
            let alertController = UIAlertController(title: "Empty Field(s)",
                                                    message: "",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(retryAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return false
        }
        
        return true
    }
    
    override func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
        textField.text = ""
        textField2.text = ""
        
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField {
            buttonsShouldReactToKeyboard = false
            textField.resignFirstResponder()
            textField2.becomeFirstResponder()
        } else if textField == self.textField2 {
            buttonsShouldReactToKeyboard = true
            textField2.resignFirstResponder()
            button.sendActions(for: .touchUpInside)
        }
        
        return true
    }
    
    override func configureKeyboardDisplayAnimations() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [button](notification) in
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
            .subscribe(onNext: { [weak self](notification) in
                if self == nil { return }
                if self!.buttonsShouldReactToKeyboard {
                    if let userInfo = notification.userInfo {
                        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                        UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: {
                                        self?.button.transform = .identity
                                        self?.button.layer.cornerRadius = 0
                                        
                        },
                                       completion: nil)
                    }
                }
            }).disposed(by: disposeBag)
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
