//
//  IndicatorButton.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

final class IndicatorButton: UIButton {
    private let indicator = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        indicator.setLeadingConstraint(equalTo: self.leadingAnchor, offset: 0)
        indicator.setTrailingConstraint(equalTo: self.trailingAnchor, offset: 0)
        indicator.setTopConstraint(equalTo: self.topAnchor, offset: frame.height * 0.1)
        indicator.setBottomConstraint(equalTo: self.bottomAnchor, offset: frame.height * -0.1)
        
        // Display text formatting
        indicator.font = UIFont(name: "Montserrat-Medium", size: 28)
        indicator.backgroundColor = .clear
        indicator.text = "0"
        indicator.textAlignment = .center
        indicator.textColor = .black
    }
    
    /**
     Change display of IndicatorButton
     */
    func setLabel(_ count: Int) {
        indicator.text = String(count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
