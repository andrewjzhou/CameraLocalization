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


// image cache
final class PostNode: SCNNode {
    let disposeBag = DisposeBag()
    private let statePublisher = PublishSubject<PostNodeState>()
    
    // Use statePublisher to set state. DO NOT DIRECTLY SET STATE
    private(set) var state: PostNodeState = .inactive {
        willSet{
            previousState = state
        }
    }
    
    // optOutPrompt() checks previousState to know which state to return to
    private var previousState: PostNodeState = .inactive
    
    // Main display
    private var contentNode: ContentNode
    
    private var key: String
    
    var info: VerticalRectInfo

    private(set) var extent: PostNodeExtent
    
    private var cache: DescriptorCache
    
    // Amount of time remaining before post node expires
    private let lifespan = Lifespan()
    
    // Publish new extent updates
    private let extentPublisher = PublishSubject<PostNodeExtent>()
    
    private var initializing: Bool = true {
        didSet {
            self.isHidden = initializing
        }
    }
    
    
    init(info: VerticalRectInfo, cache: DescriptorCache){
    
        contentNode = ContentNode(size: info.size)
        key = getKey(cache.lastLocation!)
        extent = PostNodeExtent(position: info.position,
                                size: info.size)
        self.info = info
        self.cache = cache
        super.init()
        
        self.isHidden = true // Hide during initialization
        
        self.addChildNode(contentNode)
      
        // React to state changes
        statePublisher.asObservable()
            .subscribe(onNext: { (state) in
                self.state = state
                
                switch state {
                case .inactive:
                    self.contentNode.deactivate()
                case .load:
                    self.contentNode.load()
                case .prompt:
                    self.contentNode.prompt()
//                    vibrate(.heavy)
                case .active:
                    self.contentNode.activate()

                }
                
            })
            .disposed(by: disposeBag)
        
        // Add PostNode as child to its AnchorNode and set position
        info.anchorNode.addChildNode(self)
        self.position = info.position

        // Match descriptor to cache
        if let matchKey = cache.findMatch(info.descriptor!) {
            
            // Set loading screen
            self.statePublisher.onNext(.load)
   
            // Download post and set content
            let postDownloadObservable = S3Service.sharedInstance.downloadPost(matchKey)
            postDownloadObservable
                .subscribe(onNext: { (image) in
                
                    self.setContent(image)
                   
                    self.statePublisher.onNext(.active)
                    
                    self.key = matchKey // Change current key associated with node
                    
                    // increment
                    // This is getting called multiple times before picture actually gets showned
                    DynamoDBService.sharedInstance.incrementViews(self.key)
                })
                .disposed(by: disposeBag)
            
        } else {
        
            if info.post == nil {
                // Inactive = Placeholder
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
     
        // Update extent
        extentPublisher.asObservable()
            .do(onNext: { (_) in
                self.lifespan.addLife() // Add lifespan after receiving new update
            })
            .buffer(timeSpan: 20, count: 15, scheduler: MainScheduler.instance)
            .filter{ $0.count != 0 }
            .subscribe(onNext: { (extents) in
                // Find best extent
                let newExtent = findMostPopular(extents)
                
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
        if initializing && lifespan.isLong {

            initializing = false
        }
        
        extentPublisher.onNext(extent)
    }
    
    // Upload to AWS resources
    func record() {
        let s3 = S3Service.sharedInstance
        s3.uploadDescriptor(info.descriptor!, key: key)
        s3.uploadPost(contentNode.content.image, key: key)
        
        let db = DynamoDBService.sharedInstance
        let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!
        db.create(key: key, username: username)
        
        cache.update(Descriptor(key: key, value: info.descriptor!))
    }
    

    
    // Set prompt screen to inform user to add / update
    func prompt() {
        statePublisher.onNext(.prompt)
    }
    
    // Cancel prompt screen
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



fileprivate func getKey(_ location: (Double,Double)) -> String {
    let locationString = location.0.format(f: "0.4") + "/" + location.1.format(f: "0.4")
    let date = recordDate()
    let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!
    let key = locationString + "/" + date + "/" + username
    
    return key
}

func recordDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")

    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter.string(from: Date())
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

