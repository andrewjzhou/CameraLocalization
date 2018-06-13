//
//  GeolocationService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

// The third decimal place of coordinate is worth up to 110 m: it can identify a large agricultural field or institutional campus.
// The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It is comparable to the typical accuracy of an uncorrected GPS unit with no interference.
// The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. Accuracy to this level with commercial GPS units can only be achieved with differential correction.

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<(Double, Double)>
    
    private let locationManager = CLLocationManager()

    
    private init() {
        
        locationManager.distanceFilter = 40.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
        }
        
        // Observable. Update location and format to 4 decimals
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
            .map{ // Convert CLLocation coordinates to 4 decimal places
                (roundToDecimal4($0.latitude as Double), roundToDecimal4($0.longitude as Double))
            }
            .distinctUntilChanged({ (location1, location2) -> Bool in
                // Reduce fluctuation
                let precision = 0.0002
                if abs(location1.0 - location2.0) < precision && abs(location1.1 - location2.1) < precision {
                    return true
                } else {
                    return false
                }
            })
        
        
     
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

/**
 Round double to 4 decimal digits
 */
fileprivate func roundToDecimal4(_ value: Double) -> Double{
    return Double(round(10000*value)/10000)
}
