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

final class AppSyncService {

    static let sharedInstance = AppSyncService()

    var appSyncClient: AWSAppSyncClient?
    lazy var appSyncConfig: AWSAppSyncClientConfiguration? = {
        let databaseURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(database_name)
        do {
            let config = try AWSAppSyncClientConfiguration(url: AppSyncEndpointURL,
                                                   serviceRegion: AppSyncRegion,
                                                   userPoolsAuthProvider: self,
                                                   databaseURL:databaseURL,
                                                   s3ObjectManager: AWSS3TransferUtility.default())
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

    func createNewPost() {
        //---
        let image = UIImage.from(color: .red)
        // url
        let imageName = "redColor" // your image name here
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        // store
        try? UIImagePNGRepresentation(image)?.write(to: imageUrl)
   
        //---
        let locationInput = LocationInput(lat: 30.268379,
                                          lon: -97.742396,
                                          altitude: 60.0,
                                          horAcc: 23.1,
                                          verAcc: 50.1)
        let s3Input = S3ObjectInput(bucket: "postgame-userfiles-mobilehub-1951513639",
                                    key: "public/testing/246",
                                    region: "us-east-2",
                                    localUri: imageUrl.absoluteString,
                                    mimeType: "png")
        let mutationInput = CreatePostInput(id: UUID().uuidString,
                                            location: locationInput,
                                            active: true,
                                            timestamp: timestamp(),
                                            username: "Mr.Clean",
                                            viewCount: 1,
                                            descriptor: "This is the descriptor",
                                            image: s3Input)

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

    func updatePost() {
        let mutationInput = UpdatePostInput(id: "123",
                                            active: false)
        let mutation = UpdatePostMutation(input: mutationInput)
        appSyncClient?.perform(mutation: mutation,
                              queue: DispatchQueue.global(qos: .background),
                              resultHandler: { (result, error) in
                                if let error = error as? AWSAppSyncClientError {
                                    print("Error occurred: \(error.localizedDescription )")
                                    return
                                }
                                print("Update Success")
        })
    }
    
    func incrementViewCount() {
        let mutation = IncrementViewCountMutation(id: "AA3995B3-6525-4EA2-AE45-1BE25FA98400")
        appSyncClient?.perform(mutation: mutation,
                               queue: DispatchQueue.global(qos: .background),
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


