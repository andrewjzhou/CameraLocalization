//
//  PostNodeExtent.swift
//  postgame
//
//  Created by Andrew Jay Zhou on 6/13/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import ARKit

class PostNodeExtent {
    
    private(set) var position: SCNVector3
    private(set) var size: CGSize
    
    init(position: SCNVector3, size: CGSize) {
        self.position = position
        self.size = size
    }
    
    func IoU(with extent: PostNodeExtent) -> Float {
        let center1 = CGPoint(x: CGFloat(self.position.x), y: CGFloat(-self.position.z))
        let center2 = CGPoint(x: CGFloat(extent.position.x), y: CGFloat(-extent.position.z))
        
        let tl1 = CGPoint(x: center1.x - size.width/2.0, y: center1.y + size.height/2.0)
        let tr1 = CGPoint(x: center1.x + size.width/2.0, y: center1.y + size.height/2.0)
        let bl1 = CGPoint(x: center1.x - size.width/2.0, y: center1.y - size.height/2.0)
        let br1 = CGPoint(x: center1.x + size.width/2.0, y: center1.y - size.height/2.0)
        let area1 = (tr1.x-tl1.x) * (tr1.y-br1.y)
        
        let tl2 = CGPoint(x: center2.x - extent.size.width/2.0, y: center2.y + extent.size.height/2.0)
        let tr2 = CGPoint(x: center2.x + extent.size.width/2.0, y: center2.y + extent.size.height/2.0)
        let bl2 = CGPoint(x: center2.x - extent.size.width/2.0, y: center2.y - extent.size.height/2.0)
        let br2 = CGPoint(x: center2.x + extent.size.width/2.0, y: center2.y - extent.size.height/2.0)
        let area2 = (tr2.x-tl2.x) * (tr2.y-br2.y)
        
        let tlInter = CGPoint(x: max(tl1.x, tl2.x), y: min(tl1.y, tl2.y))
        let trInter = CGPoint(x: min(tr1.x, tr2.x), y: min(tr1.y, tr2.y))
        let blInter = CGPoint(x: max(bl1.x, bl2.x), y: max(bl1.y, bl2.y))
        let brInter = CGPoint(x: min(br1.x, br2.x), y: max(br1.y, br2.y))
        let areaInter = (trInter.x-tlInter.x) * (trInter.y-brInter.y)
        
        return Float(areaInter / (area1 + area2 - areaInter))
    }
    
    func occlusion(with extent: PostNodeExtent) -> Bool {
        let center1 = CGPoint(x: CGFloat(self.position.x), y: CGFloat(-self.position.z))
        let center2 = CGPoint(x: CGFloat(extent.position.x), y: CGFloat(-extent.position.z))
        
        let tl1 = CGPoint(x: center1.x - size.width/2.0, y: center1.y + size.height/2.0)
        let tr1 = CGPoint(x: center1.x + size.width/2.0, y: center1.y + size.height/2.0)
        let bl1 = CGPoint(x: center1.x - size.width/2.0, y: center1.y - size.height/2.0)
        let br1 = CGPoint(x: center1.x + size.width/2.0, y: center1.y - size.height/2.0)
        let area1 = (tr1.x-tl1.x) * (tr1.y-br1.y)
        
        let tl2 = CGPoint(x: center2.x - extent.size.width/2.0, y: center2.y + extent.size.height/2.0)
        let tr2 = CGPoint(x: center2.x + extent.size.width/2.0, y: center2.y + extent.size.height/2.0)
        let bl2 = CGPoint(x: center2.x - extent.size.width/2.0, y: center2.y - extent.size.height/2.0)
        let br2 = CGPoint(x: center2.x + extent.size.width/2.0, y: center2.y - extent.size.height/2.0)
        let area2 = (tr2.x-tl2.x) * (tr2.y-br2.y)
        
        let tlInter = CGPoint(x: max(tl1.x, tl2.x), y: min(tl1.y, tl2.y))
        let trInter = CGPoint(x: min(tr1.x, tr2.x), y: min(tr1.y, tr2.y))
        let blInter = CGPoint(x: max(bl1.x, bl2.x), y: max(bl1.y, bl2.y))
        let brInter = CGPoint(x: min(br1.x, br2.x), y: max(br1.y, br2.y))
        let areaInter = (trInter.x-tlInter.x) * (trInter.y-brInter.y)
        
        // Find extent for intersection rectangle
        let centerInter = SCNVector3Make(Float((trInter.x + tlInter.x) / 2.0),
                                         0,
                                         Float((trInter.y + brInter.y) / 2.0))
        let sizeInter = CGSize(width: trInter.x - tlInter.x, height: trInter.y - brInter.y)
        let extentInter = PostNodeExtent(position: centerInter, size: sizeInter)
        let IoUThreshold:Float = 0.8
        
        if (areaInter == area1 || areaInter == area2) { // complete occlusion
            return true
        } else if (extentInter.IoU(with: self) > IoUThreshold || extentInter.IoU(with: extent) > IoUThreshold){ // partial occlusion
            return true
            
        } else {
            return false
        }
    }
}
