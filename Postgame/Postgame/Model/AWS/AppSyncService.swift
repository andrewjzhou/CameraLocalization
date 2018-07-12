//
//  AppSyncService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/9/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import AWSAppSync
import AWSS3
import AWSUserPoolsSignIn
import CoreLocation
import RxSwift

final class AppSyncService {

    static let sharedInstance = AppSyncService()

    var appSyncClient: AWSAppSyncClient?
    lazy var appSyncConfig: AWSAppSyncClientConfiguration? = {
        let databaseURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(database_name)
        do {
            let config = try AWSAppSyncClientConfiguration(url: AppSyncEndpointURL,
                                                   serviceRegion: AppSyncRegion,
                                                   userPoolsAuthProvider: self,
                                                   databaseURL:databaseURL)
            return config
        } catch {
            print("Error initializing appsync client. \(error)")
        }
        return nil
    }()

    init() {
        do {
            // Initialize the AWS AppSync client
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig!)
            // Set id as the cache key for objects
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
        } catch {
            print("Error initializing appsync client. \(error)")
        }
        
//        let subscription = OnDeactivatedPostSubscription(id: "30.268669305397445/-97.74071767003996/984F76D8-3296-4217-93E1-52F652E5ECB4")
//        do {
//            _ = try appSyncClient?.subscribe(subscription: subscription,
//                                             resultHandler: { (result, transaction, error) in
//
//        if let result = result {
//                                                    print("Subscription: Post was deactivated!")
//
////                                                    // Store a reference to the new object
////                                                    let newPost = result.data!.onCreatePost!
////                                                    // Create a new object for the desired query, where the new object content should reside
////                                                    let postToAdd = AllPostsQuery.Data.ListPost.Item(id: newPost.id,
////                                                                                                     title: newPost.title!,
////                                                                                                     author: newPost.author,
////                                                                                                     content: newPost.content!,
////                                                                                                     version: 1)
////                                                    do {
////                                                        // Update the local store with the newly received data
////                                                        try transaction?.update(query: AllPostsQuery(), { (data: inout AllPostsQuery.Data) in
////                                                            data.listPosts?.items?.append(postToAdd)
////                                                        })
////                                                        self.loadAllPostsFromCache()
////                                                    } catch {
////                                                        print("Error updating store")
////                                                    }
//                                                } else if let error = error {
//                                                    print(error.localizedDescription)
//                                                }
//            })
//        } catch {
//            print("Error starting subscription.")
//
//        }
        
    }
    
    func observeDescriptorsByLocation(_ location: CLLocation) -> Observable<[Descriptor]>{
        // user coordinates
        let lat = Double(location.coordinate.latitude)
        let lon = Double(location.coordinate.longitude)
        
        
        // radius for query in meters, in string format
        let dist = Double(location.horizontalAccuracy) + BaseLocationUncertainty
        let Unit = "m"
        let distString = String(dist) + Unit
        
        let query = ListPostsByLocationQuery(lat: lat, lon: lon, distance: distString)
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .fetchIgnoringCacheData,
                                 resultHandler: { (result, error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "")
                                        observer.onCompleted()
                                        return
                                    }
                                    
                                    if let posts = result?.data?.listPostsByLocation {
                                        var descriptorArr = [Descriptor]()
                                        for post in posts {
                                            guard let post = post else { continue }
                                        
                                            let descriptor = Descriptor(id: post.id,
                                                                        value: post.descriptor.base64DecodeIntoDoubleArr(),
                                                                        location: CLLocation(latitude: post.location.lat,
                                                                                             longitude: post.location.lon),
                                                                        S3Key: post.image.key,
                                                                        username: post.username,
                                                                        timestamp: post.timestamp)
                                            descriptorArr.append(descriptor)
                                            
                                        }
                                        observer.onNext(descriptorArr)
                                        observer.onCompleted()
                                    } else {
                                        observer.onCompleted()
                                    }
                                    
            })
            return Disposables.create()
        }
    }
    

    func createNewPost(id: String, username: String, location: CLLocation, timestamp: String, descriptor: String) {
        let locationInput = LocationInput(lat: Double(location.coordinate.latitude),
                                          lon: Double(location.coordinate.longitude))
        let s3Input = S3ObjectInput(bucket: S3Bucket,
                                    key: id,
                                    region: CognitoIdentityRegionString,
                                    mimeType: "png")
        let mutationInput = CreatePostInput(id: id,
                                            location: locationInput,
                                            active: true,
                                            timestamp: timestamp,
                                            username: username,
                                            viewCount: 0,
                                            descriptor: descriptor,
                                            image: s3Input,
                                            altitude: Double(location.altitude),
                                            horAcc: Double(location.horizontalAccuracy),
                                            verAcc: Double(location.verticalAccuracy))
        

        let mutation = CreatePostMutation(input: mutationInput)
        appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
            do {
    //            // Update our normalized local store immediately for a responsive UI
    //            try transaction?.update(query: AllPostsQuery(), { (data: inout AllPostsQuery.Data) in
    //                data.listPosts?.items?.append(AllPostsQuery.Data.ListPost.Item.init(id: uniqueId, title: mutationInput.title!, author: mutationInput.author, content: mutationInput.content!, version: 0))
    //            })
            } catch {
                print("Error updating the cache with optimistic response.")
            }
        }) { (result, error) in
            if let error = error {
                print("Error occurred: \(error.localizedDescription )")
                return
            }
            
            if let result = result {
                
                if let errors = result.errors {
                    for err in errors {
                         print("Error occurred: \(err.localizedDescription )")
                    }
                } else {
                    print("Successful Mutation")
                }
                
                
            }
        }
       
    }

    func deactivatePost(id: String) {
        let mutationInput = UpdatePostInput(id: id,
                                            active: false)
        let mutation = UpdatePostMutation(input: mutationInput)
        appSyncClient?.perform(mutation: mutation,
                              resultHandler: { (result, error) in
                                if let error = error as? AWSAppSyncClientError {
                                    print("Error occurred: \(error.localizedDescription )")
                                    return
                                }
                                print("Update Success")
        })
    }
    
    func incrementViewCount(id: String) {
        let mutation = IncrementViewCountMutation(id: id)
        appSyncClient?.perform(mutation: mutation,
                               resultHandler: { (result, error) in
                                if let error = error as? AWSAppSyncClientError {
                                    print("Error occurred: \(error.localizedDescription )")
                                    return
                                }
                                if let result = result {
                                    
                                    if let errors = result.errors {
                                        for err in errors {
                                            print("Error occurred: \(err.localizedDescription )")
                                        }
                                    } else {
                                        print("Successful Mutation")
                                    }
                                }
        })
    }

}

extension AppSyncService: AWSCognitoUserPoolsAuthProvider {
    func getLatestAuthToken() -> String {
        let pool = AWSCognitoIdentityUserPool.default()
        let session =  pool.currentUser()?.getSession()
        return (session?.result?.idToken?.tokenString) ?? ""
    }
}


