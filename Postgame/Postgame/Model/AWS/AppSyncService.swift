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
import KeychainSwift

final class AppSyncService {

    static let sharedInstance = AppSyncService()
    
    let keychain = KeychainSwift()
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
        
    }
    
    func listPostsByLocationLite(_ location: CLLocation, radiusInMeters: Int) -> Observable<CLLocationCoordinate2D> {
        // user coordinates
        let lat = Double(location.coordinate.latitude)
        let lon = Double(location.coordinate.longitude)
        
        // radius for query in meters, in string format
        let Unit = "m"
        let distString = String(radiusInMeters) + Unit
        
        let query = ListPostsByLocationLiteQuery(lat: lat, lon: lon, distance: distString)
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .returnCacheDataAndFetch,
                                 queue: DispatchQueue.global(qos: .background),
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
                                            
                                            let coordinate = CLLocationCoordinate2D(latitude: post.location.lat,
                                                                                    longitude: post.location.lon)
                                            observer.onNext(coordinate)
                                        }
                                        observer.onCompleted()
                                    } else {
                                        observer.onCompleted()
                                    }
                                    
            })
    
            return Disposables.create()
        }
    }
    
    func observeDescriptorsByLocation(_ location: CLLocation) -> Observable<[Descriptor]>{
        // user coordinates
        let lat = Double(location.coordinate.latitude)
        let lon = Double(location.coordinate.longitude)
        
        
        // radius for query in meters, in string format
        var dist = Double(location.horizontalAccuracy)
        if dist < BaseLocationUncertainty { dist = dist * 2 } else { dist += BaseLocationUncertainty }
        let Unit = "m"
        let distString = String(dist) + Unit
        
        let query = ListPostsByLocationQuery(lat: lat, lon: lon, distance: distString)
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .fetchIgnoringCacheData,
                                 queue: DispatchQueue.global(qos: .background),
                                 resultHandler: { (result, error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "")
                                        observer.onError(error!)
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
    

    func createNewPost(id: String, username: String, location: CLLocation, timestamp: String, descriptor: String, completion: @escaping (AWSError?)-> Void) {
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
                completion(.appSyncCreateError)
                return
            }
            
            if let result = result {
                
                if let errors = result.errors {
                    completion(.appSyncCreateError)
                    for err in errors {
                         print("Error occurred: \(err.localizedDescription )")
                    }
                } else {
                    completion(nil)
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
    
    func queryTotalViews() -> Observable<Int> {
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            guard let username = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
                observer.onCompleted()
                return Disposables.create()
            }
            let query = QueryTotalViewsByUsernameQuery(username: username)
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .returnCacheDataAndFetch,
                                 queue: DispatchQueue.global(qos: .background),
                                 resultHandler: { (result, error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "")
                                        observer.onCompleted()
                                        return
                                    }
                                    
                                    if let views = result?.data?.queryTotalViewsByUsername {
                                        observer.onNext(views)
                                        observer.onCompleted()
                                    } else {
                                        observer.onCompleted()
                                    }
            })
            return Disposables.create()
        }
    }
    
    func queryMostRecent() -> Observable<[HistoryCellInfo]> {
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            guard let username = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let query = QueryMostRecentByUsernameQuery(username: username, size: 5)
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .returnCacheDataAndFetch,
                                 queue: DispatchQueue.global(qos: .background),
                                 resultHandler: { (result, error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "")
                                        observer.onCompleted()
                                        return
                                    }
                                    
                                    var infoArr = [HistoryCellInfo]()
                                    for post in result?.data?.queryMostRecentByUsername ?? [] {
                                        if post == nil { continue }
                                        let info = HistoryCellInfo(timestamp: post!.timestamp,
                                                                   viewCount: post!.viewCount,
                                                                   active: post!.active,
                                                                   s3Key: post!.image.key)
                                        infoArr.append(info)
                                    }
                                    observer.onNext(infoArr)
                                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }
        
    func queryMostViewed() -> Observable<[HistoryCellInfo]> {
        return Observable.create { [appSyncClient] (observer) -> Disposable in
            guard let username = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let query = QueryMostViewedByUsernameQuery(username: username, size: 5)
            appSyncClient?.fetch(query: query,
                                 cachePolicy: .returnCacheDataAndFetch,
                                 queue: DispatchQueue.global(qos: .background),
                                 resultHandler: { (result, error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "")
                                        observer.onCompleted()
                                        return
                                    }
                                    
                                    var infoArr = [HistoryCellInfo]()
                                    for post in result?.data?.queryMostViewedByUsername ?? [] {
                                        if post == nil { continue }
                                        let info = HistoryCellInfo(timestamp: post!.timestamp,
                                                                   viewCount: post!.viewCount,
                                                                   active: post!.active,
                                                                   s3Key: post!.image.key)
                                        infoArr.append(info)
                                    }
                                    observer.onNext(infoArr)
                                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}

// UserTable
extension AppSyncService {
    func cacheUserInfo(username: String!, completion: @escaping ()->Void) {
        let query = GetUserQuery(username: username)
        appSyncClient?.fetch(query: query,
                             cachePolicy: .returnCacheDataAndFetch,
                             queue: DispatchQueue.global(qos: .background),
                             resultHandler: { (result, error) in
                                if error != nil {
                                    print(error?.localizedDescription ?? "")
                                    return
                                }
                                
                                if let attr = result?.data?.getUser {
                                    UserCache.shared["username"] = attr.username as AnyObject
                                    UserCache.shared["phone"] = attr.phone as AnyObject
                                    if let email = attr.email { UserCache.shared["email"] = email as AnyObject }
                                    if let name = attr.name { UserCache.shared["name"] = name as AnyObject }
                                }
                                completion()
        })
        
    }
    
    func createUser(username: String!, phone: String!, email: String?, completion: @escaping (AWSError?) -> Void) {
        let input = CreateUserInput(username: username,
                                    phone: phone,
                                    dateJoined: timestamp(),
                                    email: email,
                                    birthday: nil,
                                    name: nil)
        let mutation = CreateUserMutation(input: input)
        appSyncClient?.perform(mutation: mutation,
                               resultHandler: { (result, error) in
                                if let error = error as? AWSAppSyncClientError {
                                    print("Error occurred: \(error.localizedDescription )")
                                    completion(.appSyncCreateError)
                                    return
                                }
                                if let result = result {
                                    
                                    if let errors = result.errors {
                                        completion(.appSyncCreateError)
                                        for err in errors {
                                            print("Error occurred: \(err.localizedDescription )")
                                        }
                                    } else {
                                        print("Successful created new user, \(username)")
                                        completion(nil)
                                    }
                                }
        })
    }
    
    
    func updateName(username: String!, name: String!, completion: @escaping (Bool)->Void) {
        let input = UpdateUserInput(username: username, phone: nil, dateJoined: nil, email: nil, birthday: nil, name: name)
        updateUser(input) { (bool) in
            completion(bool)
        }
    }
    
    func updateEmail(username: String!, email: String!, completion: @escaping (Bool)->Void) {
        let input = UpdateUserInput(username: username, phone: nil, dateJoined: nil, email: email, birthday: nil, name: nil)
        updateUser(input) { (bool) in
            completion(bool)
        }
    }
    
    func updatePhone(username: String!, phone: String!, completion: @escaping (Bool)->Void) {
        let input = UpdateUserInput(username: username, phone: phone, dateJoined: nil, email: nil, birthday: nil, name: nil)
        updateUser(input) { (bool) in
            completion(bool)
        }
    }
    
    private func updateUser(_ input: UpdateUserInput, completion: @escaping (Bool)->Void) {
        let mutation = UpdateUserMutation(input: input)
        appSyncClient?.perform(mutation: mutation,
                               resultHandler: { (result, error) in
                                if let error = error as? AWSAppSyncClientError {
                                    print("Error occurred: \(error.localizedDescription )")
                                    completion(false)
                                    return
                                }
                                
                                if let result = result {
                                    if let errors = result.errors {
                                        for err in errors {
                                            print("Error occurred: \(err.localizedDescription )")
                                        }
                                        completion(false)
                                    } else {
                                        completion(true)
                                    }
                                }
        })
    }
    
    
}

extension AppSyncService: AWSCognitoUserPoolsAuthProvider {
    func getLatestAuthToken() -> String {
        let user = AWSCognitoIdentityUserPool.default().currentUser()
        user?.getSession().continueWith(block: { [weak self](task) -> Any? in
            let getSessionResult = task.result
            if let tokenString = getSessionResult?.idToken?.tokenString {
                print("getLatestAuthoToken(): \(tokenString)")
                self?.keychain.set(tokenString, forKey: CognitoAuthTokenStringKey)
            }
            return nil
        })
        return keychain.get(CognitoAuthTokenStringKey) ?? ""
    }
}


