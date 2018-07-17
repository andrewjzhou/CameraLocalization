//
//  MapViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/17/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate {
    lazy var mapView = MGLMapView(frame: view.bounds.insetBy(dx: UIScreen.main.bounds.width * 0.01,
                                                             dy: UIScreen.main.bounds.height * 0.005),
                                  styleURL: MGLStyle.lightStyleURL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        
        mapView.layer.cornerRadius = 10
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        view.addSubview(mapView)
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let location = userLocation?.location?.coordinate {
            mapView.setCenter(location, zoomLevel: 16, animated: true)
        }
    }

}
