//
//  Descriptor.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/24/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

struct Descriptor {
    let key: String
    let value: [UInt8]
    
    init(key: String, value: [UInt8]) {
        self.key = key
        self.value = value
    }
}
