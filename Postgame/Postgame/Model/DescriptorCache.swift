//
//  DescriptorCacheService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import RxSwift
import RxCocoa
// Cosine similarity may be unreliable. Explore other matching methods between vectors

class DescriptorCache {
    private(set) var cache: [String : Descriptor] {
        didSet{
            countSubject.onNext(cache.count)
        }
    }
    
    private(set) var geolocationService: GeolocationService
    
    let threshold = 0.6
    var lastLocation: (Double,Double)?
    
    private let countSubject = BehaviorSubject<Int>(value: 0)
    private(set) var counter: Driver<Int>
    private let cacheRequestSubject = PublishSubject<(Double, Double)>()
    
    init(_ geolocationService: GeolocationService) {
        cache = [String : Descriptor]()
    
        counter = countSubject.asObservable().asDriver(onErrorJustReturn: 0)
        
        self.geolocationService = geolocationService
        
        // Get the current user coordinate
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
            .debug("Cache: New location coming in")
            .subscribe(onNext: { (location) in
                self.lastLocation = location
                // Refresh cache. Remove descriptors that are not inside user region
                self.cache = self.cache.filter { $0.value.neighbors(self.lastLocation!) }
                //
                self.cacheRequestSubject.onNext(location)
            })
            .disposed(by: disposeBag)
        
        
        cacheRequestSubject.asObservable()
            .map({ location -> [(Double,Double)] in
                generateNeighborCoordinates(location)
            })
            .debug("Cache: generated neighbor coordinates")
            .flatMap { Observable.from($0) }
            .map { converToString($0) } // String representation of location coordinates
            .flatMap { DynamoDBService.sharedInstance.query($0)} // Download keys from dynamoDB
            .flatMap { Observable.from($0) }
            .debug("Cache: queried dynamoDB and got keys")
            .flatMap { S3Service.sharedInstance.downloadDescriptor($0) } // Download descriptors from S3
            .debug("Cache: downloaded descriptors from S3")
            .filter {$0 != nil}
            .subscribe(onNext: { (descriptor) in
                self.update(descriptor!)
            })
            .disposed(by: disposeBag)
    }
    
    func update(_ descriptor: Descriptor) {
            cache.updateValue(descriptor, forKey: descriptor.key)
    }
    
    func refresh() {
        print("Refreshing")
        if let location = self.lastLocation {
             cacheRequestSubject.onNext(location)
        }
    }
    
    /**
     Find the best match between descriptors in cache and target descriptor. Similarity must be above of threshold.
     */
    func findMatch(_ target: [Double]) -> String? {
        var bestMatchKey: String? = nil
        var bestMatchSimilarity: Double? = nil
        
        for (_, descriptor) in cache {
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
        print("DescriptorCache: Match Found with similarity: \(bestMatchSimilarity)")
        return bestMatchKey
    }
    
    private func downloadKeys(_ locations: [(Double,Double)]) -> Observable<String> {
        let keyPublisher = PublishSubject<String>()
        let db = DynamoDBService.sharedInstance
        for location in locations {
            let locationString = String(location.0) + "/" + String(location.1)
            let observable = db.query(locationString)
            observable
                .subscribe(onNext: { (keys) in
                    for key in keys {
                        keyPublisher.onNext(key)
                    }
                })
                .disposed(by: disposeBag)
        }
        
        return keyPublisher.asObservable()
    }
    
    
    
    
}


class Descriptor: NSObject {
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Descriptor else {
            return false
        }
        return self.key == other.key
    }
   
}

extension Descriptor {
    func neighbors(_ location: (Double, Double)) -> Bool {
        let precision = 0.0003
        let lat = self.location.0
        let long = self.location.1
        return (abs(lat - location.0) < precision) && (abs(long - location.1) < precision)
    }
    
    func newTo(_ cache: [Descriptor]) -> Bool {
        for cached in cache {
            if cached.key == self.key {
                return false
            }
        }
        return true
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

fileprivate func generateNeighborCoordinates(_ location: (Double, Double)) -> [(Double, Double)] {
    let lat = location.0
    let long = location.1
    
    var latRange = [Double]()
    var longRange = [Double]()
    for alpha in -2 ... 2 {
        latRange.append(lat + Double(alpha) * Double(0.0001))
        longRange.append(long + Double(alpha) * Double(0.0001))
    }
   
//    let latRange = [lat-0.0002, lat-0.0001, lat, lat+0.0001, lat+0.0002]
//    let longRange = [long-0.0002, long-0.0001, long, long+0.0001, long+0.0002]
    
    var output = [(Double, Double)]()
    for i in latRange {
        for j in longRange {
            output.append((i,j))
        }
    }
    
    return output
}

fileprivate func converToString(_ location: (Double,Double)) -> String {
    return location.0.format(f: "0.4") + "/" + location.1.format(f: "0.4")
}

fileprivate let disposeBag = DisposeBag()

