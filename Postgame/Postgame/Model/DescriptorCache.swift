//
//  DescriptorCacheService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

// Cosine similarity may be unreliable. Explore other matching methods between vectors

class DescriptorCache {
   
    private(set) var cache: [Descriptor]
    private(set) var geolocationService: GeolocationService
    let threshold = 0.75
    var lastLocation: (Double,Double)?
    
    init(_ geolocationService: GeolocationService) {
        cache = [Descriptor]()
        self.geolocationService = geolocationService
        
     
        // Get the current user coordinate
        let userLocation = geolocationService.location
        userLocation.drive(onNext: { (location) in
            self.lastLocation = location
        })
        
        
        //            .do(onNext: { (location) in
        //                // Refresh cache. Remove descriptors that are not inside user region
        //                for key in self.descriptorCache.keys {
        //                    if !self.keyCloseToLocation(key: key, location: location) {
        //                        self.descriptorCache.removeValue(forKey: key)
        //                    }
        //                }
        //            })
        //            .debug("After distinct until changed")
        //            .asObservable()
        
        
        // Cache descritpors based on user location
        // Switch out S3 function with mobilehub version
        //        userLocation
        //            .map { coordinate in
        //                // Get surrounding coordinates
        //                return self.surroundingCoordinates(for: coordinate)
        //            }
        //            .debug("Descriptor Cache: After map2")
        //            .flatMap { locations in
        //                // Get list or URLs asscossiated with coordinates
        //                return self.s3.urlList(for: locations)
        //            }
        //            .debug("Descriptor Cache: After flat-map")
        //            .flatMap({ (url) in
        //                // Download descriptors
        //                return self.s3.downloadDescriptor(url)
        //            })
        //            .subscribe(onNext: { (descriptor) in
        //                // Cache descriptors
        //                self.descriptorCache.updateValue(descriptor.value, forKey: descriptor.key)
        //            }, onError: { (error) in
        //                print("Descriptor Cache Error: ", error)
        //            })
        //            .disposed(by: disposeBag)
    }
    
    /**
     Find the best match between descriptors in cache and target descriptor. Similarity must be above of threshold.
     */
    func findMatch(_ target: [Double]) -> String? {
        var bestMatchKey: String? = nil
        var bestMatchSimilarity: Double? = nil
        
        for descriptor in cache {
            var sumxx = 0, sumxy = 0, sumyy = 0
            for i in 0 ..< target.count {
                let similarity = cosineSimilarity(v1: target, v2: descriptor.value)
                if similarity > threshold {
                    if bestMatchSimilarity == nil { // Found first best match
                        bestMatchKey = descriptor.key
                        bestMatchSimilarity = similarity
                    } else if similarity > bestMatchSimilarity! { // Found better match than current best match
                        bestMatchKey = descriptor.key
                        bestMatchSimilarity = similarity
                    }
                }
            }
        }
        
        return bestMatchKey
    }
}


struct Descriptor {
    let key: String
    let value: [Double]
    
    init(key: String, value: [Double]) {
        self.key = key
        self.value = value
    }
}


/**
 Find cosine similarity between two vectors.
 */
fileprivate func cosineSimilarity(v1: [Double], v2: [Double]) -> Double {
    var sumxx = 0.0, sumxy = 0.0, sumyy = 0.0
    for i in 0 ..< v1.count {
        let x = v1[i], y = v2[i]
        sumxx += x*x
        sumyy += y*y
        sumxy += x*y
    }
    return sumxy/sqrt(sumxx*sumyy)
}


/**
 Get coordinates surrounding estimated coordinate
 */
fileprivate func surroundingCoordinates(for coordinate: (Double, Double)) -> [(Double, Double)]{
    var coordinates = [(Double, Double)]()
    let lattitude = coordinate.0,
    longitude = coordinate.1
    
    // +/- 0.0002
    let lats = [lattitude-0.0002, lattitude-0.0001, lattitude, lattitude+0.0001, lattitude+0.0002]
    let longs = [longitude-0.0002, longitude-0.0001, longitude, longitude+0.0001, longitude+0.0002]
    
    for lat in lats {
        for long in longs {
            coordinates.append((lat, long))
        }
    }
    
    return coordinates
}

/**
 Check if descriptor is in the approximate region that the user is in by checking descriptor key.
 */
fileprivate func keyCloseToLocation(key: String, location: (Double, Double)) -> Bool {
    let keyArr = key.split(separator: "/")
    guard let lat = Double(keyArr[0]),
        let long = Double(keyArr[1]) else {
            print("keyCloseToLocation: Conversion Error")
            return false
    }
    
    let precision = 0.0003
    return (abs(lat - location.0) < precision) && (abs(long - location.1) < precision)
}
