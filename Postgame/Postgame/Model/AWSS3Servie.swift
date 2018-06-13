//
//  AWSS3Service.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/21/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSS3
import AWSCore
import AWSMobileClient
import AWSAuthCore
import RxSwift
import RxCocoa

// Add User File Storage: https://docs.aws.amazon.com/aws-mobile/latest/developerguide/add-aws-mobile-user-data-storage.html
// Transfer Utility: https://docs.aws.amazon.com/aws-mobile/latest/developerguide/how-to-transfer-files-with-transfer-utility.html

// private - Each mobile app user can create, read, update, and delete their own files in this folder. No other app users can access this folder.
// protected - Each mobile app user can create, read, update, and delete their own files in this folder. In addition, any app user can read any other app user's files in this folder.
// public ? Any app user can create, read, update, and delete files in this folder.
// Need to add <retry upon failure> for downloading.

class AWSS3Service {
    
    static let sharedInstance = AWSS3Service()
    
    private(set) var transferUtility: AWSS3TransferUtility
    
    private init() {
        // Create S3 Client and TransferUtility
        transferUtility = AWSS3TransferUtility.default()
    }
    
    /**
     Upload descriptor from S3 using key.
     */
    func uploadDescriptor(_ descriptor: [Double], key: String) {
        let data = encodeDescriptor(descriptor)
        upload(data: data, key: key)
        
    }
    
    /**
     Upload post to S3 using key.
     */
    func uploadPost(_ post: UIImage, key: String) {
        guard let jpeg = UIImageJPEGRepresentation(post, 1.0) else {return}
        let data = jpeg.base64EncodedData(options: .lineLength64Characters)
        upload(data: data, key: key)
    }
    
    /**
     Upload data to S3 using key.
     */
    private func upload(data: Data, key: String) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
                
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data,
                                   key: key,
                                   contentType: "text/plain",
                                   expression: expression,
                                   completionHandler: completionHandler).continueWith {
                                    (task) -> AnyObject! in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                        
                                    }
                                    return nil;
        }
    }
    
    /**
     Download descriptor from S3 using key.
     */
    func downloadDescriptor(_ key: String) -> Observable<Descriptor?> {
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
                    let descriptor = Descriptor(key: key, value: decodeForDescriptor(data!))
                    
                    observer.onNext(descriptor)
                    observer.onCompleted()
                }
                
                
            }
            
            // Download task
            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(
                forKey: key,
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
    
    /**
     Download post from S3 using key.
     */
    func downloadPost(_ key: String) -> Observable<UIImage> {
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
                    let decoded: Data = Data(base64Encoded: data!, options: .ignoreUnknownCharacters)!
                    guard let post = UIImage(data: decoded) else {return}
                    
                    observer.onNext(post)
                    observer.onCompleted()
                }
                
                
            }
            
            // Download task
            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(
                forKey: key,
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

fileprivate func encodeDescriptor(_ descriptor: [Double]) -> Data {
    let stringRepresentation = descriptor.map{ String($0) }.joined(separator: ",")
    let encodedString =
        stringRepresentation
            .data(using: String.Encoding.utf8)?
            .base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let data = Data(base64Encoded: encodedString!)
    return data!
}

fileprivate func decodeForDescriptor(_ data: Data) -> [Double] {
    let decodedString = String(data: data, encoding: .utf8)
    return decodedString!.split(separator: ",").map { Double($0)! }
}


/**
 Produce the list of urls associated with the input locations, if exist.
 */
//    func urlList(for locations: [(Double, Double)]) -> Observable<String> {
//        return Observable.create({ observer in
//            for location in locations {
//                // Produce prefix for listRequest
//                let prefix = String(location.0) + "/" + String(location.1) + "/" + "descriptor"
//                //                let prefix = String(location.0) + "/" + String(location.1)
//
//                // Produce listRequest for S3
//                let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
//
//
//
////                listRequest.bucket = S3Bucket
////                listRequest.prefix = prefix
//
//
//                // Emit urls through observer
//                self.client.listObjects(listRequest).continueWith { (task) -> AnyObject? in
//                    guard let objects = task.result?.contents else {
//                        print("AWSS3Service.urlList(): No URLs found for input locations")
//                        return nil
//                    }
//
//                    for object in objects {
//                        observer.onNext(object.key!)
//                    }
//
//                    return nil
//                }
//            }
//            return Disposables.create()
//        })
//
//
//    }
