//
//  AppDelegate.swift
//  AB
//
//  Created by Cameron Bernhardt on 9/14/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if(UIScreen.main.bounds.height <= 480.0) { // Don't show status bar on 4s (not enough room)
            application.isStatusBarHidden = true
        }
        
        Parse.setApplicationId("WGmtjlRAoyLDAnsFkyAhM5YvuCA2cqeklcyBtwcz", clientKey: "I0iTjxmaBUQuRnOfu459KTxrGRQT0SDwB13MYG9a")
        
        // Register for Push Notifications
        if #available(iOS 8.0, *) {
            let notificationTypes: UIUserNotificationType = ([.alert, .badge, .sound])
            let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        } else {
            // Fallback on earlier versions
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
        return true
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstallation: PFInstallation = PFInstallation.current()
        currentInstallation.setDeviceTokenFrom(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Registration failed (probably because you can't use push in Simulator)
        print(error.localizedDescription, terminator: "")
    }
    
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : Any]) {
        PFPush.handle(userInfo)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

