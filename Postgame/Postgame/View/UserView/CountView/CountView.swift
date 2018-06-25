//
//  CountView.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/26/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit


class CountView: UIView {
    
    let totalView = TotalView()
    let topView = TopView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(totalView)
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.setTopConstraint(equalTo: topAnchor, offset: 0)
        totalView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        totalView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        totalView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        
        addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        topView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        topView.setTopConstraint(equalTo: totalView.bottomAnchor, offset: 0)
        topView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
