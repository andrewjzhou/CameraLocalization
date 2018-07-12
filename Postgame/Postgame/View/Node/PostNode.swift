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
import CoreLocation
import AWSUserPoolsSignIn

final class PostNode: SCNNode {
    private let disposeBag = DisposeBag()
    private let ttl = TTL()
    private var contentNode: ContentNode
    
    // state changes. control display
    enum PostNodeState { case initialize, active, inactive, load, prompt }
    private(set) var state: PostNodeState = .initialize {
        willSet { previousState = state }
        didSet {
            switch state {
            case .initialize:
                isHidden = true
            case .active:
                contentNode.activate()
            case .inactive:
                contentNode.deactivate()
            case .load:
                contentNode.load()
            case .prompt:
                contentNode.prompt()
            }
            if state != .initialize { isHidden = false }
        }
    }
    private(set) var previousState: PostNodeState = .initialize
    
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
    private(set) var confirmObservable: Observable<PostNode?> // notify view controller when geometry is confirmed
    
    // recorder: record updates and upload to AWS
    var recorder: Recorder
    struct Recorder {
        private var firstDiscovery = true // determines if need to deactivate old post before creating new post
        private let username: String
        let realImage: UIImage
    
        private(set) var id: String? {
            willSet {
                if id != nil { idToDeactivate = id }
            }
        }
        var idToDeactivate: String?
        var descriptor: [Double]?
        var post: UIImage?
        var location: CLLocation? {
            didSet {
                id = generateID(with: location!)
            }
        }
        
        fileprivate init(username: String, realImage: UIImage) {
            self.username = username
            self.realImage = realImage
        }
        
        mutating func record() {
            guard let id = id, let location = location, let descriptor = descriptor else { return }
            
            // 1. deactivate post if necessary
            if idToDeactivate != nil{ AppSyncService.sharedInstance.deactivatePost(id: idToDeactivate!) }
            
            // 2. store info in dynamoDB
            AppSyncService.sharedInstance.createNewPost(id: id,
                                                        username: username,
                                                        location: location,
                                                        timestamp: timestamp(),
                                                        descriptor: descriptor.base64EncodedString())
            
            // 3. upload image to S3
            S3Service.sharedInstance.uploadPost(post!, key: id)
        }
    }
    
    init(_ info: RectInfo) {
        // initialize Geometry Updater
        geometryUpdater = GeometryUpdater(currGeometry: info.geometry, status: .stage1)
        
        // set confirm observable
        let confirmPublisher = PublishSubject<PostNode?>()
        confirmObservable = confirmPublisher.asObservable()
        
        // initialize recorder
        let pool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        let username = pool.currentUser()!.username!
        recorder = Recorder(username: username, realImage: info.realImage)
        
        
        
        // set size and initialize Content Node
        contentNode = ContentNode(size: CGSize(width: info.geometry.width,
                                               height: info.geometry.height))
        super.init()
        addChildNode(contentNode)
        isHidden = true // hide upon initalization, unhide when geometry receives enough updates
        contentNode.deactivate()
        
        // set position
        let anchor = info.anchorNode
        anchor.addChildNode(self)
        position = info.geometry.center
        
        // set orientation
        eulerAngles.x = -.pi / 2
        eulerAngles.y = info.geometry.orientation
        
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
                // check if confirmed
                if self!.geometryUpdater.status == .confirmed {
                    confirmPublisher.onNext(self!)
                    confirmPublisher.onCompleted()
                    
                }
                
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
        recorder.post = image
    }
    
    func downloadAndSetContent(_ key: String, imageCacheToUpdate: NSCache<NSString, UIImage>) {
        state = .load
        // Download post and set content
        let postDownloadObservable = S3Service.sharedInstance.downloadPost(key)
        postDownloadObservable.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                if self == nil { return }
                self!.setContent(image)
                imageCacheToUpdate.setObject(image, forKey: key as NSString)
            })
            .disposed(by: disposeBag)
    }
    
    func setContentAndRecord(image: UIImage, location: CLLocation) {
        setContent(image)
        recorder.location = location
        recorder.record()
    }
    
    // Observe a new Rect Geometry update
    func updateGeometry(_ update: RectGeometry) { geometryPublisher.onNext(update) }
   
    // Set prompt screen to inform user to add / update
    func prompt() { state = .prompt }
    
    // Cancel prompt screen
    func optOutPrompt() { state = (previousState == .active) ? .active : .inactive }
    
    // deactivate
    func deactivate() { state = .inactive }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate func generateID(with location: CLLocation) -> String {
    return "\(location.coordinate.latitude)/\(location.coordinate.longitude)/\(UUID().uuidString)"
}
