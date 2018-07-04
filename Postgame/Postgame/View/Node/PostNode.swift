//
//  PostNode.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/2/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import Vision
import SpriteKit
import RxCocoa
import RxSwift
import AWSUserPoolsSignIn

final class PostNode: SCNNode {
    private let disposeBag = DisposeBag()
    private let ttl = TTL()
    private var contentNode: ContentNode
    
    // state changes. control display
    enum PostNodeState { case active, inactive, load, prompt }
    private(set) var state: PostNodeState = .inactive {
        willSet { previousState = state }
        didSet {
            switch state {
            case .active:
                contentNode.activate()
            case .inactive:
                contentNode.deactivate()
            case .load:
                contentNode.load()
            case .prompt:
                contentNode.prompt()
            }
        }
    }
    private var previousState: PostNodeState = .inactive
    
    // geometry updates
    private(set) var geometryUpdater: GeometryUpdater {
        didSet {
            position = geometryUpdater.currGeometry.center
            eulerAngles.y = geometryUpdater.currGeometry.orientation
            contentNode.updateSize(CGSize(width: geometryUpdater.currGeometry.width,
                                          height: geometryUpdater.currGeometry.height))
           
        }
    }
    private var geometryPublisher = PublishSubject<RectGeometry>()
    struct GeometryUpdater {
        var currGeometry: RectGeometry
        var status: UpdaterStatus
        enum UpdaterStatus { case stage1, stage2, confirmed }
        fileprivate mutating func upgradeStatus() {
            switch status {
            case .stage1:
                status = .stage2
            case .stage2:
                status = .confirmed
            case .confirmed:
                break
            }
        }
    }
    
    // recorder: record updates and upload to AWS
    private(set) var recorder: Recorder?
    struct Recorder {
        let key: String
        let descriptor: [Double]
        let username: String
        var image: UIImage?
        
        func record() {
            guard let image = image else { return }
            // S3
            let s3 = S3Service.sharedInstance
            s3.uploadDescriptor(descriptor, key: key)
            s3.uploadPost(image, key: key)
            // DynamoDB
            let db = DynamoDBService.sharedInstance
            db.create(key: key, username: username)
        }
    }
    
    init(_ info: RectInfo) {
        // initialize Geometry Updater
        geometryUpdater = GeometryUpdater(currGeometry: info.geometry, status: .stage1)
        
        // set size and initialize Content Node
        contentNode = ContentNode(size: CGSize(width: info.geometry.width,
                                               height: info.geometry.height))
        super.init()
        addChildNode(contentNode)
        isHidden = true // hide upon initalization, unhide when geometry receives enough updates
        
        // set position
        let anchor = info.anchorNode
        anchor.addChildNode(self)
        position = info.geometry.center
        
        // set orientation
        eulerAngles.x = -.pi / 2
        eulerAngles.y = info.geometry.orientation
        
        // set initial state and recorder
        switch info.key.status {
        case .inactive:
            contentNode.deactivate()
        case .new:
            state = .prompt
            contentNode.prompt()
            recorder = Recorder(key: info.key.identifier!,
                                descriptor: info.descriptor!,
                                username: AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!,
                                image: nil)
        case .used:
            state = .load
            contentNode.load()
            downloadAndSetContent(info.key.identifier!)
            recorder = Recorder(key: info.key.identifier!,
                                descriptor: info.descriptor!,
                                username: AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()!.username!,
                                image: nil)
        }
        
        /// MARK:-  Geometry update
        let geometryObservable = geometryPublisher.asObservable().observeOn(MainScheduler.instance).share()
        geometryObservable
            .filter({ [geometryUpdater] _ in
                // no more updates needed if confirmed
                return geometryUpdater.status != .confirmed
            })
            .buffer(timeSpan: 15, count: 3, scheduler: MainScheduler.instance)
            .filter{ $0.count != 0 }
            .subscribe(onNext: { [weak self] updates in
                if self == nil { return }
                let newGeometry = RectGeometry.findMostPopular(updates) // consider putting this on a background thread
                if newGeometry.IoU(with: self!.geometryUpdater.currGeometry) > RectGeometry.highIoUThreshold {
                    self!.geometryUpdater.upgradeStatus()
                }
                self!.geometryUpdater.currGeometry = newGeometry
                
            }).disposed(by: disposeBag)

        
        /// MARK:- Time to live
        ttl.completeDriver.drive(onCompleted: {
            self.removeFromParentNode()
        }).disposed(by: disposeBag)
        
        geometryObservable.take(2).subscribe(onNext: { [weak self] _ in
            if self == nil { return }
            self!.ttl.increment()
            self!.isHidden = (self!.ttl.state == .unlimited) ? false : true
        }).disposed(by: disposeBag)
    }
    
    // Display the image in Content Node
    func setContent(_ image: UIImage) {
        contentNode.content = image.convertToScene()
        state = .active
        if var recorder = recorder { recorder.image = image }
    }
    
    func downloadAndSetContent(_ key: String) {
        // Download post and set content
        let postDownloadObservable = S3Service.sharedInstance.downloadPost(key)
        postDownloadObservable.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                if self == nil { return }
                self!.setContent(image)
                
                // increment
                // This is getting called multiple times before picture actually gets showned
                DynamoDBService.sharedInstance.incrementViews(key)
            })
            .disposed(by: disposeBag)
    }
    
    // Observe a new Rect Geometry update
    func updateGeometry(_ update: RectGeometry) { geometryPublisher.onNext(update) }
   
    // Set prompt screen to inform user to add / update
    func prompt() { state = .prompt }
    
    // Cancel prompt screen
    func optOutPrompt() { state = (previousState == .active) ? .active : .inactive }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
