//
//  Posts.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class Posts: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _key: String?
    var _creationDate: String?
    var _location: String?
    var _username: String?
    var _viewCount: NSNumber?
    
    class func dynamoDBTableName() -> String {
        
        return "postgame-mobilehub-1951513639-Posts"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_key"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_key" : "key",
            "_creationDate" : "creation_date",
            "_location" : "location",
            "_username" : "username",
            "_viewCount" : "view_count",
        ]
    }
}
