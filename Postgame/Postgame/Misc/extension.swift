//
//  extension.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import Vision
import ARKit
import SpriteKit

extension ARHitTestResult {
    var worldVector: SCNVector3 {
        get {
            return SCNVector3Make(worldTransform.columns.3.x,
                                  worldTransform.columns.3.y,
                                  worldTransform.columns.3.z)
        }
    }
}

extension ARSCNView {
    
    struct HitTestRay {
        let origin: SCNVector3
        let direction: SCNVector3
    }
    
    func hitTestRayFromScreenPos(_ point: CGPoint) -> HitTestRay? {
        
        guard let frame = self.session.currentFrame else {
            return nil
        }
        
        let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)
        
        // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
        let positionVec = SCNVector3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = self.unprojectPoint(positionVec)
        
        var rayDirection = screenPosOnFarClippingPlane - cameraPos
        rayDirection.normalize()
        
        return HitTestRay(origin: cameraPos, direction: rayDirection)
    }
    
    func isPointOnPlane(_ point: CGPoint) -> Bool {
        let results = hitTest(point, types: .existingPlaneUsingExtent)
        return results.first != nil
    }
    
    // Check if point is on a confirmed post node.
    // If eliminate is true, eliminate unconfirmed nodes if there is a confirmed node
    func isPointOnConfirmed(_ point: CGPoint, eliminateRest: Bool) -> Bool {
        let results = hitTest(point, options: [.backFaceCulling: true])
        var toEliminate = [PostNodeNew](), found = false
  
        for result in results {
            guard let contentNode = result.node as? ContentNode,
                let postNode = contentNode.parent as? PostNodeNew else { continue }
            
            if postNode.geometryUpdater.status == .confirmed { found = true }
            else if eliminateRest { toEliminate.append(postNode) }
        }
        if found == true {
            for node in toEliminate { node.removeFromParentNode() }
        }
        
        return found
    }
}

extension CGSize {
    /**
     Check if size1 is less than size2 in area.
     */
    func smaller(than size2: CGSize) -> Bool {
        let area1 = self.width * self.height
        let area2 = size2.width * size2.height
        if area1 < area2 {
            return true
        }
        return false
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension SCNVector3 {
    func crossProduct(_ vectorB: SCNVector3) -> SCNVector3 {
        
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = (z * vectorB.x) - (x * vectorB.z)
        let computedZ = (x * vectorB.y) - (y * vectorB.x)
        
        return SCNVector3(computedX, computedY, computedZ)
    }
    
    func midpoint(from vector: SCNVector3) -> SCNVector3 {
        let midX = (self.x + vector.x) / 2
        let midY = (self.y + vector.y) / 2
        let midZ = (self.z + vector.z) / 2
        return SCNVector3Make(midX, midY, midZ)
    }
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    mutating func normalize() {
        self = self.normalized()
    }
    
    func normalized() -> SCNVector3 {
        if self.length() == 0 {
            return self
        }
        
        return self / self.length()
    }
    
    func midVector(_ vectorB:SCNVector3) -> SCNVector3 {
        return SCNVector3.init((x + vectorB.x)/2.0, (y + vectorB.y)/2.0, (z + vectorB.z)/2.0)
    }
    
    func distance(from vector: SCNVector3) -> CGFloat {
        let deltaX = self.x - vector.x
        let deltaY = self.y - vector.y
        let deltaZ = self.z - vector.z
        
        return CGFloat(sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ))
    }
    
    // Calculate the magnitude of this vector
    var magnitude:Float {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    func dotProduct(_ vectorB:SCNVector3) -> Float {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    func angleBetweenVectors(_ vectorB:SCNVector3) -> Float {
        
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return Float(acos(cosineAngle))
    }
}
/**
 Binary operators for SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

extension String {
    mutating func insert(separator: String, every n: Int) {
        self = inserting(separator: separator, every: n)
    }
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}

extension UIGestureRecognizerState {
    var isActive: Bool {
        get {
            return self == .began || self == .changed
        }
    }
}

extension UIColor {
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}


extension UIImage {
    /**
     Create a colored image.
     */
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /**
     Convert to SKScene using screen frame size. SKScene is used to display content in PostNode's cntentNode.
     */
    
    func convertToScene() -> ContentScene {
        return ContentScene(self)
    }
    
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(width: CGFloat, height: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func fixOrientation() -> UIImage? {
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        let width  = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }
        
        context.concatenate(transform);
        
        switch self.imageOrientation {
            
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
            
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        
        let img = UIImage(cgImage: newCGImg)
        
        return img;
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor) {
        self.setBackgroundImage(UIImage.from(color: color), for: .normal)

    }
}

extension UIView {
    // Configure constraints of UIView manually
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    /**
     Set width constraint of UIView.
     */
    func setWidthConstraint(_ width: CGFloat) {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    /**
     Set height constraint of UIView.
     */
    func setHeightConstraint(_ height: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    /**
     Set top anchor constraint of UIView.
     */
    func setTopConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        topAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set bottom anchor constraint of UIView.
     */
    func setBottomConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        bottomAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set leading anchor constraint of UIView.
     */
    func setLeadingConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        leadingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set trailing anchor constraint of UIView.
     */
    func setTrailingConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        trailingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set centerX anchor constraint of UIView.
     */
    func setCenterXConstraint(equalTo anchor: NSLayoutXAxisAnchor , offset: CGFloat) {
        centerXAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Set centerY anchor constraint of UIView.
     */
    func setCenterYConstraint(equalTo anchor: NSLayoutYAxisAnchor , offset: CGFloat) {
        centerYAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
    }
    
    /**
     Converts a point from camera coordinates (0 to 1 or -1 to 0, depending on orientation, origin bottom left corner)
     into a point within the given view.
     */
    func convertFromCamera(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
//        let orientation = UIDevice.current.orientation
//
//        switch orientation {
//        case .portrait, .unknown:
//            return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
//        case .landscapeLeft:
//            return CGPoint(x: (1 - point.x) * frame.width, y: point.y * frame.height)
//        case .landscapeRight:
//            return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
//        case .portraitUpsideDown:
//            return CGPoint(x: (1 - point.y) * frame.width, y: (1 - point.x) * frame.height)
//        default:
//            return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
//        }
    }
    
    /**
     Converts a rect from camera coordinates (0 to 1 or -1 to 0, depending on orientation)
     into a point within the given view.
     */
    func convertFromCamera(_ rect: CGRect) -> CGRect {
        let orientation = UIDevice.current.orientation
        let x, y, w, h: CGFloat
        
        switch orientation {
        case .portrait, .unknown:
            w = rect.height
            h = rect.width
            x = rect.origin.y
            y = rect.origin.x
        case .landscapeLeft:
            w = rect.width
            h = rect.height
            x = 1 - rect.origin.x - w
            y = rect.origin.y
        case .landscapeRight:
            w = rect.width
            h = rect.height
            x = rect.origin.x
            y = 1 - rect.origin.y - h
        case .portraitUpsideDown:
            w = rect.height
            h = rect.width
            x = 1 - rect.origin.y - w
            y = 1 - rect.origin.x - h
        default:
            w = rect.height
            h = rect.width
            x = rect.origin.y
            y = rect.origin.x
        }
        
        return CGRect(x: x * frame.width, y: y * frame.height, width: w * frame.width, height: h * frame.height)
    }
}



extension VNRectangleObservation {
    /**
     Center of observation in camera coordinate system.
     */
    var center:CGPoint {
        get {
            return CGPoint(x: (topRight.x + bottomLeft.x)*0.5, y: (topRight.y + bottomLeft.y)*0.5)
        }
    }
}





