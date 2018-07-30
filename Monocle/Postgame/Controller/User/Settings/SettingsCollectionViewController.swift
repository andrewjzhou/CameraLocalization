//
//  SettingsCollectionViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/19/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import RxSwift

private let reuseIdentifier = "Cell"

final class SettingsCollectionViewController: UICollectionViewController {
    
    let UserProfileKeys: [String] = ["username",
                                     "name",
                                     "phone",
                                     "email",
                                     "password"]
    let didSelect: [UIViewController?] = [nil,
                                          UpdateNameViewController(),
                                          UpdatePhoneViewController(),
                                          UpdateEmailViewController(),
                                          UpdatePasswordViewController()]
    
    private let refreshPublisher = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 50, right: 0)
        
        super.init(collectionViewLayout: layout)
        
        // load data 
        refreshPublisher.asDriver(onErrorJustReturn: false).drive(onNext: { (toRefresh) in
            if toRefresh {
                UserCache.shared.cacheUserInfo(completion: { [weak self](error) in
                    DispatchQueue.main.async {
                        if error == nil {
                            self?.collectionView?.reloadData()
                        } else {
                            let alertController = UIAlertController(title: "Oops",
                                                                    message: "There was a problem loading your user information. Reload if you wish.",
                                                                    preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            let retryAction = UIAlertAction(title: "Reload", style: .default, handler: {(_) in
                                self?.refresh()
                            })
                            alertController.addAction(retryAction)
                            
                            self?.present(alertController, animated: true, completion:  nil)
                        }
                    }
                })
            }
        }).disposed(by: disposeBag)
        
        refresh()
    }
    
    func refresh() {
        refreshPublisher.onNext(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView!.register(UserProfileCell.self, forCellWithReuseIdentifier: UserProfileCell.reuseIdentifier)
        collectionView!.register(SignOutCell.self, forCellWithReuseIdentifier: SignOutCell.reuseIdentifier)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = .flatWhiteDark
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            return UserProfileKeys.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCell.reuseIdentifier, for: indexPath)
    
        if indexPath.section == 0 {
            if let cell = cell as? UserProfileCell {
                if indexPath.item == 0 {
                    cell.moreButton.isHidden = true
                } else {
                    cell.moreButton.isHidden = false
                }
                let attr = UserProfileKeys[indexPath.item]
                cell.keyLabel.text = attr
                
             cell.valueLabel.text = UserCache.shared[attr] as? String ?? ""
              
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: SignOutCell.reuseIdentifier, for: indexPath)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let vc = didSelect[indexPath.item] {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SignOutCell.reuseIdentifier, for: indexPath) as! SignOutCell
            cell.isHighlighted = true
            dismiss(animated: true) {
                AWSCognitoIdentityUserPool.default().currentUser()?.signOut()
                AWSCognitoIdentityUserPool.default().clearAll()
                AWSCognitoIdentityUserPool.default().currentUser()?.getDetails()
                cell.isHighlighted = false
            }
        }
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
     required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension SettingsCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0.08 * collectionView.bounds.height)

    }
}


final class UserProfileCell: UICollectionViewCell {
    static let reuseIdentifier = "UserProfileCell"
    
    let moreButton = UIButton()
    var keyLabel = UILabel()
    var valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .flatWhite
        
        
        // keyLabel
        contentView.addSubview(keyLabel)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.setLeadingConstraint(equalTo: contentView.leadingAnchor, offset: 0.02 * contentView.bounds.width)
        keyLabel.setWidthConstraint(0.3 * contentView.bounds.width)
        keyLabel.setHeightConstraint(contentView.bounds.height)
        keyLabel.setCenterYConstraint(equalTo: contentView.centerYAnchor, offset: 0)
        keyLabel.textColor = .flatBlack
        keyLabel.textAlignment = .left
        keyLabel.text = ""
        valueLabel.font = UIFont(name: "Montserrat-Regular", size: 17)
        
        // more button
        contentView.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(named: "baseline_arrow_forward_ios_white_24pt")!, for: .normal)
        moreButton.tintColor = .flatGrayDark
        moreButton.setWidthConstraint(0.5 * frame.height * 0.5)
        moreButton.setHeightConstraint(0.5 * frame.height * 0.5)
        moreButton.setTrailingConstraint(equalTo: contentView.trailingAnchor, offset: -0.02 * contentView.bounds.width)
        moreButton.setCenterYConstraint(equalTo: contentView.centerYAnchor, offset: 0)
        
        // valueLabel
        contentView.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.setTrailingConstraint(equalTo: moreButton.leadingAnchor, offset: -0.03 * contentView.bounds.width)
        valueLabel.setWidthConstraint(0.6 * contentView.bounds.width)
        valueLabel.setHeightConstraint(contentView.bounds.height)
        valueLabel.setCenterYConstraint(equalTo: contentView.centerYAnchor, offset: 0)
        valueLabel.textColor = .flatGrayDark
        valueLabel.textAlignment = .right
        valueLabel.text = ""
        valueLabel.font = UIFont(name: "Montserrat-Regular", size: 15)

    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class SignOutCell: UICollectionViewCell {
    static let reuseIdentifier = "SignOutCell"
    
    private let signOutButton = UILabel()
    
    override public var isHighlighted: Bool {
        didSet {
            signOutButton.backgroundColor = isHighlighted ? UIColor.flatBlack.withAlphaComponent(0.8) : UIColor.flatBlackDark.withAlphaComponent(0.9)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.clipsToBounds = true
        signOutButton.setCenterXConstraint(equalTo: contentView.centerXAnchor, offset: 0)
        signOutButton.setCenterYConstraint(equalTo: contentView.centerYAnchor, offset: 0)
        signOutButton.setWidthConstraint(contentView.bounds.width * 0.8)
        signOutButton.setHeightConstraint(contentView.bounds.height * 0.8)
        signOutButton.layer.cornerRadius = 8
        signOutButton.layer.borderColor = UIColor.flatWhite.cgColor
        signOutButton.layer.borderWidth = 1
        signOutButton.text = "Sign Out"
        signOutButton.font = UIFont(name: "Montserrat-Medium", size: 17)
        signOutButton.textAlignment = .center
        signOutButton.textColor = .flatWhite
        signOutButton.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.55)
      
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
