//
//  SignUpInfoViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpBaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    let label = UILabel()
    let textField = UITextField()
    let button = UIButton()
    
    var introVC: IntroViewController?
    
    var signUpInfo = SignUpInfo()
    struct SignUpInfo {
        var username: String?
        var password: String?
        var email: String?
        var phone: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .flatWhite
        
        setupInput()
        setupButton()
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func setupInput() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setLeadingConstraint(equalTo: view.leadingAnchor, offset: UIScreen.main.bounds.width * 0.2)
        label.setTopConstraint(equalTo: view.topAnchor, offset: UIScreen.main.bounds.height * 0.18)
        label.setWidthConstraint(UIScreen.main.bounds.width * 0.5)
        label.text = "Username:"
        label.textColor = .flatBlack
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeadingConstraint(equalTo: label.leadingAnchor, offset: 0)
        textField.setTopConstraint(equalTo: label.bottomAnchor,
                                       offset: UIScreen.main.bounds.height * 0.025)
        textField.setTrailingConstraint(equalTo: view.trailingAnchor,
                                            offset: -UIScreen.main.bounds.width * 0.25)
        textField.contentVerticalAlignment = .bottom
        addUnderline(for: textField)
    }
    
    func setupButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        button.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        button.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        button.setHeightConstraint(UIScreen.main.bounds.height * 0.1)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Catatan Perjalanan", size: 25)
        button.titleLabel?.textColor = .flatWhite
        button.backgroundColor = .flatForestGreen
        
        button.rx.tap
            .filter { return self.buttonActionCondition() }
            .bind { self.buttonAction() }
            .disposed(by: disposeBag)
    }
    
    func buttonAction() { }
    
    func buttonActionCondition() -> Bool { return true }

}
