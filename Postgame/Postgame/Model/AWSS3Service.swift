//
//  AWSS3Service.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/21/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSS3
import RxSwift
import RxCocoa

class AWSS3Service {
    
    private(set) var transferUtility: AWSS3TransferUtility
    private(set) var client: AWSS3
    
    init() {
        // Initialize the Amazon Cognito credentials provider
        // WARNING: Current permissinos on S3 console is public. Reset permissions.
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:2ae3765b-253b-41f4-a797-70a8c333c526")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Create S3 Client and TransferUtility
        client = AWSS3.default()
        transferUtility = AWSS3TransferUtility.default()
    
    }

    /**
     Produce the list of urls associated with the input locations, if exist.
    */
    func urlList(for locations: [(Double, Double)]) -> Observable<String> {
        return Observable.create({ observer in
            for location in locations {
                // Produce prefix for listRequest
                let prefix = String(location.0) + "/" + String(location.1) + "/" + "descriptor"
//                let prefix = String(location.0) + "/" + String(location.1)
                
                // Produce listRequest for S3
                let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
                listRequest.bucket = S3Bucket
                listRequest.prefix = prefix
                
                // Emit urls through observer
                self.client.listObjects(listRequest).continueWith { (task) -> AnyObject? in
                    guard let objects = task.result?.contents else {
                        print("AWSS3Service.urlList(): No URLs found for input locations")
                        return nil
                    }
                    
                    for object in objects {
                        observer.onNext(object.key!)
                    }
                    
                    return nil
                }
            }
            return Disposables.create()
        })
       
    
    }
    
    /**
     Download descriptor from S3 using key.
     */
    func downloadDescriptor(_ key: String) -> Observable<Descriptor> {
        return Observable.create({ (observer) in
            // Track progress
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
            }
            
            // Completion
            var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
            completionHandler = { (task, URL, data, error) -> Void in
               
                // Do something e.g. Alert a user for transfer completion.
                // On failed downloads, `error` contains the error object.
                
                if let _ = data {
                    let descriptor = Descriptor(key: key, value: Array(data!))
                    
                    observer.onNext(descriptor)
                    observer.onCompleted()
                }
                    
              
            }
            
            // Download task
            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(
                fromBucket: S3Bucket,
                key: key,
                expression: expression,
                completionHandler: completionHandler
                ).continueWith {
                    (task) -> AnyObject! in if let error = task.error {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    if let _ = task.result {
                        // Do something with downloadTask.
                        
                    }
                    return nil
            }
            
            return Disposables.create()
        })
        
    }
}
