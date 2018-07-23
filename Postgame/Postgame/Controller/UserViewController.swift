//
//  UserViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserViewController: UIViewController {
    let menu = UserMenu()
    let countView = CountView()
    let disposeBag = DisposeBag()
//    let settingsView = UIView()
    
    let settingsVC: SettingsCollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        return SettingsCollectionViewController(collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        countView.refresh()
        
        blurBackground()
        
        let margin: CGFloat = 4
        
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.setTopConstraint(equalTo: view.topAnchor, offset: margin)
        containerView.setBottomConstraint(equalTo: view.bottomAnchor, offset: -margin)
        containerView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: margin)
        containerView.setTrailingConstraint(equalTo: view.trailingAnchor, offset: -margin)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 16
        
        containerView.addSubview(menu)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.setTopConstraint(equalTo: containerView.topAnchor, offset: 0)
        menu.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        menu.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        menu.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.1).isActive = true
        
       
        let navVC = UINavigationController(rootViewController: settingsVC)
        let navigationView = navVC.view!
        navVC.hidesNavigationBarHairline = true
        navVC.isNavigationBarHidden = true
        addChildViewController(navVC)
        containerView.addSubview(navigationView)
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.setTopConstraint(equalTo: menu.bottomAnchor, offset: 0)
        navigationView.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        navigationView.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        navigationView.setBottomConstraint(equalTo: containerView.bottomAnchor, offset: 0)
        
        containerView.addSubview(countView)
        countView.translatesAutoresizingMaskIntoConstraints = false
        countView.setTopConstraint(equalTo: menu.bottomAnchor, offset: 0)
        countView.setLeadingConstraint(equalTo: containerView.leadingAnchor, offset: 0)
        countView.setTrailingConstraint(equalTo: containerView.trailingAnchor, offset: 0)
        countView.setBottomConstraint(equalTo: containerView.bottomAnchor, offset: 0)
        
        menu.didSelectDriver.drive(onNext: { [countView, navigationView] (index) in
            switch index {
            case 0:
                containerView.bringSubview(toFront: countView)
            case 1:
                containerView.bringSubview(toFront: navigationView)
                countView.refresh()
            default:
                return
            }
        }).disposed(by: disposeBag)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleUserViewSwipe(sender:)))
        swipe.direction = .up
        containerView.addGestureRecognizer(swipe)
    }
    

    @objc func handleUserViewSwipe (sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func blurBackground() {
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView =  UIVisualEffectView(effect: blurEffect)
        
        // add vibrancy
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.contentView.addSubview(vibrancyView)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.setTopConstraint(equalTo: effectView.topAnchor, offset: 0)
        vibrancyView.setBottomConstraint(equalTo: effectView.bottomAnchor, offset: 0)
        vibrancyView.setLeadingConstraint(equalTo: effectView.leadingAnchor, offset: 0)
        vibrancyView.setTrailingConstraint(equalTo: effectView.trailingAnchor, offset: 0)
        
        // add blur
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.setTopConstraint(equalTo: view.topAnchor, offset: 0)
        effectView.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        effectView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        effectView.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
    }

}
