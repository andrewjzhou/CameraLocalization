//
//  DynamoDbService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSDynamoDB
import AWSUserPoolsSignIn
import RxSwift
import RxCocoa

struct DynamoDBService {
    
    static let sharedInstance = DynamoDBService()
    private let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    
    private init() {}
    
    /// Mark:- Posts
    func create(key: String,  username: String) {
        let postItem: Posts = Posts()
        
        let keyParts = key.split(separator: "/")
        let location = String(keyParts[0]) + "/" + String(keyParts[1])
        
        postItem._key = key
        postItem._location = location
        postItem._username = username
        postItem._viewCount = 0
        postItem._creationDate = recordDate()
        
        dynamoDbObjectMapper.save(postItem) { (error) in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        }
    }
    
    func locationQuery(_ locationString: String) -> Observable<String> {
        return Observable.create({ [dynamoDbObjectMapper] observer in
            // 1) Configure the query
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.indexName = "location"
            queryExpression.keyConditionExpression = "#_location = :_location"
            
            queryExpression.expressionAttributeNames = [
                "#_location": "location",
            ]
            queryExpression.expressionAttributeValues = [
                ":_location": locationString,
            ]
            
            
            // 2) Make the query
            DispatchQueue.global(qos: .userInitiated).async {
                dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
                    if error != nil {
                        print("The request failed. Error: \(String(describing: error))")
                        observer.onCompleted()
                    }
                    
                    if output != nil {
                        for item in output!.items {
                            let post = item as? Posts
                            if let key = post?._key {
                                observer.onNext(key)
                            }
                        }
                    }
                    observer.onCompleted()
                    
                }
            }
            return Disposables.create()
        })
    }
    
    func usernameQuery(_ username: String) -> Observable<[Posts]> {
       
        let publisher = PublishSubject<[Posts]>()
        
        // 1) Configure the query
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "username"
        queryExpression.keyConditionExpression = "#_username = :_username"
        
        queryExpression.expressionAttributeNames = [
            "#_username": "username",
        ]
        queryExpression.expressionAttributeValues = [
            ":_username": username,
        ]
        
        
        // 2) Make the query
        dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
                publisher.onCompleted()
            }
            
            if output != nil {
                if let posts = output!.items as? [Posts] {
                    for post in posts {
                        print("DOWNLOADED", post._key!)
                    }
                    publisher.onNext(posts)
                }
                publisher.onCompleted()
            } else {
                publisher.onCompleted()
            }
        }
        return publisher.asObservable()
    }
    
    func incrementViews(_ key: String) {
        print("Incrementing Views")
        APIGatewayService.sharedInstance.DynamoDB_incrementViews(key)
    }
    
    /// Mark:- ViewCount
    func registerUser(_ id: String) {
        let vcItem: ViewCount = ViewCount()
        
        vcItem._userId = id
        
        // recents initialization
        vcItem._recent1Key = "nil"
        vcItem._recent1Date = "nil"
        vcItem._recent1Views = NSNumber(value: 0)
        vcItem._recent2Key = "nil"
        vcItem._recent2Date = "nil"
        vcItem._recent2Views = NSNumber(value: 0)
        vcItem._recent3Key = "nil"
        vcItem._recent3Date = "nil"
        vcItem._recent3Views = NSNumber(value: 0)
        vcItem._recent4Key = "nil"
        vcItem._recent4Date = "nil"
        vcItem._recent4Views = NSNumber(value: 0)
        vcItem._recent5Key = "nil"
        vcItem._recent5Date = "nil"
        vcItem._recent5Views = NSNumber(value: 0)
        
        // tops initialization
        vcItem._top1Key = "nil"
        vcItem._top1Date = "nil"
        vcItem._top1Views = NSNumber(value: 0)
        vcItem._top2Key = "nil"
        vcItem._top2Date = "nil"
        vcItem._top2Views = NSNumber(value: 0)
        vcItem._top3Key = "nil"
        vcItem._top3Date = "nil"
        vcItem._top3Views = NSNumber(value: 0)
        vcItem._top4Key = "nil"
        vcItem._top4Date = "nil"
        vcItem._top4Views = NSNumber(value: 0)
        vcItem._top5Key = "nil"
        vcItem._top5Date = "nil"
        vcItem._top5Views = NSNumber(value: 0)
        
        // total initialization
        vcItem._totalViews = NSNumber(value: 0)
        
        dynamoDbObjectMapper.save(vcItem) { (error) in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                print("Amazon DynamoDB Save Error: \(vcItem)")
            
                return
            }
            print("ViewCont: An item was saved.")
        }
    }
    
    func viewCountQuery(_ userId: String) -> Driver<ViewCount?> {
        let publisher = PublishSubject<ViewCount?>()
        
        // 1) Configure the query
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#_userId = :_userId"
        
        queryExpression.expressionAttributeNames = [
            "#_userId": "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":_userId": userId,
        ]
        
        
        // 2) Make the query
        dynamoDbObjectMapper.query(ViewCount.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
                publisher.onCompleted()
            }
            
            if output != nil {
                for item in output!.items {
                    if let vc = item as? ViewCount {
                        publisher.onNext(vc)
                    }
                }
            }
            publisher.onCompleted()
        }
        
        return publisher.asDriver(onErrorJustReturn: nil)
    }
    
}
