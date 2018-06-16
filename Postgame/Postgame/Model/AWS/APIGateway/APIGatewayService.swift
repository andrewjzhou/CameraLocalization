//
//  AWSAPIService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSCore
import AWSAPIGateway
import AWSMobileClient

class APIGatewayService {
    static let sharedInstance = APIGatewayService()
    private init() {}
    
    func DynamoDB_incrementViews(_ key: String) {
        // change the method name, or path or the query string parameters here as desired
        let httpMethodName = "POST"
        // change to any valid path you configured in the API
        let URLString = "/posts"
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Request
        let queryStringParameters = ["action":"increment"]
        let httpBody = ["key" : key]

        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: httpBody)
        
        
        // Create a service configuration object for the region your AWS API was created in
        let serviceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast2,
            credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        
        AWSAPI_QJVZDPTXRF_PostManagementMobileHubClient.register(with: serviceConfiguration!, forKey: "CloudLogicAPIKey")
        
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient =
            AWSAPI_QJVZDPTXRF_PostManagementMobileHubClient(forKey: "CloudLogicAPIKey")
        
        invocationClient.invoke(apiRequest).continueWith { (
            task: AWSTask) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString =
                String(data: result.responseData!, encoding: .utf8)
            
//            print(responseString)
//            print(result.statusCode)
            
            return nil
        }
    }
}


