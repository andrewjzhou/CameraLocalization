//
//  CountView.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/26/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import RxSwift

class CountView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "countCellId"
    
    var urls = [String]()
    var counts = [Int]()
    
    lazy var list: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        list.dataSource = self
        list.delegate = self
        list.register(CountCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(list)
        addConstraintsWithFormat("H:|[v0]|", views: list)
        addConstraintsWithFormat("V:|[v0]|", views: list)
        
        refresh()
    }
    
    // Not best practice. Fix in future
    func refresh() {
        urls.removeAll()
        counts.removeAll()
        
        if let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username {
            let _ = DynamoDBService.sharedInstance.usernameQuery(username)
                .subscribe(onNext: { (posts) in
                    for post in posts {
                        self.urls.append(post._key!)
                        self.counts.append(Int(post._view_count!))
                    }
                }, onCompleted: {
                    DispatchQueue.main.sync {
                        self.list.reloadData()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CountCell
        
        cell.name.text = urls[indexPath.row]
        cell.count.text = String(counts[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.bounds.width
        let height = self.bounds.height * 0.06
        return CGSize.init(width: width, height: height)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CountCell: UICollectionViewCell {
    var name = UILabel()
    var count = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .yellow
        
        name.textColor = .black
        count.textColor = .black
        
        contentView.addSubview(name)
        contentView.addSubview(count)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.setHeightConstraint(self.bounds.height)
        name.setWidthConstraint(self.bounds.width * 0.5)
        name.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: self.leftAnchor, constant: UIScreen.main.bounds.width * 0.13).isActive = true
        
        count.translatesAutoresizingMaskIntoConstraints = false
        count.setHeightConstraint(self.bounds.height)
        count.setWidthConstraint(self.bounds.width * 0.1)
        count.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        count.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: self.rightAnchor, constant: UIScreen.main.bounds.width * -0.13).isActive = true
        
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 2
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

fileprivate let disposeBag = DisposeBag()
