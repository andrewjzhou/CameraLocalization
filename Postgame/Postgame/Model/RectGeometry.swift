//
//  RectGeometry.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/2/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision

struct RectGeometry {
    let center: SCNVector3
    let width: CGFloat
    let height: CGFloat
    let orientation: Float
    let projection: ProjectedRect
    
    // Thresholds
    static let highIoUThreshold: Float = 0.5
    static let lowIoUThreshold: Float = 0.2

    // Projecting self to 2D with no orientation for comparing purposes
    struct ProjectedRect {
        let center: CGPoint
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomRight: CGPoint
        let area: CGFloat
        
        fileprivate init(center: SCNVector3, width: CGFloat, height: CGFloat, orientation: Float) {
            let halfWidth = width * 0.5
            let halfHeight = height * 0.5
            self.center = CGPoint(x: CGFloat(center.x), y: CGFloat(-center.z))
            topLeft = CGPoint(x: self.center.x - halfWidth, y: self.center.y + halfHeight)
            topRight = CGPoint(x: self.center.x + halfWidth, y: self.center.y + halfHeight)
            bottomRight = CGPoint(x: self.center.x + halfWidth, y: self.center.y - halfHeight)
            area = (topRight.x-topLeft.x) * (topRight.y-bottomRight.y)
        }
    }
    
    
    init (center: SCNVector3, width: CGFloat, height: CGFloat, orientation: Float){
        self.center = center
        self.width = width
        self.height = height
        self.orientation = orientation
        self.projection = ProjectedRect(center: center, width: width, height: height, orientation: orientation)
        
    }
    
    func IoU(with that: RectGeometry) -> Float {
        // check to see that the difference between orientation is low
        // if this check passes. assume they have the same orientation for later calculations (this methodology should be improved)
        // return 0, assuming no intersection, if orientation difference is large
        let oriThreshold: Float = 0.05
        if abs(that.orientation - orientation) > oriThreshold { return 0 }
        
        let areaInter = findIntersection(with: that)
        
        return Float(areaInter / (self.projection.area + that.projection.area - areaInter))
    }
    
    // If this is a variation of a known RectGeometry struct, then this is a candidate to update RectGeometry
    func isVariation(of that: RectGeometry) -> Bool {
        let oriThreshold: Float = 0.05
        
        // check to see that the difference between orientation is low
        // if this check passes. assume they have the same orientation for later calculations (this methodology should be improved)
        // return 0, assuming no intersection, if orientation difference is large
        if abs(that.orientation - orientation) > oriThreshold { return false }
        
        let areaInter = findIntersection(with: that)
        // check if this or that encloses one another
        if areaInter == self.projection.area { return false }
        else if areaInter == that.projection.area { return true }
        
        // IoU check
        let iou = Float(areaInter / (self.projection.area + that.projection.area - areaInter))
        if iou > RectGeometry.lowIoUThreshold { return true }
        
        return false
    }
    
    private func findIntersection(with that: RectGeometry) -> CGFloat {
        // find the intersecting area
        let thisProjection = self.projection
        let thatProjection = that.projection
        let tlInter = CGPoint(x: max(thisProjection.topLeft.x, thatProjection.topLeft.x),
                              y: min(thisProjection.topLeft.y, thatProjection.topLeft.y))
        let trInter = CGPoint(x: min(thisProjection.topRight.x, thatProjection.topRight.x),
                              y: min(thisProjection.topRight.y, thatProjection.topRight.y))
        let brInter = CGPoint(x: min(thisProjection.bottomRight.x, thatProjection.bottomRight.x),
                              y: max(thisProjection.bottomRight.y, thatProjection.bottomRight.y))
        
        let areaInter = (trInter.x-tlInter.x) * (trInter.y-brInter.y)
        return areaInter
    }
    
    // Find the object that has the largest sum of IoU values with all other objects in the array
    static func findMostPopular(_ array: [RectGeometry]) -> RectGeometry {
        let count = array.count
        
        if count == 0 {
            return RectGeometry(center: SCNVector3Zero, width: 0, height: 0, orientation: 0)
        }
        
        var score = Array(repeating: 0, count: count)
        for i in 0 ..< count {
            for j in (i+1) ..< count {
                if array[i].IoU(with: array[j]) > RectGeometry.highIoUThreshold {
                    score[i] += 1
                    score[j] += 1
                }
            }
        }
        let index = score.index(of: score.max()!)!
        let winner = array[index]
        return winner
    }
}
