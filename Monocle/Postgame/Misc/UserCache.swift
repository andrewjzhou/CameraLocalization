//
//  UserCache.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/20/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

final class UserCache: NSCache<AnyObject, AnyObject> {
    static let shared = UserCache()
    
    
    /// Observer for `UIApplicationDidReceiveMemoryWarningNotification`.
    
    private var memoryWarningObserver: NSObjectProtocol!
    
    /// Note, this is `private` to avoid subclassing this; singletons shouldn't be subclassed.
    ///
    /// Add observer to purge cache upon memory pressure.
    
    private override init() {
        super.init()
        
        memoryWarningObserver = NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [weak self] notification in
            self?.removeAllObjects()
        }
    }
    
    /// The singleton will never be deallocated, but as a matter of defensive programming (in case this is
    /// later refactored to not be a singleton), let's remove the observer if deallocated.
    
    deinit {
        NotificationCenter.default.removeObserver(memoryWarningObserver)
    }
    
    /// Subscript operation to retrieve and update
    
    subscript(key: String) -> AnyObject? {
        get {
            return object(forKey: key as AnyObject)
        }
        
        set (newValue) {
            if let object = newValue {
                setObject(object, forKey: key as AnyObject)
            } else {
                removeObject(forKey: key as AnyObject)
            }
        }
    }
    
    func cacheUserInfo(completion: @escaping (AWSError?) -> Void = { _ in }) {
        if UserCache.shared[UserCacheKey.username.rawValue] == nil || UserCache.shared[UserCacheKey.phone.rawValue] == nil  {
            if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
                AppSyncService.sharedInstance.cacheUserInfo(username: username, completion: { error in
                    completion(error)
                })
            } else {
                completion(.appSyncGetUserError)
            }
        } else {
            completion(nil)
        }
    }
    
}

enum UserCacheKey: String {
    case username = "username"
    case phone = "phone"
    case email = "email"
    case name = "name"
}

