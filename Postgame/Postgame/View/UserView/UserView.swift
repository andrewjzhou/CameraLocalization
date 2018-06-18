//
//  UserView.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/26/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import RxSwift

class UserView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var menu: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let countView = CountView()
    
    let cellId = "userInfoCellId"
    
    private let signOutPublisher = PublishSubject<Any>()
    
    private(set) var signOutObservable: Observable<Any>
    
    init() {
        signOutObservable = signOutPublisher.asObservable()
        
        super.init(frame: .zero)
        
        // User Info
        self.backgroundColor = .black
        self.alpha = 0.9
        
        menu.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        addSubview(menu)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.topAnchor.constraint(equalTo: self.topAnchor, constant: UIScreen.main.bounds.height * 0.13).isActive = true
        menu.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: UIScreen.main.bounds.height * -0.13).isActive = true
        menu.leftAnchor.constraint(equalTo: self.leftAnchor, constant: UIScreen.main.bounds.width * 0.13).isActive = true
        menu.rightAnchor.constraint(equalTo: self.rightAnchor, constant: UIScreen.main.bounds.width * -0.13).isActive = true
        menu.backgroundColor = .clear
        
        addSubview(countView)
        countView.translatesAutoresizingMaskIntoConstraints = false
        countView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIScreen.main.bounds.height * 0.13).isActive = true
        countView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: UIScreen.main.bounds.height * -0.13).isActive = true
        countView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: UIScreen.main.bounds.width * 0.13).isActive = true
        countView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: UIScreen.main.bounds.width * -0.13).isActive = true
        countView.backgroundColor = .clear
        countView.alpha = 0
    }
    
    override func didMoveToSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else {return}
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            // Reload countView and show
            countView.refresh()
            UIView.animate(withDuration: 0.5) {
                self.countView.alpha = 1
            }
        case 1:
            // Change password
            print("1")
        case 2:
            // SignOut
            signOutPublisher.onCompleted()
        default:
            break
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        switch indexPath.row{
        case 0:
            cell.label.text = "Views"
        case 1:
            cell.label.text = "Change Password"
        case 2:
            cell.label.text = "Sign Out"
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = menu.bounds.width
        let height = menu.bounds.height * 0.2
        return CGSize.init(width: width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuCell: UICollectionViewCell {
    var label = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .yellow
        
        label.textColor = .black
        
        contentView.addSubview(label)
        contentView.addConstraintsWithFormat("H:|-10-[v0]|", views: label)
        contentView.addConstraintsWithFormat("V:|[v0]|", views: label)
        
        contentView.layer.cornerRadius = self.bounds.width * 0.1
        contentView.layer.borderWidth = self.bounds.height * 0.3
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
