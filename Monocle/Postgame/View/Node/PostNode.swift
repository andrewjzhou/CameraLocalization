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
    enum PostNodeState { case initialize, active, inactive, load, prompt, retry }
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
                DispatchQueue.main.async { vibrate(.medium) }
            case .retry:
                contentNode.retry()
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
    
    private(set) var confirmObservable: Observable<PostNode?> // notify view controller when geometry is confirmed
    
    // recorder: record updates and upload to AWS
    var recorder: Recorder
    
    init(_ info: RectInfo) {
        // initialize Geometry Updater
        geometryUpdater = GeometryUpdater(currGeometry: info.geometry, status: .stage1)
        
        // set confirm observable
        let confirmPublisher = PublishSubject<PostNode?>()
        confirmObservable = confirmPublisher.asObservable()
        
        // initialize recorder
        let pool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        let username = pool.currentUser()!.username!
        recorder = Recorder(username: username)
        recorder.realImages.append(info.realImage)
        
        
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
            .buffer(timeSpan: 15, count: 7, scheduler: MainScheduler.instance)
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
            self?.ttl.increment()
            self?.isHidden = (self!.ttl.state == .unlimited) ? false : true
        }).disposed(by: disposeBag)
    }
    
    // Display the image in Content Node
    func setContent(_ image: UIImage, username: String, timestamp: String) {
        contentNode.setImage(image, username: username, timestamp: timestamp)
        state = .active
        recorder.post = image
    }
    
    func downloadAndSetContent(_ key: String, username: String, timestamp: String) {
        state = .load
        
        // Download post and set content
        let postDownloadObservable = S3Service.sharedInstance.downloadPost(key)
        postDownloadObservable.observeOn(MainScheduler.instance)
            .retry(3)
            .subscribe(onNext: { [weak self] (image) in
                self?.setContent(image, username: username, timestamp: timestamp)
                ImageCache.shared[key] = image
            }, onError: { (error) in
                print(error)
                self.removeFromParentNode()
            })
            .disposed(by: disposeBag)
    }
    
    func setContentAndRecord(image: UIImage, location: CLLocation) {
        print("setContentAndRecord()")
        setContent(image, username: recorder.username, timestamp: timestamp())
        recorder.location = location
        recorder.record { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.recorder.recordError(error)
                    self?.state = .retry
                }
            }
        }
        
        // cache image
        ImageCache.shared[recorder.id!] = recorder.post!
    }
    
    // Observe a new Rect Geometry update
    func updateGeometry(_ update: RectGeometry) { geometryPublisher.onNext(update) }
   
    // Set prompt screen to inform user to add / update
    func prompt() { state = .prompt }
    
    // Cancel prompt screen
    func optOutPrompt() { state = (previousState == .active) ? .active : .inactive }
    
    // deactivate
    func deactivate() { state = .inactive }
    
    func retryUpload() {
        state = .active
        recorder.retry { [weak self] (error) in
            if let error = error {
                self?.recorder.recordError(error)
                self?.state = .retry
            }
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PostNode {
    struct Recorder {
        private var firstDiscovery = true // determines if need to deactivate old post before creating new post
        let username: String
        var realImages = [UIImage]()
        
        private(set) var id: String? {
            willSet {
                if id != nil { idToDeactivate = id }
            }
        }
        var idToDeactivate: String?
        var descriptors = [[Double]]()
        var descriptorToRecord: [Double]?
        
        var post: UIImage?
        var location: CLLocation? {
            didSet {
                id = generateID(with: location!)
            }
        }
        
        private var error: AWSError?
        
        fileprivate init(username: String) {
            self.username = username
        }
        
        mutating func record(completion: @escaping (AWSError?) -> Void) {
            print("record")
            
            guard let id = id, let location = location else { return }
            if descriptorToRecord == nil && descriptors.count < 1 { return }
            let descriptor = descriptorToRecord != nil ? descriptorToRecord! : descriptors[0]
            
            // 1. deactivate post if necessary
            if idToDeactivate != nil { AppSyncService.sharedInstance.deactivatePost(id: idToDeactivate!) }
            
            // 2. store info in dynamoDB
            AppSyncService.sharedInstance.createNewPost(id: id,
                                                        username: username,
                                                        location: location,
                                                        timestamp: timestamp(),
                                                        descriptor: descriptor.base64EncodedString(),
                                                        completion: { [post] error in
                                                            print("createNewPost() completed")
                                                            if let error = error {
                                                                completion(error)
                                                            } else {
                                                                // 3. upload image to S3 if no error
                                                                S3Service.sharedInstance.uploadPost(post!, key: id, completion: {error in
                                                                    completion(error)
                                                                })
                                                            }
            })
        }
        
        mutating func recordError(_ newError: AWSError) {
            error = newError
        }
        
        mutating func retry(completion: @escaping (AWSError?) -> Void) {
            if let error = error {
                switch error {
                case .appSyncCreateError:
                    record { (error) in
                        completion(error)
                    }
                case .s3UploadError:
                    guard let id = id else {
                        completion(.s3UploadError)
                        return
                    }
                    S3Service.sharedInstance.uploadPost(post!, key: id, completion: {error in
                        completion(error)
                    })
                default:
                    break
                }
            } else {
                fatalError("PostNode: No error recorded but attempting to retry")
            }
        }
    }
}

extension PostNode {
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
}


fileprivate func generateID(with location: CLLocation) -> String {
    return "\(location.coordinate.latitude)/\(location.coordinate.longitude)/\(UUID().uuidString)"
}
