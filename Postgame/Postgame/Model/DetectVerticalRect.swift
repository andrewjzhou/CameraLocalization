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

/**
 Create observable that detects vertical rects.
 */
func detectVerticalRect(frame: ARFrame, in sceneView: ARSCNView) -> Observable<VNRectangleObservation> {
    let rectanglesObservable = detectRectangles(in: frame)
    let observable =
        rectanglesObservable
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
            .flatMap { Observable.from($0) }

   return observable
}


/**
 Create observable that detects rectangles in a frame.
 */
fileprivate func detectRectangles(in frame: ARFrame) -> Observable<[VNRectangleObservation]?>{
    return Observable.create({ observer in
        let request = VNDetectRectanglesRequest(completionHandler: { (request, error) in
            DispatchQueue.main.sync {
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
            }
        })
        
        // Don't limit resulting number of observations
        request.maximumObservations = 1
        request.quadratureTolerance = 5
        request.minimumConfidence   = 0.6
        //            request.minimumAspectRatio  = 0.5
        //            request.maximumAspectRatio  = 2.0
        
        // Perform request
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
        DispatchQueue.global(qos: .background).async {
            try? handler.perform([request])
        }
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

