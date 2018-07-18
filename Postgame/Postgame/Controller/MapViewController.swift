//
//  MapViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/17/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Mapbox
import RxSwift
import ChameleonFramework


final class MapViewController: UIViewController, MGLMapViewDelegate {
    let disposeBag = DisposeBag()
    let mapView = MGLMapView()
    let slider = UISlider()
    
    var presentingVC: ViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        
        setupMapView()
        setupSlider()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        view.addGestureRecognizer(tap)
    }
  
    // Tap to dismiss Keyboard
    @objc func dismiss(sender: UITapGestureRecognizer) {
        let point = sender.location(in: view)
        // noTapZone prevents user from tapping out by accident when controlling slider
        let noTapZone = slider.frame.insetBy(dx: -0.12 * view.bounds.width, dy: -slider.bounds.height)
        if !noTapZone.contains(point) {
            // dismiss MapViewController
            self.dismiss(animated: true) {
                if let vc = self.presentingVC {
                    // show buttons in presenting ViewController
                    UIView.animate(withDuration: 0.15) {
                        vc.indicatorButton.alpha = 1
                        vc.createButton.alpha = 1
                        vc.userButton.alpha = 1
                        vc.resetButton.alpha = 1
                        vc.screenshotButton.alpha = 1
                    }
                    self.presentingVC = nil
                }
            }
        }
        
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // initial camera
        if let location = mapView.userLocation?.coordinate {
            mapView.setCenter(location, zoomLevel: 16, animated: true)
        }
        
        // load annotations
        if let location = mapView.userLocation?.location {
            AppSyncService.sharedInstance.listPostsByLocationLite(location, radiusInMeters: 1000)
                .asDriver(onErrorJustReturn: CLLocationCoordinate2D())
                .drive(onNext: { [mapView] (coordinate) in
                    let point = MGLPointAnnotation()
                    point.coordinate = coordinate
                    point.title = "\(coordinate.latitude), \(coordinate.longitude)"
                    mapView.addAnnotation(point)
                })
                .disposed(by: disposeBag)
        }
        
        // track slider for zoom
        slider.rx.value.asDriver(onErrorJustReturn: 16.0).drive(onNext: { [mapView] (zoom) in
            if let location = mapView.userLocation?.coordinate {
                mapView.setCenter(location, zoomLevel: Double(zoom), animated: false)
            }
            
        }).disposed(by: disposeBag)
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let location = userLocation?.location?.coordinate {
            mapView.setCenter(location, animated: true)
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
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 0,
                               y: 0,
                               width: 0.95 * view.bounds.width,
                               height: 0.95 * view.bounds.width)
        mapView.styleURL = MGLStyle.streetsStyleURL
        mapView.center = CGPoint(x: view.center.x,
                                 y: view.center.y - 0.1 * view.bounds.height)
        mapView.layer.cornerRadius = 0.5 * 0.95 * view.bounds.width
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.tintColor = .flatGreen
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.allowsTilting = false
        mapView.allowsScrolling = false
        mapView.allowsRotating = false
        mapView.allowsZooming = false
        mapView.maximumZoomLevel = 19
        mapView.minimumZoomLevel = 14
        mapView.layer.borderColor = UIColor.flatForestGreen.cgColor
        mapView.layer.borderWidth = 10
        mapView.layer.opacity = 0.85
      
    }
    
    private func setupSlider() {
        view.addSubview(slider)
        slider.frame = CGRect(x: 0,
                              y: 0,
                              width: 0.7 * view.bounds.width,
                              height: 0.08 * view.bounds.height)
        slider.center = CGPoint(x: view.center.x,
                                y: 0.75 * view.bounds.height)
        slider.alpha = 0.65
        slider.tintColor = .flatGreen
        slider.maximumValue = Float(mapView.maximumZoomLevel)
        slider.minimumValue = Float(mapView.minimumZoomLevel)
        slider.value = Float(16)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presentingVC = nil
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
