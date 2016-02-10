//
//  AppDelegate.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/11/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    var window: UIWindow?
    var navigation : UINavigationController!

    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Registers our custom Parse Modals
        Category.registerSubclass()
        SubCategory.registerSubclass()
        Question.registerSubclass()
        Challenge.registerSubclass()
        Game.registerSubclass()
        
        // Sets our app to a specific Parse Project
        Parse.enableLocalDatastore()
        Parse.setApplicationId("QART5eXws8zvXOmWQJIxlRDy0WiyOaCktpymTKzE", clientKey:"vVCNh2voxo8e8Xeik14wTdiGKUkXABZx0HRyw3gL")
        
        // Customize navigation bar for every screen globally
        UINavigationBar.appearance().barTintColor = UIColor(red: 16.0/255.0, green: 90.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        /* Will set write to private for any object created by the current user
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        */
        
//        if application.respondsToSelector("registerUserNotificationSettings:") {
//            let userNotificationType = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//            
//            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//            
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            let types = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//            
//            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
//        }
        
        var storyboard : UIStoryboard!
        if IS_iPad {
            storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
        } else {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        IQKeyboardManager.sharedManager().enable = true
        
        navigation = storyboard.instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.makeKeyAndVisible()
        navigation.view.frame = window!.bounds
        self.window!.rootViewController = navigation
        self.window!.becomeFirstResponder()
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(kTimer) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kTimer)
        }
        if (NSUserDefaults.standardUserDefaults().valueForKey(kSound) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kSound)
        }
        if (NSUserDefaults.standardUserDefaults().valueForKey(kVibrate) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kVibrate)
        }
        
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(kFiftyFiftyCount) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("5" as String, forKey: kFiftyFiftyCount)
        }
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(kSkipCount) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("5" as String, forKey: kSkipCount)
        }
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(kTimerCount) == nil) {
            NSUserDefaults.standardUserDefaults().setValue("5" as String, forKey: kTimerCount)
        }
        
        // Override point for customization after application launch.
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

