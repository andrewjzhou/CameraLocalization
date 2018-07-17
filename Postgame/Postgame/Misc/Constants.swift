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
let CognitoAuthTokenStringKey = "CognitoAuthTokenString"
// MARK:- CLLocation
let BaseLocationUncertainty = 40.0

public enum ExceptionString: String {
    /// Thrown during sign-up when email is already taken.
    case aliasExistsException = "AliasExistsException"
    /// Thrown when a user is not authorized to access the requested resource.
    case notAuthorizedException = "NotAuthorizedException"
    /// Thrown when the requested resource (for example, a dataset or record) does not exist.
    case resourceNotFoundException = "ResourceNotFoundException"
    /// Thrown when a user tries to use a login which is already linked to another account.
    case resourceConflictException = "ResourceConflictException"
    /// Thrown for missing or bad input parameter(s).
    case invalidParameterException = "InvalidParameterException"
    /// Thrown during sign-up when username is taken.
    case usernameExistsException = "UsernameExistsException"
    /// Thrown when user has not confirmed his email address.
    case userNotConfirmedException = "UserNotConfirmedException"
    /// Thrown when specified user does not exist.
    case userNotFoundException = "UserNotFoundException"
}
