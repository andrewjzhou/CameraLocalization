//
//  Descriptor.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import CoreLocation

struct Descriptor: Equatable {
    // consider making this a struct
    let id: String
    let value: [Double]
    let location: CLLocation
    let parentPostInfo: ParentPostInfo
    struct ParentPostInfo { let s3Key: String, username: String, timestamp: String }
    
    
    init(id: String, value: [Double], location: CLLocation, S3Key: String, username: String, timestamp: String) {
        self.id = id
        self.value = value
        self.location = location
        self.parentPostInfo = ParentPostInfo(s3Key: S3Key, username: username, timestamp: timestamp)
    }
    
    // Descriptors are equal if they have the same key
    static func == (lhs: Descriptor, rhs: Descriptor) -> Bool {
        return lhs.id == rhs.id
    }
    
}

