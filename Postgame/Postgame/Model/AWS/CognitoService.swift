//
//  CognitoService.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/16/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import AWSUserPoolsSignIn

func cognitoUpdatePreferredUsername(_ name: String, completion: @escaping (Bool) -> Void)  {
    var attributes = [AWSCognitoIdentityUserAttributeType]()
    let prefUsername = AWSCognitoIdentityUserAttributeType();
    prefUsername?.name = "preferred_username"
    prefUsername?.value = name // character limit
    attributes.append(prefUsername!)
    AWSCognitoIdentityUserPool.default().currentUser()?.update(attributes).continueWith(block: { (task) -> Any? in
        if let _ = task.error {
            completion(false)
        } else {
            completion (true)
        }
        return nil
    })
}

func cognitoUpdatePhoneNumber(_ number: String, completion: @escaping (Bool) -> Void) {
    var attributes = [AWSCognitoIdentityUserAttributeType]()
    let phoneNum = AWSCognitoIdentityUserAttributeType();
    phoneNum?.name = "phone_number"
    phoneNum?.value = number // character limit
    attributes.append(phoneNum!)
    AWSCognitoIdentityUserPool.default().currentUser()?.update(attributes).continueWith(block: { (task) -> Any? in
        if let _ = task.error {
            completion(false)
        } else {
            completion (true)
        }
        return nil
    })
}

func cognitoUpdateEmail(_ email: String, completion: @escaping (Bool) -> Void) {
    var attributes = [AWSCognitoIdentityUserAttributeType]()
    let emailUpdate = AWSCognitoIdentityUserAttributeType();
    emailUpdate?.name = "email"
    emailUpdate?.value = email // character limit
    attributes.append(emailUpdate!)
    AWSCognitoIdentityUserPool.default().currentUser()?.update(attributes).continueWith(block: { (task) -> Any? in
        if let _ = task.error {
            completion(false)
        } else {
            completion (true)
        }
        return nil
    })
}
