//
//  MapViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/17/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Mapbox
import RxSwift


class MapViewController: UIViewController, MGLMapViewDelegate {
    let disposeBag = DisposeBag()
    lazy var mapView = MGLMapView(frame: view.bounds.insetBy(dx: UIScreen.main.bounds.width * 0.01,
                                                             dy: UIScreen.main.bounds.height * 0.005),
                                  styleURL: MGLStyle.streetsStyleURL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        
        mapView.layer.cornerRadius = 10
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        view.addSubview(mapView)
        mapView.tintColor = .flatGreen
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.allowsTilting = false
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if let location = mapView.userLocation?.location?.coordinate {
            mapView.setCenter(location, zoomLevel: 16, animated: true)
        }
        
        // load annotations
        if let location = mapView.userLocation?.location {
            AppSyncService.sharedInstance.listPostsByLocationLite(location, radiusInMeters: 5000)
                .asDriver(onErrorJustReturn: CLLocationCoordinate2D())
                .drive(onNext: { [mapView] (coordinate) in
                    let point = MGLPointAnnotation()
                    point.coordinate = coordinate
                    point.title = "\(coordinate.latitude), \(coordinate.longitude)"
                    mapView.addAnnotation(point)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else { return nil }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "identifier"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
}

// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.flatSkyBlue.cgColor
        
        layer.opacity = 0.75
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Animate the border width in/out, creating an iris effect.
//        let animation = CABasicAnimation(keyPath: "borderWidth")
//        animation.duration = 0.1
//        layer.borderWidth = selected ? bounds.width / 4 : 2
//        layer.add(animation, forKey: "borderWidth")
//    }
}
