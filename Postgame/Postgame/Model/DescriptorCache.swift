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
import CoreLocation

final class DescriptorCache {
    let disposeBag = DisposeBag()
    // Matching threshold.
    // Beware of tradeoff between false postivie and false negative
    // Currently set low to limit duplicate errors (less false negative, more false positive)
    let threshold = 0.75
    var lastLocation: CLLocation?
    
    var cache = [String : Descriptor]() {
        didSet{ countSubject.onNext(cache.count) }
    }
    
    // IndicatorButton in main View Controller uses counter to disploy number of posts nearby
    private let countSubject = BehaviorSubject<Int>(value: 0)
    private(set) lazy var counter = countSubject.asObservable().asDriver(onErrorJustReturn: 0).debounce(0.05)
    
    // Every observered event downloads descriptor to cache
    private let queryPublisher = PublishSubject<CLLocation>()
    
    init() {
        // Download descriptors
        queryPublisher.asObservable()
            .debounce(0.2,
                      scheduler: ConcurrentDispatchQueueScheduler(qos: DispatchQoS.userInteractive))
            .flatMap { AppSyncService.sharedInstance.observeDescriptorsByLocation($0) }
            .subscribe(onNext: { [weak self] (descriptors) in
                self?.cache.removeAll()
                for descriptor in descriptors {
                    self?.cache.updateValue(descriptor, forKey: descriptor.id)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // Make new query using location
    func query(_ location: CLLocation) {
        lastLocation = location
        refresh()
    }
    
    // Reload cache
    func refresh() {
        if let location = lastLocation {
//            // Refresh cache. Remove descriptors that are not inside user region
//            cache = cache.filter({ (_, value: Descriptor) -> Bool in
//                let dist = value.location.distance(from: location)
//                return dist < (location.horizontalAccuracy + BaseLocationUncertainty)
//            })
            
            // Download nearby descriptors
             queryPublisher.onNext(location)
        }
    }
    
    // Remove descriptor
    func remove(id: String) { cache.removeValue(forKey: id) }
    
    
    // Find the best match between descriptors in cache and target descriptor. Similarity must be above of threshold.
    func findMatch(_ target: [Double]) -> Descriptor? {
        var bestMatch: Descriptor? = nil, bestMatchSimilarity: Double? = nil
        
        for (_, descriptor) in cache {
            let similarity = cosineSimilarity(v1: target, v2: descriptor.value)
            print("Similarity: \(similarity)")

            if similarity > threshold {
                if bestMatchSimilarity == nil { // Found first best match
                    bestMatch = descriptor
                    bestMatchSimilarity = similarity
                } else if similarity > bestMatchSimilarity! { // Found better match than current best match
                    bestMatch = descriptor
                    bestMatchSimilarity = similarity
                }
            }
        }
        
        if bestMatch != nil { print("DescriptorCache: Match Found with similarity: \(bestMatchSimilarity)") }
        
        return bestMatch
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


