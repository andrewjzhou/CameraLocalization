//
//  DynamoDbService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSDynamoDB
import RxSwift

class DynamoDBService {
    
    static let sharedInstance = DynamoDBService()
    private let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    
    private init() {}
    
    func create(key: String,  username: String) {
        let postItem: Posts = Posts()
        
        let keyParts = key.split(separator: "/")
        let location = String(keyParts[0]) + "/" + String(keyParts[1])
        
        postItem._key = key
        postItem._location = location
        postItem._username = username
        postItem._view_count = 0
        
        dynamoDbObjectMapper.save(postItem) { (error) in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        }
    }
    
    func query(_ locationString: String) -> Observable<[String]> {
        print("Querying using \(locationString)")
        let keyPublisher = PublishSubject<[String]>()
        
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
        dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
                keyPublisher.onCompleted()
            }
            
            if output != nil {
                var keySet = [String]()
                for item in output!.items {
                    let post = item as? Posts
                    if let key = post?._key {
                        keySet.append(key)
                    }
                }
                keyPublisher.onNext(keySet)
                keyPublisher.onCompleted()
            } else {
                keyPublisher.onCompleted()
            }
        }
        return keyPublisher.asObservable()
    }
    
    func incrementViews(_ key: String) {
        APIGatewayService.sharedInstance.DynamoDB_incrementViews(key)
    }
}
