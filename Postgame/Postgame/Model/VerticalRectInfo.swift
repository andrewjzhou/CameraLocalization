//
//  VerticalRectInfo.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/12/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision

class VerticalRectInfo: NSObject {
    // Center position in 3D space
    private(set) var position: SCNVector3
    
    // Dimensions of the rectangle
    private(set) var size: CGSize
    
    // Node associated with plane anchor
    private(set) var anchorNode: SCNNode
    
    // Rectangle Observation
    private(set) var realImage: UIImage
    
    init?(for observation: VNRectangleObservation, in sceneView: ARSCNView) {
        // Perform hit test to get plane information
        let center = sceneView.convertFromCamera(observation.center)
        guard let hitTestResult = sceneView.hitTest(center, types: .existingPlaneUsingExtent).first else {
            print("PlaneRectangle Failed: no plane point")
            return nil
        }
        guard let anchor = hitTestResult.anchor as? ARPlaneAnchor else {
            print("PlaneRectangle Failed: no anchor")
            return nil
        }
        
        // Anchor of the plane
        guard let nodeForAnchor = sceneView.node(for: anchor) else {return nil}
        self.anchorNode = nodeForAnchor
        
        // Point with 3d position on the plane
        let planePoint = hitTestResult.worldVector
        
        // find Plane Normal
        let planeVector = planePoint - anchorNode.worldPosition
        let yUnit = SCNVector3Make(0, 1, 0)
        let normal = yUnit.crossProduct(planeVector)
        
        // Create hit-test rays to perform hit-test more accurately with plane extent is not necessarily detected fully
        // Camera position is different from position in sceneView
        guard let tlRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.bottomLeft)),
            let trRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.topLeft)),
            let blRay = sceneView.hitTestRayFromScreenPos(sceneView.convertFromCamera(observation.bottomRight))
            else {return nil}
        
        // Find corner positions for topLeft, topRight, and bottomleft (only 3 corners is needed)
        guard let tl = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: tlRay.direction, linePoint: tlRay.origin),
            let tr = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: trRay.direction, linePoint: trRay.origin),
            let bl = planeLineIntersectPoint(planeVector: normal, planePoint: planePoint, lineVector: blRay.direction, linePoint: blRay.origin)
            else {
                print("PlaneRectangle Failed: no corners found")
                return nil
        }
        
        // Center of the plane relative to anchor
        let pos = tr.midpoint(from: bl)
        let convertedPos = sceneView.scene.rootNode.convertPosition(pos, to: anchorNode) // Convert position to anchorNode's coordinate system
        self.position = SCNVector3(convertedPos.x, 0, convertedPos.z) // x (+ is right, - is left), z (+ is down, - is up)
        
        // Size of the plane
        self.size = CGSize(width: tr.distance(from: tl), height: tl.distance(from: bl))
        
        // Record real-world surface image associated with the plane rectangle
        guard let currFrame = sceneView.session.currentFrame else {return nil}
        let currImage = CIImage(cvPixelBuffer: currFrame.capturedImage)
        let convertedRect = convertFromCamera(observation.boundingBox, size: currImage.extent.size)
        let rect = expandRect(convertedRect, extent: currImage.extent)
        let croppedImage = currImage.cropped(to: rect)
        self.realImage = resizeAndOrient(ciImage: croppedImage)!
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

// expand rectangle region for cropped image for more room for CoreML vision request
fileprivate func expandRect(_ rect: CGRect, extent container: CGRect) -> CGRect {
    // TODO: play with increment ratio to see how it affect vision request results
    let widthIncrement = rect.size.width
    let heighIncrement = rect.size.height
    
    var x = rect.origin.x - widthIncrement / 2.0
    if x < container.origin.x {
        x = container.origin.x
    }
    
    var width = rect.size.width + widthIncrement
    if (x + width > container.origin.x + container.size.width) {
        width = container.size.width - x
    }
    
    var y = rect.origin.y - heighIncrement / 2.0
    if y < container.origin.y {
        y = container.origin.y
    }
    
    var height = rect.size.height + heighIncrement
    if (y + height > container.origin.y + container.size.height) {
        height = container.size.height - y
    }
    
    return CGRect(x: x, y: y, width: width, height: height)
}

// Resize and Orient CIImage, then Return UIImage
fileprivate func resizeAndOrient(ciImage: CIImage, withPercentage percentage: CGFloat) -> UIImage? {
    let orientation = UIApplication.shared.statusBarOrientation
    
    switch orientation {
    case .portrait, .unknown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right).resized(withPercentage: percentage)
    case .landscapeLeft:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .down).resized(withPercentage: percentage)
    case .landscapeRight:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up).resized(withPercentage: percentage)
    case .portraitUpsideDown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .left).resized(withPercentage: percentage)
    }
}

fileprivate func resizeAndOrient(ciImage: CIImage) -> UIImage? {
    let orientation = UIApplication.shared.statusBarOrientation
    
    switch orientation {
    case .portrait, .unknown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .right).resized(width: 227, height: 227)
    case .landscapeLeft:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .down).resized(width: 227, height: 227)
    case .landscapeRight:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up).resized(width: 227, height: 227)
    case .portraitUpsideDown:
        return UIImage(ciImage: ciImage, scale: 1.0, orientation: .left).resized(width: 227, height: 227)
    }
}

