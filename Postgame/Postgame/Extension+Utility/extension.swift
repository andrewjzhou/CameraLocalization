//
//  extension.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Create a colored image.
     */
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIView {
    /**
     Set width constraint of UIView.
     */
    func setWidthConstraint(_ width: CGFloat) {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    /**
     Set height constraint of UIView.
     */
    func setHeightConstraint(_ height: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    /**
     Set top anchor constraint of UIView.
     */
    func setTopConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        topAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set bottom anchor constraint of UIView.
     */
    func setBottomConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        bottomAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set leading anchor constraint of UIView.
     */
    func setLeadingConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        leadingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set trailing anchor constraint of UIView.
     */
    func setTrailingConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        trailingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set centerX anchor constraint of UIView.
     */
    func setCenterXConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        centerXAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set centerY anchor constraint of UIView.
     */
    func setCenterYConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        centerYAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
}
