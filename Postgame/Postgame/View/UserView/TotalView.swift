//
//  TotalView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/25/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

class TotalView: UIView {
    
    var titleLabel = UILabel()
    var numberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setTopConstraint(equalTo: topAnchor, offset: 0)
        titleLabel.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        titleLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        titleLabel.setHeightConstraint(64)
        titleLabel.text = "Total: "
        titleLabel.textAlignment = .center
        
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.setTopConstraint(equalTo: titleLabel.bottomAnchor, offset: 0)
        numberLabel.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        numberLabel.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        numberLabel.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        numberLabel.text = "0 0 0 , 0 0 0 , 0 0 0"
        numberLabel.textAlignment = .center
        
        
        titleLabel.backgroundColor = UIColor.flatLime
        numberLabel.backgroundColor = UIColor.flatBlue
    
    }
    
    func setNumber(_ views: Int) {
        numberLabel.text = views.labelFormat()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension Int {
    func labelFormat() -> String {
        // max value is 999,999,999
        let int = (self <= 999999999) ? self : 999999999
        var str = String(format: "%09d", int)
        
        // add commas
        str.insert(separator: ",", every: 3)
        str.remove(at: str.endIndex) // To: "xxx,xxx,xxx"
        
        // add space
        str.insert(separator: " ", every: 1) // To: "x x x , x x x , x x x"
        
        return str
    }
}
