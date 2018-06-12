//
//  PostNodeObservable.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/11/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision
import SpriteKit
import RxCocoa
import RxSwift
import AWSUserPoolsSignIn

class PostNode: SCNNode {
    
    private(set) var contentNode: ContentNode
    var key: String {
        get {
            return getKey()
        }
    }
    
    init(_ pair: InfoDescriptorPair){
        contentNode = ContentNode(size: pair.info.size)
        super.init()
        
        // Add PostNode as child to its AnchorNode and set position
        pair.info.anchorNode.addChildNode(self)
        self.position = pair.info.anchorNode.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class ContentNode: SCNNode {
    private(set) var content: SKScene
    
    init(size: CGSize) {
        content = UIImage.from(color: .white).convertToSKScene()
        
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
    
    private func setContent(_ image: UIImage) {
        if let plane = self.geometry as? SCNPlane {
            plane.firstMaterial?.diffuse.contents = image.convertToSKScene()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate func getKey() -> String {
    let location = GeolocationService.sharedInstance.lastLocation!
    let locationString = String(location.0) + "/" + String(location.1)
    let date = recordDate()
    let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!
    let key = locationString + "/" + date + "/" + username
    
    return key
}

fileprivate func recordDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.dateFormat = "yyyy-MM-dd'@'HH:mm:ss"
    return dateFormatter.string(from: Date())
}
