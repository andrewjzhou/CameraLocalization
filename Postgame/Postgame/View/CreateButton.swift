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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
