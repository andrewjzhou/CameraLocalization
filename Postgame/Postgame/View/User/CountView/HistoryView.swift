//
//  TopView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/25/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import RxSwift
import NVActivityIndicatorView

final class HistoryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let disposeBag = DisposeBag()
    
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
    
    var topInfos: [HistoryCellInfo]? {
        didSet{
            for info in topInfos! { downloadImageToCache(info.s3Key) }
            collectionView.reloadData()
        }
        
    }
    var recentInfos: [HistoryCellInfo]? {
        didSet{
            for info in recentInfos! { downloadImageToCache(info.s3Key) }
            collectionView.reloadData()
        }
    }
    
    enum state { case top, recent }
    var currState = state.top {
        didSet {
            if currState == .top { self.titleLabel.text = "Top 5 :" }
            else { self.titleLabel.text = "Recent 5 : " }
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.alpha = 0.9
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setTopConstraint(equalTo: topAnchor, offset: 0)
        titleLabel.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        titleLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        titleLabel.setHeightConstraint(32)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .flatWhite
        titleLabel.text = "Top 5 : "
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        
        addSubview(collectionView)
        collectionView.register(HistoryViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.setTopConstraint(equalTo: titleLabel.bottomAnchor, offset: 0)
        collectionView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        collectionView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        collectionView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        collectionView.isScrollEnabled = false
        
        titleLabel.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.65)
        collectionView.backgroundColor = UIColor.flatWhiteDark.withAlphaComponent(0.97)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        titleLabel.addGestureRecognizer(tap)
        titleLabel.isUserInteractionEnabled = true
        
    }
    @objc func handleTap (sender: UITapGestureRecognizer) {
        currState = (currState == .top) ? .recent : .top
    }
    

    // CollectionView Setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let infos = (currState == .top) ? topInfos : recentInfos
        return (infos != nil) ? infos!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HistoryViewCell
        let infos = (currState == .top) ? topInfos : recentInfos
        if infos != nil {
            let info = infos![indexPath.row]
            
            // Format date
            let date = formatDateForDisplay(info.timestamp)
            cell.titleLabel.text = date
            cell.numberLabel.text = String(info.viewCount)
            
            // display image
            if let imageToShow = ImageCache.shared[info.s3Key] {
                cell.isLoadingImage = false
                cell.imageView.image = imageToShow
            } else {
                cell.isLoadingImage = true
                S3Service.sharedInstance.downloadPost(info.s3Key)
                    .asDriver(onErrorJustReturn: UIImage(named: "ic_camera_alt")!.withRenderingMode(.alwaysTemplate))
                    .drive(onNext: { (image) in
                        cell.isLoadingImage = false 
                        cell.imageView.image  = image
                        ImageCache.shared[info.s3Key] = image
                    })
                    .disposed(by: cell.disposeBag)
            }
            
            // active/inactive
            cell.backgroundColor = info.active ? UIColor.flatGreen.withAlphaComponent(0.85) : UIColor.flatRed.withAlphaComponent(0.85)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    private func downloadImageToCache(_ key: String) {
        S3Service.sharedInstance.downloadPost(key)
            .asDriver(onErrorJustReturn: UIImage(named: "ic_camera_alt")!.withRenderingMode(.alwaysTemplate))
            .drive(onNext: { (image) in
                ImageCache.shared[key] = image
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class HistoryViewCell: BaseCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let numberLabel = UILabel()

    private let activityIndicator = NVActivityIndicatorView(frame: .zero,
                                                            type: NVActivityIndicatorType.pacman,
                                                            color: .flatWhite,
                                                            padding: 7)
    var isLoadingImage: Bool = false {
        didSet {
            if isLoadingImage {
                imageView.image = nil
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            } else {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
            
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLeadingConstraint(equalTo: leadingAnchor, offset: 5)
        imageView.setTopConstraint(equalTo: topAnchor, offset: 5)
        imageView.setBottomConstraint(equalTo: bottomAnchor, offset: -5)
        imageView.setWidthConstraint(frame.height - 10)
        
        imageView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.setLeadingConstraint(equalTo: imageView.leadingAnchor, offset: 5)
        activityIndicator.setTopConstraint(equalTo: imageView.topAnchor, offset: 5)
        activityIndicator.setBottomConstraint(equalTo: imageView.bottomAnchor, offset: 5)
        activityIndicator.setTrailingConstraint(equalTo: imageView.trailingAnchor, offset: 5)
        
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 5)
        numberLabel.setTopConstraint(equalTo: topAnchor, offset: 5)
        numberLabel.setBottomConstraint(equalTo: bottomAnchor, offset: 5)
        numberLabel.setWidthConstraint(frame.width / 4)
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont(name: "Montserrat-Bold", size: 17)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setLeadingConstraint(equalTo: imageView.trailingAnchor, offset: 5)
        titleLabel.setTrailingConstraint(equalTo: numberLabel.leadingAnchor, offset: 5)
        titleLabel.setTopConstraint(equalTo: topAnchor, offset: 5)
        titleLabel.setBottomConstraint(equalTo: bottomAnchor, offset: 5)
        titleLabel.text = ""
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 17)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 2
    }
    
}

func formatDateForDisplay(_ date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let date = dateFormatter.date(from: date)
    
    // new format
    dateFormatter.timeZone = TimeZone.current
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

struct HistoryCellInfo {
    let timestamp: String
    let viewCount: Int
    let active: Bool
    let s3Key: String
}
