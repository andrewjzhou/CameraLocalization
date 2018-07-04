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

final class DescriptorCache {
    let disposeBag = DisposeBag()
    // Matching threshold.
    // Beware of tradeoff between false postivie and false negative
    // Currently set low to limit duplicate errors (less false negative, more false positive)
    let threshold = 0.75
    var lastLocation: (Double,Double)?
    
    private(set) var cache = [String : Descriptor]() {
        didSet{ countSubject.onNext(cache.count) }
    }
    
    // IndicatorButton in main View Controller uses counter to disploy number of posts nearby
    private let countSubject = BehaviorSubject<Int>(value: 0)
    private(set) lazy var counter = countSubject.asObservable().asDriver(onErrorJustReturn: 0)
    
    // Every observered event downloads descriptor to cache
    private let queryPublisher = PublishSubject<(Double, Double)>()
    
    init() {
        // Download descriptors
        queryPublisher.asObservable()
            .throttle(2, scheduler: MainScheduler.instance)
            .map({ location -> [(Double,Double)] in
                generateNeighborCoordinates(location)
            })
            .flatMap { Observable.from($0) }
            .map { converToString($0) } // String representation of location coordinates
            .flatMap { DynamoDBService.sharedInstance.locationQuery($0)} // Download keys from dynamoDB
            .flatMap { S3Service.sharedInstance.downloadDescriptor($0) } // Download descriptors from S3
            .filter {$0 != nil}
            .subscribe(onNext: { [weak self] (descriptor) in
                if self == nil { return }
                self!.update(descriptor!)
            })
            .disposed(by: disposeBag)
    }
    
    // Make new query using location
    func query(_ location:(Double, Double)) {
        if lastLocation != nil && lastLocation! == location { return }
        
        lastLocation = location
        refresh()
    }
    
    // Reload cache
    func refresh() {
        if let location = self.lastLocation {
            // Refresh cache. Remove descriptors that are not inside user region
             cache = cache.filter { $0.value.neighbors(location) }
            
            // Download nearby descriptors
             queryPublisher.onNext(location)
        }
    }
    
    // Append or update descriptor
    func update(_ descriptor: Descriptor) { cache.updateValue(descriptor, forKey: descriptor.key) }
    
    
    // Find the best match between descriptors in cache and target descriptor. Similarity must be above of threshold.
    func findMatch(_ target: [Double]) -> String? {
        var bestMatchKey: String? = nil, bestMatchSimilarity: Double? = nil
        
        for (_, descriptor) in cache {
            let similarity = cosineSimilarity(v1: target, v2: descriptor.value)

            print("DescriptorCache: descriptor in cache : \(descriptor.key)")
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
        
        if bestMatchKey != nil { print("DescriptorCache: Match Found with similarity: \(bestMatchSimilarity)") }
        
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


