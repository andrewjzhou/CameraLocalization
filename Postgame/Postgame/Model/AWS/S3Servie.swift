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

class S3Service {
    // S3 descriptor Key Format: public/descriptor/lattitude/longitude/creation-date/first-username
    // S3 post Key Format: public/post/lattitude/longitude/creation-date/first-username
    
    static let sharedInstance = S3Service()
    
    private(set) var transferUtility: AWSS3TransferUtility
    
    private init() {
        transferUtility = AWSS3TransferUtility.default()
    }
    
    /**
     Upload descriptor from S3 using key.
     */
    func uploadDescriptor(_ descriptor: [Double], key: String) {
        // generate data
        let data = encodeDescriptor(descriptor)
        // generate key
        let prefix = "public/descriptor/"
        let _key = prefix + key
        upload(data: data, key: _key)
    }
    
    /**
     Upload post to S3 using key.
     */
    func uploadPost(_ post: UIImage, key: String) {
        // generate data
        // compress image to 0.1x to increase upload/download speed
        guard let jpeg = UIImageJPEGRepresentation(post, 0.1) else {return}
        let data = jpeg.base64EncodedData(options: .lineLength64Characters)
        // generate key
        let prefix = "public/post/"
        let _key = prefix + key
        upload(data: data, key: _key)
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
        let prefix = "public/descriptor/"
        let downloadKey = prefix + key
        return Observable.create({ (observer) in
            print("downloadDescriptor() using key: \(key) ")
            
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
                if let error = error {
                    print("Error: \(error)")
                }
                
                if let _ = data {
                    
                    let descriptor = Descriptor(key: key, value: decodeForDescriptor(data!))
                    
                    observer.onNext(descriptor)
                    observer.onCompleted()
                }
                
                
            }
            
            // Download task
            self.transferUtility.downloadData(
                forKey: downloadKey,
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
        let prefix = "public/post/"
        let downloadKey = prefix + key
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
                if let error = error {
                    print("Error: \(error)")
                }
                
                if let _ = data {
                    let decoded: Data = Data(base64Encoded: data!, options: .ignoreUnknownCharacters)!
                    guard let post = UIImage(data: decoded) else {return}
                    
                    observer.onNext(post)
                    observer.onCompleted()
                    DynamoDBService.sharedInstance.incrementViews(key)
                }
                
                
            }
            
            // Download task
            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(
                forKey: downloadKey,
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

// Convert descriptor array to encoded data
fileprivate func encodeDescriptor(_ descriptor: [Double]) -> Data {
    let stringRepresentation = descriptor.map{ String($0) }.joined(separator: ",")
    let encodedString =
        stringRepresentation
            .data(using: String.Encoding.utf8)?
            .base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let data = Data(base64Encoded: encodedString!)
    return data!
}

// Decode data and convert to descriptory array
fileprivate func decodeForDescriptor(_ data: Data) -> [Double] {
    let decodedString = String(data: data, encoding: .utf8)
    return decodedString!.split(separator: ",").map { Double($0)! }
}


