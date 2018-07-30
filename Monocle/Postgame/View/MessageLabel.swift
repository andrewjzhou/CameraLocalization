//
//  MessageLabel.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/23/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

final class MessageLabel: UIView {
    
    private let label = UILabel()
    var message: Message = .nameUpdated {
        didSet {
            label.text = message.rawValue
        }
    }
    
    enum Message: String {
        case nameUpdated = "Name updated"
        case tryAgain = "Try again..."
        case phoneVerified = "Phone verified"
        case emailUpdated = "Email updated"
        case passwordUpdated = "Password updated"
        case savedToPhotos = "Saved to Photos"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.setTopConstraint(equalTo: topAnchor, offset: 0)
        effectView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        effectView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        effectView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        
        effectView.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTopConstraint(equalTo: effectView.contentView.topAnchor, offset: 0)
        label.setBottomConstraint(equalTo: effectView.contentView.bottomAnchor, offset: 0)
        label.setLeadingConstraint(equalTo: effectView.contentView.leadingAnchor, offset: 0)
        label.setTrailingConstraint(equalTo: effectView.contentView.trailingAnchor, offset: 0)
        label.textAlignment = .center
        label.textColor = .flatWhite
        label.font = UIFont(name: "Montserrat-Medium", size: 15)
    }
    
    func display(_ message: Message) {
        self.message = message
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0
                })
            })
        }
    }
    
    override func didMoveToSuperview() {
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
