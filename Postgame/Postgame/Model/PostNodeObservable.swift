//
//  PostNodeObservable.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/11/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision
import RxCocoa
import RxSwift

class PostNodesObservable {
    
    public static func create(_ verticalRectsObservable: Observable<[VNRectangleObservation]>, in sceneView: ARSCNView) {
        let postNodesObservable
            = verticalRectsObservable
                // Determine geometric information and crop real world image of each vertical rect
                .map { (observations) -> [VerticalRectInfo] in
                    var infoSet = [VerticalRectInfo]()
                    for observation in observations {
                        if let info = VerticalRectInfo(for: observation, in: sceneView) {
                            infoSet.append(info)
                        }
                    }
                    return infoSet
                }
                
    }
    
}
