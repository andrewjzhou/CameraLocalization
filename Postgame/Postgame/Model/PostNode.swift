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

fileprivate let disposeBag = DisposeBag()

class PostNode: SCNNode {
    
    // Use statePublisher to state state. DO NOT DIRECTLY SET STATE
    private(set) var state: PostNodeState = .inactive {
        willSet{
            previousState = state
        }
    }
    private var previousState: PostNodeState = .inactive
    
    private var contentNode: ContentNode
    private var key: String
    private var info: VerticalRectInfo
    private(set) var extent: PostNodeExtent
    private var cache: DescriptorCache
    
    private let lifespan = Lifespan()
    private let extentPublisher = PublishSubject<PostNodeExtent>()
    private let statePublisher = PublishSubject<PostNodeState>()
    
    init(info: VerticalRectInfo, cache: DescriptorCache){
        contentNode = ContentNode(size: info.size)
        key = getKey(cache.lastLocation!)
        extent = PostNodeExtent(position: info.position,
                                size: info.size)
        self.info = info
        self.cache = cache
        super.init()
        
        self.addChildNode(contentNode)
        
        // React to state changes
        statePublisher.asObservable().subscribe(onNext: { (state) in
            self.state = state
            
            switch state {
            case .inactive:
                self.contentNode.content.deactivate()
            case .load:
                self.contentNode.load()
            case .prompt:
                self.contentNode.prompt()
            case .active:
                self.contentNode.activate()
                
            }
        }).disposed(by: disposeBag)
        
        // Add PostNode as child to its AnchorNode and set position
        info.anchorNode.addChildNode(self)
        self.position = info.position

        // Match descriptor to cache
        if let matchKey = cache.findMatch(info.descriptor!) {
            self.statePublisher.onNext(.load)
            // Download and set content node post
            let postDownloadObservable = S3Service.sharedInstance.downloadPost(matchKey)
            postDownloadObservable
                .subscribe(onNext: { (image) in
                    print("PostNode: Downloaded Post using key: \(matchKey)")
                    self.setContent(image)
                    self.statePublisher.onNext(.active)
                    self.key = matchKey
                })
                .disposed(by: disposeBag)
        } else {
            if info.post == nil {
                // Set default contentNode content
                self.statePublisher.onNext(.inactive)
            } else {
                // prompt
                self.statePublisher.onNext(.prompt)
            }
        }
        
        // Self-destruct after lifespan is up. Clean bad postnodes
        lifespan.completeObservable
            .subscribe(onCompleted: {
                self.removeFromParentNode()
            })
            .disposed(by: disposeBag)
        
        // Update extent using last 10
        extentPublisher.asObservable()
            .do(onNext: { (_) in
                self.lifespan.addLife() // Add lifespan after receiving new update
            })
            .buffer(timeSpan: 20, count: 15, scheduler: MainScheduler.instance)
            .filter{ $0.count != 0 }
            .subscribe(onNext: { (extents) in
                // Find best extent
                let newExtent = self.findMostPopular(extents)
                
                // Update
                self.position = newExtent.position
                self.updateSize(newExtent.size)
                self.extent = newExtent
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func setContent(_ image: UIImage) {
        contentNode.content = image.convertToScene()
        statePublisher.onNext(.active)
    }
    
    func updateExtent(_ extent: PostNodeExtent) {
        extentPublisher.onNext(extent)
    }
    
    func record() {
        let s3 = S3Service.sharedInstance
        s3.uploadDescriptor(info.descriptor!, key: key)
        s3.uploadPost(contentNode.content.image, key: key)
        
        let db = DynamoDBService.sharedInstance
        let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!
        db.create(key: key, username: username)
        
        cache.update(Descriptor(key: key, value: info.descriptor!))
        print("Recorded")
    }
    
    func prompt() {
        statePublisher.onNext(.prompt)
    }
    
    func optOutPrompt() {
        if previousState == .active{
            statePublisher.onNext(.active)
        } else {
            statePublisher.onNext(.inactive)
        }
    }
    
    private func updateSize(_ size: CGSize) {
        contentNode.updateSize(size)
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
    case prompt
    case load
}


class ContentNode: SCNNode {
    var content: ContentScene = UIImage.from(color: .yellow).convertToScene() {
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
    
    func load() {
        content.load()
    }
    
    func prompt() {
        print("Content2: ", content)
        print("Prompt2")
        content.prompt()
    }
    
    func activate() {
        content.activate()
    }
    
    func deactivate() {
        content.deactivate()
    }
    
    
    
    fileprivate func updateSize(_ size: CGSize) {
        let plane = self.geometry as! SCNPlane
        plane.width = size.width
        plane.height = size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate func getKey(_ location: (Double,Double)) -> String {
    let locationString = location.0.format(f: "0.4") + "/" + location.1.format(f: "0.4")
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



