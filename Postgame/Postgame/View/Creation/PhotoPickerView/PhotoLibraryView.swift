//
//  PhotoLibraryGrid.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/19/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import Photos
import RxCocoa
import RxSwift

final class PhotoLibraryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// Publish image to subscriber
    public var imageSubject = PublishSubject<UIImage>()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.2
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    private lazy var fetchResult : PHFetchResult<PHAsset> = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =  [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        return fetchResult
    }()
    private let assets = {
        return PHAsset.fetchAssets(with: .image, options: nil)
    }()
    private let cellId = "cellId"
    private let manager = PHImageManager.default()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        collectionView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        collectionView.setTopConstraint(equalTo: topAnchor, offset: 0)
        collectionView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = frame.height / 2 - 0.2
        return CGSize.init(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GridCell
        
        if let _ = fetchResult.firstObject {
            manager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - indexPath.row) as PHAsset,
                                 targetSize: cell.bounds.size,
                                 contentMode: .aspectFill,
                                 options: PHImageRequestOptions(),
                                 resultHandler: { (uiImage, any) in
                                    if let img = uiImage {
                                        cell.imageView.image = img
                                    }
            })
        }
        return cell
    }
    
    /**
     Did select item .
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = fetchResult.firstObject {
            manager.requestImageData(for: fetchResult.object(at: fetchResult.count - 1 - indexPath.row),
                                     options: PHImageRequestOptions(),
                                     resultHandler: { (data, string, ori, any) in
                                        guard let imageData = data else {
                                            print("PhotoLibraryGrid: No Image Data Found")
                                            return
                                        }
                                        guard let image = UIImage(data: imageData) else {
                                            print("PhotoLibraryGrid: Cannot Create UIImage with Data")
                                            return
                                        }
                                        
                                        // Publish image after selection
                                        self.imageSubject.onNext(image)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate class GridCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.purple
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setTopConstraint(equalTo: topAnchor, offset: -0.1)
        imageView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        imageView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        imageView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


