//
//  ImageCache.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

final class ImageCache: NSCache<AnyObject, UIImage> {
    
    static let shared = ImageCache()
    
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
    
    subscript(key: String) -> UIImage? {
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
    
}
