//
//  Constants.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/9/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import AWSS3
// MARK:- AWS
let AppSyncRegion: AWSRegionType = .USEast2
let AppSyncEndpointURL: URL = URL(string: "https://jvmekczlubgmld6cpnb6rpxxdm.appsync-api.us-east-2.amazonaws.com/graphql")!
let CognitoIdentityRegion: AWSRegionType = .USEast2
let CognitoIdentityRegionString = "us-east-2"
let database_name = "PostTable"
let S3Bucket = "postgame-userfiles-mobilehub-1951513639"

// MARK:- CLLocation
let BaseLocationUncertainty = 20.0
