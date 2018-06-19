//
//  DescriptorCacheService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

// Cosine similarity may be unreliable. Explore other matching methods between vectors

import RxSwift
import RxCocoa

class DescriptorCache {
    // Matching threshold.
    // Beware of tradeoff between false postivie and false negative
    // Currently set low to limit duplicate errors (less false negative, more false positive)
    let threshold = 0.75
    
    private(set) var cache: [String : Descriptor] {
        didSet{
            // Update count
            countSubject.onNext(cache.count)
        }
    }
    
    private(set) var geolocationService: GeolocationService
    
    var lastLocation: (Double,Double)?
    
    // Use countSubject to drive counter
    private let countSubject = BehaviorSubject<Int>(value: 0)
    
    // IndicatorButton in main View Controller uses counter to disploy number of posts nearby
    private(set) var counter: Driver<Int>
    
    // Every observered event downloads descriptor to cache
    private let cacheRequestSubject = PublishSubject<(Double, Double)>()
    
    init(_ geolocationService: GeolocationService) {
        cache = [String : Descriptor]()
    
        counter = countSubject.asObservable().asDriver(onErrorJustReturn: 0)
        
        self.geolocationService = geolocationService
        
        // Get the current user coordinate and filter
        let userLocation = geolocationService.location.asObservable()
        userLocation
            .filter({ (location) -> Bool in
                if self.lastLocation == nil {
                    return true
                } else if self.lastLocation! != location {
                    return true
                }
                return false
            })
            .subscribe(onNext: { (location) in
                self.lastLocation = location
                
                // Reload cache
                self.refresh()
            })
            .disposed(by: disposeBag)
        
        // Download descriptors
        cacheRequestSubject.asObservable()
            .map({ location -> [(Double,Double)] in
                generateNeighborCoordinates(location)
            })
            .flatMap { Observable.from($0) }
            .map { converToString($0) } // String representation of location coordinates
            .flatMap { DynamoDBService.sharedInstance.locationQuery($0)} // Download keys from dynamoDB
            .flatMap { Observable.from($0) }
            .flatMap { S3Service.sharedInstance.downloadDescriptor($0) } // Download descriptors from S3
            .filter {$0 != nil}
            .subscribe(onNext: { (descriptor) in
                self.update(descriptor!)
            })
            .disposed(by: disposeBag)
    }
    
    // Append or update descriptor
    func update(_ descriptor: Descriptor) {
            cache.updateValue(descriptor, forKey: descriptor.key)
    }
    
    // Reload cache
    func refresh() {
        if let location = self.lastLocation {
            
            // Refresh cache. Remove descriptors that are not inside user region
             cache = cache.filter { $0.value.neighbors(location) }
            
            // Download nearby descriptors
             cacheRequestSubject.onNext(location)
        }
    }
    
    
    // Find the best match between descriptors in cache and target descriptor. Similarity must be above of threshold.
    func findMatch(_ target: [Double]) -> String? {
        var bestMatchKey: String? = nil
        var bestMatchSimilarity: Double? = nil
        
        for (_, descriptor) in cache {
            let similarity = cosineSimilarity(v1: target, v2: descriptor.value)
            
            print("similarity: \(similarity)")
            
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
        
        if bestMatchKey != nil {
            print("DescriptorCache: Match Found with similarity: \(bestMatchSimilarity)")
        }
        
        return bestMatchKey
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

// Generate list of coordinates that are neighbors of last location
fileprivate func generateNeighborCoordinates(_ location: (Double, Double)) -> [(Double, Double)] {
    let lat = location.0
    let long = location.1
    
    var latRange = [Double]()
    var longRange = [Double]()
    for alpha in -2 ... 2 {
        latRange.append(lat + Double(alpha) * Double(0.0001))
        longRange.append(long + Double(alpha) * Double(0.0001))
    }
    
    var output = [(Double, Double)]()
    for i in latRange {
        for j in longRange {
            output.append((i,j))
        }
    }
    
    return output
}

// Get string representation of location
fileprivate func converToString(_ location: (Double,Double)) -> String {
    return location.0.format(f: "0.4") + "/" + location.1.format(f: "0.4")
}

fileprivate let disposeBag = DisposeBag()

