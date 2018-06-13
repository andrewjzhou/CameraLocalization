//
//  AWSDynamoDbService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/13/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSCore
import AWSDynamoDB

class AWSDynamoDBService {
    static let sharedInstance = AWSDynamoDBService()
    
//    private let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    
    private init() {}
    
    func query() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // 1) Configure the query
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#key = :key"
        
        queryExpression.expressionAttributeNames = [
            "#key": "key",
        ]
        queryExpression.expressionAttributeValues = [
            ":key": "testing/abc/1/",
        ]
        
        // 2) Make the query
        dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            print("querying")
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
            }
            if output != nil {
                for item in output!.items {
                    let post = item as? Posts
                    print("\(post?._key)")
                }
            }
        }
    }
    
    
}
