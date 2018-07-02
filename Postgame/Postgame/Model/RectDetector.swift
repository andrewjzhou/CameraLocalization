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

final class RectDetector {
    private let disposeBag = DisposeBag()
    
    private let publisher = PublishSubject<VNRectangleObservation>()
    private lazy var request: VNDetectRectanglesRequest = VNDetectRectanglesRequest(completionHandler: { [publisher] (request, error) in
        
        // Filter observations and observe detected results
        guard let observations = request.results as? [VNRectangleObservation],
            let first = observations.first else {
                return
        }
        
        publisher.onNext(first)
        
    })
    
    // drive from rectDriver to observe VNRectangleObservations detected by RectDetector
    private(set) lazy var rectDriver = publisher.asDriver(onErrorJustReturn: VNRectangleObservation(boundingBox: .zero))
    
    init() {
        // findtune request parameters
        request.maximumObservations = 1
        request.quadratureTolerance = 5
        request.minimumConfidence   = 0.6
        
        // dispose
        publisher.disposed(by: disposeBag)
    }
    
    /// perform rectangle detection. results are observed through rectDriver
    func detectRectangle(in frame: ARFrame) {
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
        
        DispatchQueue.global(qos: .background).async { [request] in
            try? handler.perform([request])
        }
    }
}

  
    

