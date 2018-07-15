//
//  PhotoPickerView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/19/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoPickerView: UIStackView {
   
    fileprivate(set) var buttonSize: CGFloat
    fileprivate(set) var gridHeight: CGFloat
    fileprivate let buttonAlpha: CGFloat = 0.8
    fileprivate let disposeBag = DisposeBag()
    
    // UI Elements
    let downButton = UIButton()
    private let gridView = PhotoLibraryView()
    
    // Image published
    public var imageSubject = PublishSubject<UIImage>()
    
    init(frame: CGRect, buttonSize: CGFloat) {
        self.buttonSize = buttonSize
        self.gridHeight = frame.height - buttonSize
        super.init(frame: frame)
        
        // Set containerView specs
        axis = .vertical
        isLayoutMarginsRelativeArrangement = true
        spacing = 0
        isLayoutMarginsRelativeArrangement = true
        alignment = UIStackViewAlignment.center
        
        // setup downButton layout
        addArrangedSubview(downButton)
        downButton.backgroundColor = UIColor.white.withAlphaComponent(buttonAlpha)
        downButton.translatesAutoresizingMaskIntoConstraints = false
        downButton.setImage(UIImage(named: "ic_details"), for: .normal)
        downButton.imageView?.contentMode = .scaleAspectFill
        downButton.layer.cornerRadius = 0.05 * buttonSize
        
        // setup grid layout
        addArrangedSubview(gridView)
        gridView.setHeightConstraint(gridHeight)
        gridView.setWidthConstraint(frame.width)
        
        
        /**
         Publish image clicked in gridView - React to gridView imageSubject
         */
        gridView.imageSubject
            .subscribe(onNext: { (image) in
                self.imageSubject.onNext(image)
            })
            .disposed(by: disposeBag)
    }
    
 
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


