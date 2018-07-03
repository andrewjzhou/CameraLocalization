//
//  Descriptor.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

struct Descriptor: Equatable {
    // consider making this a struct
    let key: String
    let value: [Double]
    let location: (Double, Double)
    
    init(key: String, value: [Double]) {
        self.key = key
        self.value = value
        
        let keyArr = key.split(separator: "/")
        let lat = Double(keyArr[0])!
        let long = Double(keyArr[1])!
        self.location = (lat, long)
    }
    
    // Descriptors are equal if they have the same key
    static func == (lhs: Descriptor, rhs: Descriptor) -> Bool {
        return lhs.key == rhs.key
    }
    
}

extension Descriptor {
    func neighbors(_ location: (Double, Double)) -> Bool {
        let precision = 0.0003
        let lat = self.location.0
        let long = self.location.1
        return (abs(lat - location.0) < precision) && (abs(long - location.1) < precision)
    }
    
}
