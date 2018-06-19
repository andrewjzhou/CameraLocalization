//
//  ContentNode.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit

class ContentNode: SCNNode {
    var content: ContentScene = UIImage.from(color: .white).convertToScene() {
        didSet{
            self.geometry?.firstMaterial?.diffuse.contents = content
        }
    }
    
    init(size: CGSize) {
        super.init()
        
        // Create the 3D plane geometry with the dimensions calculated from corners
        let planeGeometry = SCNPlane(width: size.width, height: size.height)
        planeGeometry.firstMaterial?.diffuse.contents = content
        
        // Flip content horizontally for skscene in setImage()
        planeGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,-1,1)
        planeGeometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.init(rawValue: 2)!
        
        self.geometry = planeGeometry
        self.eulerAngles.x = -.pi / 2 // might need to set this property as a child node in post node if it doesn't work
    }
    
    func updateSize(_ size: CGSize) {
        let plane = self.geometry as! SCNPlane
        plane.width = size.width
        plane.height = size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
