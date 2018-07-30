//
//  AWSError.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/24/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation

enum AWSError: Error {
    case s3UploadError
    case appSyncCreateError
    case appSyncGetUserError
    case noResultFound
}
