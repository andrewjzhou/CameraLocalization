//
//  InfoDescriptorPair.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision

class InfoDescriptorPair: NSObject {
    private(set) var info: VerticalRectInfo
    private(set) var descriptor: [Double]
    
    init(info: VerticalRectInfo, descriptor: [Double]) {
        self.info = info
        self.descriptor = descriptor
    }
}
