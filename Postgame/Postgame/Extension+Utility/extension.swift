//
//  extension.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import Vision
import ARKit

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
    
    /**
     Converts a point from camera coordinates (0 to 1 or -1 to 0, depending on orientation, origin bottom left corner)
     into a point within the given view.
     */
    func convertFromCamera(_ point: CGPoint) -> CGPoint {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
        case .portrait, .unknown:
            return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
        case .landscapeLeft:
            return CGPoint(x: (1 - point.x) * frame.width, y: point.y * frame.height)
        case .landscapeRight:
            return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
        case .portraitUpsideDown:
            return CGPoint(x: (1 - point.y) * frame.width, y: (1 - point.x) * frame.height)
        }
    }
    
    /**
     Converts a rect from camera coordinates (0 to 1 or -1 to 0, depending on orientation)
     into a point within the given view.
     */
    func convertFromCamera(_ rect: CGRect) -> CGRect {
        let orientation = UIApplication.shared.statusBarOrientation
        let x, y, w, h: CGFloat
        
        switch orientation {
        case .portrait, .unknown:
            w = rect.height
            h = rect.width
            x = rect.origin.y
            y = rect.origin.x
        case .landscapeLeft:
            w = rect.width
            h = rect.height
            x = 1 - rect.origin.x - w
            y = rect.origin.y
        case .landscapeRight:
            w = rect.width
            h = rect.height
            x = rect.origin.x
            y = 1 - rect.origin.y - h
        case .portraitUpsideDown:
            w = rect.height
            h = rect.width
            x = 1 - rect.origin.y - w
            y = 1 - rect.origin.x - h
        }
        
        return CGRect(x: x * frame.width, y: y * frame.height, width: w * frame.width, height: h * frame.height)
    }
}

extension CGSize {
    /**
     Check if size1 is less than size2 in area.
     */
    func smaller(than size2: CGSize) -> Bool {
        let area1 = self.width * self.height
        let area2 = size2.width * size2.height
        if area1 < area2 {
            return true
        }
        return false
    }
}

extension VNRectangleObservation {
    /**
     Center of observation in camera coordinate system.
     */
    var center:CGPoint {
        get {
            return CGPoint(x: (topRight.x + bottomLeft.x)*0.5, y: (topRight.y + bottomLeft.y)*0.5)
        }
    }
}

extension CGPoint {
    /**
     Check if point lies on a vertical plane in given sceneView.
    */
    func isOnVerticalPlane(in sceneView: ARSCNView) -> Bool {
        let results = sceneView.hitTest(self, types: .existingPlaneUsingExtent)
        if let _ = results.first{
            return true
        }
        return false
    }
}
