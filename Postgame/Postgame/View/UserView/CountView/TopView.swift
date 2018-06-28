//
//  TopView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/25/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

final class TopView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let imageCache = NSCache<NSString, UIImage>()
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
    
    var topInfos: [CellInfo]?
    var recentInfos: [CellInfo]?
    
    enum state { case top, recent }
    var currState = state.top {
        didSet {
            if currState == .top {
                self.titleLabel.text = "Top 5 :"
            } else {
                self.titleLabel.text = "Recent 5 : "
            }
            collectionView.reloadData()
        }
    }
    
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        titleLabel.addGestureRecognizer(tap)
        titleLabel.isUserInteractionEnabled = true
        
    }
    @objc func handleTap (sender: UITapGestureRecognizer) {
        currState = (currState == .top) ? .recent : .top
        print("This is being tapped: \(currState)")
    }
    
    func setup(_ vc: ViewCount) {
        topInfos = [CellInfo]()
        if vc._recent1Key != "nil" {
            let info = CellInfo(key: vc._top1Key!, date: vc._top1Date!, views: vc._top1Views!.intValue)
            topInfos!.append(info)
        }
        if vc._recent2Key != "nil" {
            let info = CellInfo(key: vc._top2Key!, date: vc._top2Date!, views: vc._top2Views!.intValue)
            topInfos!.append(info)
        }
        if vc._recent3Key != "nil" {
            let info = CellInfo(key: vc._top3Key!, date: vc._top3Date!, views: vc._top3Views!.intValue)
            topInfos!.append(info)
        }
        if vc._recent4Key != "nil" {
            let info = CellInfo(key: vc._top4Key!, date: vc._top4Date!, views: vc._top4Views!.intValue)
            topInfos!.append(info)
        }
        if vc._recent5Key != "nil" {
            let info = CellInfo(key: vc._top5Key!, date: vc._top5Date!, views: vc._top5Views!.intValue)
            topInfos!.append(info)
        }
        
        recentInfos = [CellInfo]()
        if vc._recent1Key != "nil" {
            let info = CellInfo(key: vc._recent1Key!, date: vc._recent1Date!, views: vc._recent1Views!.intValue)
            recentInfos!.append(info)
        }
        if vc._recent2Key != "nil" {
            let info = CellInfo(key: vc._recent2Key!, date: vc._recent2Date!, views: vc._recent2Views!.intValue)
            recentInfos!.append(info)
        }
        if vc._recent3Key != "nil" {
            let info = CellInfo(key: vc._recent3Key!, date: vc._recent3Date!, views: vc._recent3Views!.intValue)
            recentInfos!.append(info)
        }
        if vc._recent4Key != "nil" {
            let info = CellInfo(key: vc._recent4Key!, date: vc._recent4Date!, views: vc._recent4Views!.intValue)
            recentInfos!.append(info)
        }
        if vc._recent5Key != "nil" {
            let info = CellInfo(key: vc._recent5Key!, date: vc._recent5Date!, views: vc._recent5Views!.intValue)
            recentInfos!.append(info)
        }
        
        collectionView.reloadData()
    }
    

    // CollectionView Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let infos = (currState == .top) ? topInfos : recentInfos
        return (infos != nil) ? infos!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopViewCell
        let infos = (currState == .top) ? topInfos : recentInfos
        if infos != nil {
            let info = infos![indexPath.row]
            
            // Format date
            let date = formatDateForDisplay(info.date)
            cell.titleLabel.text = date
            cell.numberLabel.text = String(info.views)
            
            if let imageToShow = imageCache.object(forKey: info.key as NSString) {
                cell.imageView.image = imageToShow
            } else {
                S3Service.sharedInstance.downloadPost(info.key)
                    .asDriver(onErrorJustReturn: UIImage(named: "ic_camera_alt")!.withRenderingMode(.alwaysTemplate))
                    .drive(onNext: { (image) in
                        cell.imageView.image  = image
                        self.imageCache.setObject(image, forKey: info.key as NSString)
                    })
                    .disposed(by: cell.disposeBag)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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

final class TopViewCell: BaseCell {
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

func formatDateForDisplay(_ date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let date = dateFormatter.date(from: date)
    
    // new format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    return dateFormatter.string(from: date!)
}

fileprivate extension Int {
    func labelFormat() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        
        return formattedNumber!
    }
}


struct CellInfo {
    let key: String
    let date: String
    let views: Int
}
