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
    private(set) var key: String
    private let lifespan = Lifespan()
    
    private let disposeBag = DisposeBag()
    private let extentPublisher = PublishSubject<PostNodeExtent>()
    
    var state: PostNodeState = .inactive

    
    init(infoDesciptorPair: InfoDescriptorPair, cache: DescriptorCache){
        contentNode = ContentNode(size: infoDesciptorPair.info.size)
        key = getKey(cache.lastLocation!)
       
        super.init()
        
        self.addChildNode(contentNode)
        
        // Add PostNode as child to its AnchorNode and set position
        infoDesciptorPair.info.anchorNode.addChildNode(self)
        self.position = infoDesciptorPair.info.position
        
        // Match descriptor to cache
        if let matchKey = cache.findMatch(infoDesciptorPair.descriptor) {
            // Download and set content node post
            let postObservab = AWSS3Service.sharedInstance.downloadPost(matchKey)
            postObservab
                .subscribe(onNext: { (image) in
                    self.setContent(image)
                    self.state = .active
                })
                .disposed(by: disposeBag)
        } else {
            // Set default contentNode content
        }
        
        // Self-destruct after lifespan is up. Clean bad postnodes
        lifespan.completeObservable
            .subscribe(onCompleted: {
                self.removeFromParentNode()
            })
            .disposed(by: disposeBag)
        
        // Update extent using last 10
        extentPublisher.asObservable()
            .buffer(timeSpan: 10, count: 10, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (extents) in
                // Find best extent
                let newExtent = self.findMostPopular(extents)
                
                // Update
                self.position = newExtent.position
                self.updateSize(newExtent.size)
            })
            .disposed(by: disposeBag)
    }
    
    func setContent(_ image: UIImage) {
        contentNode.setContent(image)
    }
    
    func updateSize(_ size: CGSize) {
        contentNode.updateSize(size)
    }
    
    func updateExtent(_ extent: PostNodeExtent) {
        extentPublisher.onNext(extent)
    }
    
    fileprivate func findMostPopular(_ extents: [PostNodeExtent]) -> PostNodeExtent {
        let IoUThreshold:Float = 0.5
        
        let count = extents.count
        var score = Array(repeating: 0, count: count)
        for i in 0 ..< count {
            for j in (i+1) ..< count {
                if extents[i].IoU(with: extents[j]) > IoUThreshold{
                    score[i] += 1
                    score[j] += 1
                }
            }
        }
        let index = score.index(of: score.max()!)!
        let winner = extents[index]
        return winner
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum PostNodeState {
    case inactive
    case active
}


class ContentNode: SCNNode {
    private(set) var content: SKScene
    
    init(size: CGSize) {
        content = UIImage.from(color: .white).convertToSKScene()
        
        super.init()
        
        // Create the 3D plane geometry with the dimensions calculated from corners
        let planeGeometry = SCNPlane(width: size.width, height: size.height)
        planeGeometry.firstMaterial?.diffuse.contents = content
        planeGeometry.firstMaterial?.isDoubleSided = true
        
        // Flip content horizontally for skscene in setImage()
        planeGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,-1,1)
        planeGeometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.init(rawValue: 2)!
        
        self.geometry = planeGeometry
        self.eulerAngles.x = -.pi / 2 // might need to set this property as a child node in post node if it doesn't work
    }
    
    fileprivate func updateSize(_ size: CGSize) {
        let plane = self.geometry as! SCNPlane
        plane.width = size.width
        plane.height = size.height
    }
    
    fileprivate func setContent(_ image: UIImage) {
        if let plane = self.geometry as? SCNPlane {
            plane.firstMaterial?.diffuse.contents = image.convertToSKScene()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate func getKey(_ location: (Double,Double)) -> String {
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


