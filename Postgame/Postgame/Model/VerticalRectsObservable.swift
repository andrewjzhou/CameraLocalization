//
//  DetectRectanglesObservable.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/11/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision
import RxSwift
import RxCocoa

class VerticalRectsObservable {
    
    /**
     Create observable that emits detected rectangles that reside on vertical plane in a given frame.
     */
    public static func create(_ didUpdateFrameObservable: Observable<ARFrame>, in sceneView: ARSCNView) -> Observable<[VNRectangleObservation]> {
        let verticalRectsObservable
            = didUpdateFrameObservable
                // Slow down frame rate
                .throttle(0.1, scheduler:  MainScheduler.instance)
                // Detect rectangles in each frame
                .flatMap{ detectRectangles(in: $0) }
                .filter{ $0 != nil }
                // Check if detected rectangles reside on vertical plane
                .map { (observations) -> [VNRectangleObservation] in
                    var verticalObservations = [VNRectangleObservation]()
                    for observation in observations! {
                        let center = sceneView.convertFromCamera(observation.center)
                        if center.isOnVerticalPlane(in: sceneView) {
                            verticalObservations.append(observation)
                        }
                    }
                    return verticalObservations
                }
                .filter{ $0.count != 0}
        
        return verticalRectsObservable
    }
    
}


/**
 Detect rectangles in a frame.
 */
fileprivate func detectRectangles(in frame: ARFrame) -> Observable<[VNRectangleObservation]?>{
    return Observable.create({ observer in
        let request = VNDetectRectanglesRequest(completionHandler: { (request, error) in
            // Filter observations and observe detected results
            guard let observations = request.results as? [VNRectangleObservation],
                let _ = observations.first else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
            }
            
            let filteredObservations = filterContainedRects(observations)
            observer.onNext(filteredObservations)
            observer.onCompleted()
        })
        
        // Don't limit resulting number of observations
        request.maximumObservations = 1
        request.quadratureTolerance = 5
        request.minimumConfidence   = 0.6
        //            request.minimumAspectRatio  = 0.5
        //            request.maximumAspectRatio  = 2.0
        
        // Perform request
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
        try? handler.perform([request])
        return Disposables.create()
    })
}

/**
 Filter out rectangle observations that are contained by another rectangle observation.
 */
fileprivate func filterContainedRects(_ observations: [VNRectangleObservation]) -> [VNRectangleObservation]{
    // Sort in increasing order
    var filtered = [VNRectangleObservation]()
    let sorted = observations.sorted(by: { (o1, o2) -> Bool in
        if o1.boundingBox.size.smaller(than: o2.boundingBox.size) {
            return true
        }
        return false
    })
    
    // Check if observation is contained
    let length = sorted.count
    for i in 0..<length{
        let currObservation = sorted[i]
        
        var contained = false
        for j in (i+1)..<length {
            if sorted[j].boundingBox.contains(currObservation.boundingBox) {
                contained = true
                break
            }
        }
        
        // Appened uncontained observation
        if !contained {
            filtered.append(currObservation)
        }
    }
    return filtered
}

