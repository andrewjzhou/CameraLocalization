//
//  DescriptorService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import Foundation
import CoreML
import Vision
import RxCocoa
import RxSwift

// Is resizing correct? Does it resize image to a size that meets caffenet model input requirement?
// Explore other descriptor services: e.g. MobileNet
// How to get rid of Multi-Array
// Explore other Convolutional Image retrieval methods using descriptor vector
// [UInt8] vs [Double] Representation

class DescriptorComputer: NSObject {
    
    // CaffeNet processing Request
    lazy var model = try VNCoreMLModel(for: CaffenetExtractor().model)
    
    override init() {
        super.init()
    }
    
    func compute(info: VerticalRectInfo) -> Observable<VerticalRectInfo?> {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(info.realImage.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: info.realImage) else { fatalError("Unable to create \(CIImage.self) from \(info.realImage).") }
        
        return Observable.create({ observer in
            let request = VNCoreMLRequest(model: self.model, completionHandler: { [weak self] request, error in
                guard let result = request.results?.first as? VNCoreMLFeatureValueObservation else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                guard let multiArray = result.featureValue.multiArrayValue else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                let array = MultiArray<Double>(multiArray)
                let descriptor = self!.processArray(array)
                
                info.descriptor = descriptor
                
                observer.onNext(info)
                observer.onCompleted()
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            
            // Perform request
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            DispatchQueue.global(qos: .userInteractive).async {
                try? handler.perform([request])
            }
            return Disposables.create()
        })
    
    }
    
    
    private func processArray(_ array: MultiArray<Double>) -> [Double] {
        // Get basic info for feature MultiArray (1x1x256x13x13)
        let height = array.shape[3]
        let width = array.shape[4]
        let length = array.shape[2]
        let sigma = Double(length) / 6.0
        
        // Initialize descriptor vector
        var descriptor = Array(repeating: 0.0, count: length)
        
        // Calcualte descritpor by traversing through feature MultiArray
        for i in 0..<height { // 13
            for j in 0..<width { // 13
                for k in 0..<length{ // 256
                    //                        // For Sum-pooling
                    //                        let num1 = pow((Double(i) - Double(height)/2.0), 2)
                    //                        let num2 = pow((Double(j) - Double(width)/2.0), 2)
                    //                        let den  = 2 * pow(sigma, 2)
                    //
                    //                        // For Center-prioring
                    //                        let alpha = exp(-(num1 + num2)/den)
                    //
                    //                        // Aggregate
                    //                        descriptor[k] += alpha * array[array.offset(for: [0,0,k,i,j])]
                    descriptor[k] += array[array.offset(for: [0,0,k,i,j])]
                }
            }
        }
        
        return descriptor
    }
}


