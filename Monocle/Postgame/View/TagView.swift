//
//  TagView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/24/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit


class TagView: UIView {
    
    public var font: UIFont? {
        didSet {
            if font != nil { label.font! = font! }
        }
    }
    
    private let effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .flatWhite
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.setTopConstraint(equalTo: topAnchor, offset: 0)
        effectView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        effectView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        effectView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        
        effectView.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTopConstraint(equalTo: effectView.contentView.topAnchor, offset: 0)
        label.setBottomConstraint(equalTo: effectView.contentView.bottomAnchor, offset: 0)
        label.setLeadingConstraint(equalTo: effectView.contentView.leadingAnchor, offset: 0)
        label.setTrailingConstraint(equalTo: effectView.contentView.trailingAnchor, offset: 0)
    }

    
    func display(username: String, timestamp: String) {
        label.text = "@" + username + "  " + formatDateForDisplay(timestamp)
    }
    
    private func formatDateForDisplay(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: date)
        
        // new format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: date!)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
