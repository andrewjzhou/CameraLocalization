//
//  VerificationModalPhoneViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/26/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import TextFieldEffects
import AWSCognitoIdentityProvider
import RxSwift
import RxCocoa
import PhoneNumberKit


final class VerificationModalPhoneViewController: UIViewController, UITextFieldDelegate {
    
    let textField = IsaoTextField()
    let disposeBag = DisposeBag()
    let button = SubmitButton()
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIButton()
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setWidthConstraint(56)
        closeButton.setHeightConstraint(56)
        closeButton.setTopConstraint(equalTo: view.topAnchor, offset: 4)
        closeButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 4)
        closeButton.setImage(UIImage(named: "ic_close")!, for: .normal)
        closeButton.backgroundColor = .flatWhite
        closeButton.tintColor = .flatGray
        closeButton.rx.tap.bind {
            self.closeButtonAction()
        }
        
        let instructionLabel = UILabel()
        view.addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        instructionLabel.setTopConstraint(equalTo: closeButton.bottomAnchor, offset: 0.01 * view.bounds.height)
        instructionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
        instructionLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        instructionLabel.textColor = .flatBlack
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 2
        instructionLabel.font = UIFont.systemFont(ofSize: 12)
        instructionLabel.text = "You must verify your phone number\n Enter your phone number then press next"
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Phone"
        textField.activeColor = .flatSkyBlue
        textField.inactiveColor = .flatGrayDark
        textField.keyboardType = .phonePad
        textField.delegate = self
        textField.setTopConstraint(equalTo: instructionLabel.topAnchor, offset: view.bounds.height * 0.1)
        textField.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        textField.setHeightConstraint(view.bounds.height * 0.075)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        button.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        button.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        button.setHeightConstraint(UIScreen.main.bounds.height * 0.08)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Catatan Perjalanan", size: 25)
        button.titleLabel?.textColor = .flatWhite
        button.rx.tap.bind{
            self.buttonAction()
        }
        
        let formatter = PartialFormatter()
        textField.rx.controlEvent([.editingChanged]).bind {
            self.button.isActive = (self.textField.text!.count != 0)
            self.textField.text =  formatter.formatPartial(self.textField.text!)
            }.disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    private func buttonAction() {
        view.endEditing(true)
        button.isActive = false
        do {
            let phoneRaw = phoneNumberKit.format(try phoneNumberKit.parse(textField.text!), toType: .e164)
            if let user = AWSCognitoIdentityUserPool.default().currentUser() {
                // update in cognito
                cognitoUpdatePhoneNumber(phoneRaw) { [weak self] (success) in
                    if success {
                        // update phone in UserTable
                        AppSyncService.sharedInstance.updatePhone(username: user.username!,
                                                                  phone: phoneRaw,
                                                                  completion: { success in
                                                                    DispatchQueue.main.async {
                                                                        if success {
                                                                            UserCache.shared[UserCacheKey.phone.rawValue] = phoneRaw as AnyObject
                                                                            // verify on success
                                                                            let verifyVC = VerificationModalConfirmationCodeViewController()
                                                                            verifyVC.user = user
                                                                            self?.navigationController?.pushViewController(verifyVC,
                                                                                                                           animated: true)
                                                                        } else {
                                                                            self?.tryAgainAlert()
                                                                            self?.button.isActive = true
                                                                        }
                                                                    }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self?.tryAgainAlert()
                            self?.button.isActive = true
                        }
                    }
                }
            }
            
        } catch {
            print("PhoneViewController: Error parsing phone number for raw string")
        }
    }
    
    private func tryAgainAlert() {
        let alertController = UIAlertController(title: "Try Again",
                                                message: "",
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(retryAction)
        
        self.present(alertController, animated: true, completion:  nil)
    }
    
    private func closeButtonAction() {
        let alertController = UIAlertController(title: "Sure?",
                                                message: "You must verify your phone to use Monocle.",
                                                preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: {
                AWSCognitoIdentityUserPool.default().currentUser()?.signOut()
                AWSCognitoIdentityUserPool.default().clearAll()
                AWSCognitoIdentityUserPool.default().currentUser()?.getDetails()
            })
        })
        alertController.addAction(logOutAction)
        let retryAction = UIAlertAction(title: "Resume", style: .default, handler: nil)
        alertController.addAction(retryAction)
        
        self.present(alertController, animated: true, completion:  nil)
    }
}

