//
//  UserView.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/26/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import RxSwift

class UserView: UIView {
    let menu = UserMenu()
    let countView = CountView()
    let settingsView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let margin: CGFloat = 4
        
        let backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.setTopConstraint(equalTo: topAnchor, offset: 0)
        backgroundView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        backgroundView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        backgroundView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let containerView = UIView()
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.setTopConstraint(equalTo: topAnchor, offset: margin)
        containerView.setBottomConstraint(equalTo: bottomAnchor, offset: -margin)
        containerView.setLeadingConstraint(equalTo: leadingAnchor, offset: margin)
        containerView.setTrailingConstraint(equalTo: trailingAnchor, offset: -margin)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 16
        
        containerView.addSubview(menu)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.setTopConstraint(equalTo: containerView.topAnchor, offset: 0)
        menu.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        menu.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        menu.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.1).isActive = true
        
        containerView.addSubview(settingsView)
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.setTopConstraint(equalTo: menu.bottomAnchor, offset: 0)
        settingsView.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        settingsView.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        settingsView.setBottomConstraint(equalTo: containerView.bottomAnchor, offset: 0)
        settingsView.backgroundColor = UIColor.flatPlum.withAlphaComponent(0.7)
        
        containerView.addSubview(countView)
        countView.translatesAutoresizingMaskIntoConstraints = false
        countView.setTopConstraint(equalTo: menu.bottomAnchor, offset: 0)
        countView.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        countView.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        countView.setBottomConstraint(equalTo: containerView.bottomAnchor, offset: 0)
        
        menu.didSelectDriver.drive(onNext: { (index) in
            switch index {
            case 0:
                containerView.bringSubview(toFront: self.countView)
            case 1:
                containerView.bringSubview(toFront: self.settingsView)
                self.countView.refresh()
            default:
                return
            }
        }).disposed(by: disposeBag)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate let disposeBag = DisposeBag()
