//
//  IndicatorButton.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class IndicatorButton: UIButton {
    let indicator = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.setLeadingConstraint(equalTo: self.leadingAnchor, offset: 0)
        indicator.setTrailingConstraint(equalTo: self.trailingAnchor, offset: 0)
        indicator.setTopConstraint(equalTo: self.topAnchor, offset: frame.height * 0.1)
        indicator.setBottomConstraint(equalTo: self.bottomAnchor, offset: frame.height * -0.1)
        
        // Indicator text formatting
        indicator.font = UIFont(name: "Helvetica", size: 24)
        indicator.backgroundColor = .clear
        indicator.text = "0"
        indicator.textAlignment = .center
        indicator.textColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
