//
//  RectInfo.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/2/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision

struct RectInfo {
    let geometry: RectGeometry
    let realImage: UIImage
    let anchorNode: SCNNode
    
    var descriptor: [Double]?
    var post: UIImage?
    
    init? (for observation: VNRectangleObservation, in sceneView: ARSCNView) {
    
        let center = sceneView.convertFromCamera(observation.center)
        guard let hitTestResult = sceneView.hitTest(center, types: .existingPlaneUsingExtent).first else {
            print("RectInfo Failed: no plane point")
            return nil
        }
        
        /// MARK:- Anchor
        guard let anchor = hitTestResult.anchor as? ARPlaneAnchor,
            let nodeForAnchor = sceneView.node(for: anchor) else {
            print("RectInfo Failed: no anchor")
            return nil
        }
        self.anchorNode = nodeForAnchor
        
        
        /// MARK:- Geometry
        // point with 3d position on the plane
        let planePoint = hitTestResult.worldVector
        
        // find Plane Normal
        let planeVector = planePoint - anchorNode.worldPosition
        let yUnit = SCNVector3Make(0, 1, 0)
        let normal = yUnit.crossProduct(planeVector)
        
        // Find 3 points, assuming portraint orientation
        guard let tlRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.bottomLeft)),
            let trRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.topLeft)),
            let blRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.bottomRight))
            else {return nil}
        
        guard let tl = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: tlRay.direction, linePoint: tlRay.origin),
            let tr = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: trRay.direction, linePoint: trRay.origin),
            let bl = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: blRay.direction, linePoint: blRay.origin)
            else {
                print("RectInfo Failed: no corners found")
                return nil
        }
        
        // find geometric information
        var position: SCNVector3
        var width, height: CGFloat
        var orientation: Float
        
        switch UIDevice.current.orientation {
        case .portrait, .unknown, .faceUp, .faceDown:
            let tlPos = sceneView.scene.rootNode.convertPosition(tl, to: anchorNode)
            let trPos = sceneView.scene.rootNode.convertPosition(tr, to: anchorNode)
            let blPos = sceneView.scene.rootNode.convertPosition(bl, to: anchorNode)
            
            // orientation
            let distX = trPos.x - tlPos.x
            let distZ = trPos.z - tlPos.z
            orientation = -atan(distZ / distX)
            
            // position
            let pos = trPos.midpoint(from: blPos)
            position = SCNVector3(pos.x, 0, pos.z) // x (+ is right, - is left), z (+ is down, - is up)
            
            /// width, height
            width = tr.distance(from: tl)
            height = tl.distance(from: bl)
            
        case .landscapeLeft:
            let blPos = sceneView.scene.rootNode.convertPosition(tl, to: anchorNode)
            let tlPos = sceneView.scene.rootNode.convertPosition(tr, to: anchorNode)
            let brPos = sceneView.scene.rootNode.convertPosition(bl, to: anchorNode)
            
            // orientation
            let distX = brPos.x - blPos.x
            let distZ = brPos.z - blPos.z
            orientation = -atan(distZ / distX)
            
            // position
            let pos = tlPos.midpoint(from: brPos)
            position = SCNVector3(pos.x, 0, pos.z) // x (+ is right, - is left), z (+ is down, - is up)
            
            // width, height
            width = brPos.distance(from: blPos)
            height = tlPos.distance(from: blPos)
            
        case .landscapeRight:
            let trPos = sceneView.scene.rootNode.convertPosition(tl, to: anchorNode)
            let brPos = sceneView.scene.rootNode.convertPosition(tr, to: anchorNode)
            let tlPos = sceneView.scene.rootNode.convertPosition(bl, to: anchorNode)
            
            // orientation
            let distX = trPos.x - tlPos.x
            let distZ = trPos.z - tlPos.z
            orientation = -atan(distZ / distX)
            
            // position
            let pos = tlPos.midpoint(from: brPos)
            position = SCNVector3(pos.x, 0, pos.z) // x (+ is right, - is left), z (+ is down, - is up)
            
            // width, height
            width = trPos.distance(from: tlPos)
            height = trPos.distance(from: brPos)
        case .portraitUpsideDown:
            let brPos = sceneView.scene.rootNode.convertPosition(tl, to: anchorNode)
            let blPos = sceneView.scene.rootNode.convertPosition(tr, to: anchorNode)
            let trPos = sceneView.scene.rootNode.convertPosition(bl, to: anchorNode)
            
            // orientation
            let distX = brPos.x - blPos.x
            let distZ = brPos.z - blPos.z
            orientation = -atan(distZ / distX)
            
            // position
            let pos = trPos.midpoint(from: blPos)
            position = SCNVector3(pos.x, 0, pos.z) // x (+ is right, - is left), z (+ is down, - is up)
            
            // width, height
            width = brPos.distance(from: blPos)
            height = trPos.distance(from: brPos)
        }
        
        geometry = RectGeometry(center: position, width: width, height: height, orientation: orientation)
        
        // MARK:- Real Image
        guard let currFrame = sceneView.session.currentFrame else { return nil }
        let currImage = CIImage(cvPixelBuffer: currFrame.capturedImage)
        let convertedRect = convertFromCamera(observation.boundingBox, size: currImage.extent.size)
//        let rect = expandRect(convertedRect, extent: currImage.extent)
        let croppedImage = currImage.cropped(to: convertedRect)
        realImage = resizeAndOrient(ciImage: croppedImage)!
        
        return nil
    }
    
}

// Find intersection of a ray and an existing plane
fileprivate func planeLineIntersectPoint(planeVector: SCNVector3 , planePoint: SCNVector3, lineVector: SCNVector3, linePoint: SCNVector3) -> SCNVector3? {
    let vpt = planeVector.x*lineVector.x + planeVector.y*lineVector.y + planeVector.z*lineVector.z
    if vpt != 0 {
        let t = ((planePoint.x-linePoint.x)*planeVector.x + (planePoint.y-linePoint.y)*planeVector.y + (planePoint.z-linePoint.z)*planeVector.z)/vpt
        let cross = SCNVector3Make(linePoint.x + lineVector.x*t, linePoint.y + lineVector.y*t, linePoint.z + lineVector.z*t)
        if (cross-linePoint).length() < 5 {
            return cross
        }
    }
    return nil
}

fileprivate func resizeAndOrient(ciImage: CIImage) -> UIImage? {
    let orientation = UIDevice.current.orientation
    
    
    switch orientation {
    case .portrait, .unknown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right).resized(width: 227, height: 227)
    case .landscapeLeft:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up).resized(width: 227, height: 227)
    case .landscapeRight:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .down).resized(width: 227, height: 227)
    case .portraitUpsideDown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .left).resized(width: 227, height: 227)
    default:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right).resized(width: 227, height: 227)
    }
}

//fileprivate func orient(ciImage: CIImage) -> UIImage {
//    let orientation = UIDevice.current.orientation
//
//    switch orientation {
//    case .portrait, .unknown:
//        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right)
//    case .landscapeLeft:
//        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
//    case .landscapeRight:
//        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .down)
//    case .portraitUpsideDown:
//        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .left)
//    default:
//        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right)
//    }
//}

//// expand rectangle region for cropped image for more room for CoreML vision request
//fileprivate func expandRect(_ rect: CGRect, extent container: CGRect) -> CGRect {
//    // TODO: play with increment ratio to see how it affect vision request results
//    let widthIncrement = rect.size.width * 0.1
//    let heighIncrement = rect.size.height * 0.1
//
//    var x = rect.origin.x - widthIncrement / 2.0
//    if x < container.origin.x {
//        x = container.origin.x
//    }
//
//    var width = rect.size.width + widthIncrement
//    if (x + width > container.origin.x + container.size.width) {
//        width = container.size.width - x
//    }
//
//    var y = rect.origin.y - heighIncrement / 2.0
//    if y < container.origin.y {
//        y = container.origin.y
//    }
//
//    var height = rect.size.height + heighIncrement
//    if (y + height > container.origin.y + container.size.height) {
//        height = container.size.height - y
//}

