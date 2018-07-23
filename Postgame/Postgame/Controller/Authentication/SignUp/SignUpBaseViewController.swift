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
import TextFieldEffects

class SignUpBaseViewController: UIViewController, UITextFieldDelegate {
    let disposeBag = DisposeBag()
    lazy var textField = IsaoTextField(frame: CGRect(x: view.bounds.width * 0.15,
                                                y: view.bounds.height * 0.1,
                                                width: view.bounds.width * 0.7,
                                                height: view.bounds.height * 0.075))
    let backButton = UIButton()
    let button = SubmitButton()
    
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
        setupBackButton()
        configureKeyboardDisplayAnimations()
        
        // Dismiss keyboard with tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
        if textField.text!.count != 0 {
            button.isActive = true
        }
    }
    
    // Tap to dismiss Keyboard
    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func setupInput() {
        view.addSubview(textField)
        textField.placeholder = "Placeholder"
        textField.activeColor = .flatSkyBlue
        textField.inactiveColor = .flatGrayDark
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = self
    }
    
    func setupBackButton() {
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.setImage(UIImage(named: "ic_baseline_keyboard_arrow_left_black_24pt"), for: .normal)
        backButton.backgroundColor = .clear
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setWidthConstraint(64)
        backButton.setHeightConstraint(64)
        backButton.setTopConstraint(equalTo: view.topAnchor, offset: 0.02 * UIScreen.main.bounds.height)
        backButton.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0.02 * UIScreen.main.bounds.width)
        backButton.tintColor = .flatGray
        backButton.rx.tap.bind {
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func backButtonAction() {
        introVC = nil
        self.navigationController?.popViewController(animated: true)
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
        
        button.rx.tap
            .filter { return self.buttonActionCondition() }
            .bind { self.buttonAction() }
            .disposed(by: disposeBag)
    }
    
    
    func buttonAction() { }
    
    func buttonActionCondition() -> Bool { return button.isActive }
    
    func configureKeyboardDisplayAnimations() {
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
                                    let transform = CGAffineTransform(translationX: 0, y: -(endFrame?.size.height ?? 0.0))
                                    button.transform = transform
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
                    },
                                   completion: nil)
                }
                
            }).disposed(by: disposeBag)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        button.sendActions(for: .touchUpInside)
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.introVC = nil
    }
}

final class SubmitButton: UIButton {
    var color = UIColor.flatRed
    var highlightedColor = UIColor.flatRedDark
    
    var isActive = false {
        didSet {
            backgroundColor = isActive ? color : .flatGray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .flatGray
    }
    
    override public var isHighlighted: Bool {
        didSet {
            if isActive {
                backgroundColor = isHighlighted ? highlightedColor : color
            } else {
                backgroundColor = isHighlighted ? UIColor.flatGrayDark : UIColor.flatGray
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
