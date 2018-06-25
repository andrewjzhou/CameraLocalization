//
//  TopView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/25/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

class TopView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let titleLabel = UILabel()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.red
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
    
    var topTitles = [String]()
    var topViews = [Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setTopConstraint(equalTo: topAnchor, offset: 0)
        titleLabel.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        titleLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        titleLabel.setHeightConstraint(32)
        titleLabel.textAlignment = .center
        titleLabel.text = "Top 5 : "
        
        addSubview(collectionView)
        collectionView.register(TopViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.setTopConstraint(equalTo: titleLabel.bottomAnchor, offset: 0)
        collectionView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        collectionView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        collectionView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        collectionView.isScrollEnabled = false
        
        titleLabel.backgroundColor = UIColor.flatMint
        collectionView.backgroundColor = UIColor.flatSand
    
    }
    

    // CollectionView Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopViewCell
        
        cell.imageView.image = UIImage(named: "ic_camera_alt")?.withRenderingMode(.alwaysTemplate)
        cell.tintColor = UIColor.green
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("TopView: frame heigeht is \(frame.height)")
        print("TopView: cv frame height is \(collectionView.frame.height)")
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TopViewCell: BaseCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let numberLabel = UILabel()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLeadingConstraint(equalTo: leadingAnchor, offset: 5)
        imageView.setTopConstraint(equalTo: topAnchor, offset: 5)
        imageView.setBottomConstraint(equalTo: bottomAnchor, offset: 5)
        imageView.setWidthConstraint(frame.height - 10)
        
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 5)
        numberLabel.setTopConstraint(equalTo: topAnchor, offset: 5)
        numberLabel.setBottomConstraint(equalTo: bottomAnchor, offset: 5)
        numberLabel.setWidthConstraint(frame.width / 4)
        let view: Int = 1234
        numberLabel.text = view.labelFormat()
        numberLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setLeadingConstraint(equalTo: imageView.trailingAnchor, offset: 5)
        titleLabel.setTrailingConstraint(equalTo: numberLabel.leadingAnchor, offset: 5)
        titleLabel.setTopConstraint(equalTo: topAnchor, offset: 5)
        titleLabel.setBottomConstraint(equalTo: bottomAnchor, offset: 5)
        titleLabel.text = "This is my image at Capital Factory and I am proud of it"
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 2
    }
    
}

fileprivate extension Int {
    func labelFormat() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        
        return formattedNumber!
    }
}
