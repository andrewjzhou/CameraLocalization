//
//  DescriptorService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

// Is resizing correct? Does it resize image to a size that meets caffenet model input requirement?
// Explore other descriptor services: e.g. MobileNet
// How to get rid of Multi-Array
// Explore other Convolutional Image retrieval methods using descriptor vector
// [UInt8] vs [Double] Representation

import UIKit
import Foundation
import CoreML
import Vision
import RxCocoa
import RxSwift

final class DescriptorComputer {
    private lazy var model = try VNCoreMLModel(for: CaffenetExtractor().model)
    
    init() {}
    
    func computeDescriptors(node: PostNode, count: Int) -> Observable<PostNode> {
        let imageArr = node.recorder.realImages
        var jumps = count - 1
        if jumps > (imageArr.count-1) { jumps = imageArr.count-1 }
        let interval = Int( floor( Double(imageArr.count-1) / Double(jumps) ) )
        
        // get images to process
        var imagesToProcess = [UIImage]()
        for index in stride(from: 0, through: imageArr.count-1, by: interval) {
            imagesToProcess.append(imageArr[index])
        }
        
        // observe descriptor computation for each image
        var descriptorObservables = [Observable<[Double]?>]()
        for img in imagesToProcess {
            let obs = compute(image: img)
            descriptorObservables.append(obs)
        }
        
        // combine descriptors and record in node
        let combined = Observable.zip(descriptorObservables) { (results: [[Double]?]) -> PostNode in
            let results = results.filter { $0 != nil }
            for res in results { node.recorder.descriptors.append(res!) }
            return node
        }
    
        return combined
    }
    
    func compute(image: UIImage) -> Observable<[Double]?> {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
    
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
                guard let descriptor = self?.processArray(array) else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                observer.onNext(descriptor)
                observer.onCompleted()
                
            })
            
            request.imageCropAndScaleOption = .scaleFit
            
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
                    
                    // For Sum-pooling
                    let num1 = pow((Double(i) - Double(height)/2.0), 2)
                    let num2 = pow((Double(j) - Double(width)/2.0), 2)
                    let den  = 2 * pow(sigma, 2)
                    
                    // For Center-prioring
                    let alpha = exp(-(num1 + num2)/den)
                    
                    // Aggregate
                    descriptor[k] += alpha * array[array.offset(for: [0,0,k,i,j])]
                    descriptor[k] += array[array.offset(for: [0,0,k,i,j])]
                }
            }
        }
        
        return descriptor
    }
}


