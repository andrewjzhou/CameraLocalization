//
//  AppDelegate.swift
//  project
//
//  Created by Andrew Jay Zhou on 1/28/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import AWSMobileClient
import Fabric
import Crashlytics
import AWSUserPoolsSignIn
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class func defaultUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    let signInViewController = SignInViewController()
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    
    // Add a AWSMobileClient call in application:open url
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {

        return AWSMobileClient.sharedInstance().interceptApplication(
            application, open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)

    }
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Crashlytics
        Fabric.with([Crashlytics.self])
        self.logUser()
        // Use below method to crash
//        Crashlytics.sharedInstance().crash()
        
        self.navigationController = UINavigationController(rootViewController: signInViewController)
        
        // AWS User Pool
        setupCognitoUserPool()
        
//        navigationController.setNavigationBarHidden(true, animated: false)
//        navigationController.pushViewController(signInViewController, animated: false)
//
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = ViewController()
        window!.makeKeyAndVisible()
        
        
        // Create AWSMobileClient to connect with AWS
//        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func setupCognitoUserPool() {
        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast2, credentialsProvider: nil)
        
        // create pool configuration
        let defaultConfig = AWSCognitoIdentityUserPool.default().userPoolConfiguration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "4nqp3rhguigq5n5sm5eeelf3hk",
                                                                        clientSecret: "1qgt9n0ijabuqvllppr2d3jg6t3ef0evhhnut2jbhsp63r8ek81s",
                                                                        poolId: "us-east-2_a0pr7d57s")
        
        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        // fetch the user pool client we initialized in above step
        let pool:AWSCognitoIdentityUserPool = AppDelegate.defaultUserPool()
        pool.delegate = self
    }
    
   
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
//        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
//        Crashlytics.sharedInstance().setUserIdentifier("12345")
        if let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username {
            Crashlytics.sharedInstance().setUserName(username)
        }
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //        let visibleViewController = self.topViewController(withRootViewController: window?.rootViewController)
        //
        //        // Support only portrait orientation for a specific view controller
        //        if visibleViewController is SomeViewController {
        //            return .portrait
        //        }
        //
        //        // Otherwise, support all orientations (standard behaviour)
        //        return .allButUpsideDown
        return .portrait
    }
}

// MARK:- AWSCognitoIdentityInteractiveAuthenticationDelegate protocol delegate

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if (!self.navigationController!.isViewLoaded || self.navigationController!.view.window == nil) {
                self.window?.rootViewController?.present(self.navigationController!,
                                                         animated: false,
                                                         completion: nil)
            }
            
        }
        return self.signInViewController
    }
    //
    //    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
    //        if (self.mfaViewController == nil) {
    //            self.mfaViewController = MFAViewController()
    //            self.mfaViewController?.modalPresentationStyle = .popover
    //        }
    //        DispatchQueue.main.async {
    //            if (!self.mfaViewController!.isViewLoaded
    //                || self.mfaViewController!.view.window == nil) {
    //                //display mfa as popover on current view controller
    //                let viewController = self.window?.rootViewController!
    //                viewController?.present(self.mfaViewController!,
    //                                        animated: true,
    //                                        completion: nil)
    //
    //                // configure popover vc
    //                let presentationController = self.mfaViewController!.popoverPresentationController
    //                presentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
    //                presentationController?.sourceView = viewController!.view
    //                presentationController?.sourceRect = viewController!.view.bounds
    //            }
    //        }
    //        return self.mfaViewController!
    //    }
    //
    func startRememberDevice() -> AWSCognitoIdentityRememberDevice {
        return self
    }
}

// MARK:- AWSCognitoIdentityRememberDevice protocol delegate

extension AppDelegate: AWSCognitoIdentityRememberDevice {
    
    func getRememberDevice(_ rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>) {
        self.rememberDeviceCompletionSource = rememberDeviceCompletionSource
        DispatchQueue.main.async {
            // dismiss the view controller being present before asking to remember device
            self.window?.rootViewController!.presentedViewController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Remember Device",
                                                    message: "Do you want to remember this device?.",
                                                    preferredStyle: .actionSheet)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: false)
            })
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
