//
//  CreateButton.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/14/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import Spring

class CreateButton: SpringButton {
    
    var post: UIImage? = nil {
        didSet {
            if post == nil {
                self.setImage(UIImage(named: "ic_add"), for: .normal)
            } else {
                self.setImage(post, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Clear post inside createButton using Zoom out animation
    func clear() {
        if post == nil { return }
        guard let superview = self.superview else { return }

        let zoomButton = SpringButton(frame: self.frame)
        zoomButton.setImage(post!, for: .normal)
        zoomButton.clipsToBounds = true
        zoomButton.layer.cornerRadius = 0.5 * self.frame.width
        superview.addSubview(zoomButton)
        superview.bringSubview(toFront: zoomButton)
       
        self.post = nil
        zoomButton.animation = "zoomOut"
        zoomButton.animateNext {
            zoomButton.removeFromSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
