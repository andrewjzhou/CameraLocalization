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

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
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
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}
