//
//  GeolocationService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

// The third decimal place of coordinate is worth up to 110 m: it can identify a large agricultural field or institutional campus.
// The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It is comparable to the typical accuracy of an uncorrected GPS unit with no interference.
// The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. Accuracy to this level with commercial GPS units can only be achieved with differential correction.


import CoreLocation
import RxSwift
import RxCocoa

final class GeolocationService {
    private let disposeBag = DisposeBag()
    static let instance = GeolocationService()
    private(set) var location: Driver<CLLocation>
    
    private(set) var lastLocation: CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    
    private init() {
        print("Location service instantiated")
        locationManager.distanceFilter = 20.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        // Observable. Update location and format to 4 decimals
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .distinctUntilChanged()
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
    
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        
        locationManager.startUpdatingLocation()
    }
    
    
    
}

/**
 Round double to 4 decimal digits
 */
fileprivate func roundToDecimal4(_ value: Double) -> Double{
    return Double(round(10000*value)/10000)
}
