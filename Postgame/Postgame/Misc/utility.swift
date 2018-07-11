//
//  utility.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

func convertFromCamera(_ rect: CGRect, size: CGSize) -> CGRect {
    let orientation = UIApplication.shared.statusBarOrientation
   
    let x, y, w, h: CGFloat
    
    switch orientation {
    case .portrait, .unknown:
        w = rect.width
        h = rect.height
        x = rect.origin.x
        y = rect.origin.y
    case .landscapeLeft:
        w = rect.height
        h = rect.width
        x = rect.origin.y
        y = 1 - rect.origin.x - h
    case .landscapeRight:
        w = rect.height
        h = rect.width
        x = 1 - rect.origin.y - w
        y = rect.origin.x
    case .portraitUpsideDown:
        w = rect.height
        h = rect.width
        x = 1 - rect.origin.x - w
        y = 1 - rect.origin.y - h
    }
    
    return CGRect(x: x * size.width, y: y * size.height, width: w * size.width, height: h * size.height)
}

func vibrate(_ style: UIImpactFeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func timestamp() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter.string(from: Date())
}
