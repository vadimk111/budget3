//
//  AppDelegate.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FBSDKCoreKit

let APP: AppDelegate = UIApplication.shared.delegate as! AppDelegate
let userNotificationCenterAuthorizationChangedNotification = Notification.Name(rawValue: "UNCACNot")
let appPrefix = "doctor.budget://"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var user: User?
    var automaticAuthenticationCompleted = false
    var notificationsAllowed = false
    var dbToShare: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        registerCategory()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func registerCategory() {
        let clear = UNNotificationAction(identifier: "clear", title: "Clear", options: [])
        let category = UNNotificationCategory.init(identifier: reminderNotification, actions: [clear], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if self.notificationsAllowed != granted {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: userNotificationCenterAuthorizationChangedNotification))
                }
            }
            self.notificationsAllowed = granted
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let absoluteUrl = url.absoluteString
        if absoluteUrl.range(of: appPrefix) != nil {
            dbToShare = absoluteUrl.substring(from: absoluteUrl.index(absoluteUrl.startIndex, offsetBy: appPrefix.characters.count))
            
            if automaticAuthenticationCompleted {
                onSignInStateChanged()
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
            }
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func onSignInStateChanged() {
        NotificationCenter.default.removeObserver(self, name: signInStateChangedNotification, object: nil)
        
        if let dbId = dbToShare {
            if let ref = ModelHelper.sharingReference() {
                let sharing = Sharing()
                sharing.dbId = dbId
                sharing.insert(into: ref)
                
                APP.user?.loadSharing {
                    NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
                }
            } else {
                let a = UIAlertController(title: "", message: "Account sharing allowed only for signed-in users", preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in })
                if let top = window?.rootViewController?.presentedViewController {
                    top.present(a, animated: true, completion: nil)
                } else {
                    window?.rootViewController?.present(a, animated: true, completion: nil)
                }
            }
            dbToShare = nil
        }
    }
}

