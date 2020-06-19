//
//  AppDelegate.swift
//  Banana
//
//  Created by musharraf on 4/13/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit

let restApiUrl: String = "https://thebananaapp.com/restapi/";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Check if launched from notification
        // 1
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject]
        {
            // 2
            print(notification)
        }
        
        
        // Override point for customization after application launch.
        
        registerForPushNotifications(application)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        
        GMSServices.provideAPIKey("AIzaSyDjTVLy8HpvKA_nGz9_2PEjUj8FapG5iyA")

        LocationManager.startMonitoring()
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LocationManager.stopMonitoring()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func registerForPushNotifications(application: UIApplication)
    {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings)
    {
        if notificationSettings.types != .None
        {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length
        {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(tokenString, forKey: "tokenString")
        defaults.synchronize()
        
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        print("Failed to register:", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        let state = UIApplication.sharedApplication().applicationState
        
        
        print(userInfo)
        let aps = userInfo["aps"] as! [String: AnyObject]
        let data = aps["data"] as! [String: AnyObject]
        let type = data["type"] as! String
        var ID = ""
        
        if let value = data["id"]
        {
            if value is String
            {
                ID = value as! String
            }
            else if value is Int
            {
                ID = String(format: "%d", value as! Int)
            }
        }
        
        switch type
        {
        case "activity_request":
            
            switch state
            {
            case .Background:
                print("app is in background")
                
                //activity_request
                print("go to actdetail")
                
                NSNotificationCenter.defaultCenter().postNotificationName("viewActivityDetail", object: nil, userInfo: ["id":ID])
                
            case .Active:
                print("app is in Active")
                
                
                
            case .Inactive:
                print("app is in Inactive")
                
                // lets test it for inactive state, on same
                print("go to actdetail")
                let ID = data["id"] as! String
                NSNotificationCenter.defaultCenter().postNotificationName("viewActivityDetail", object: nil, userInfo: ["id":ID])
            default:
                print("app is in unknown state")
            }
            
            
            
        case "friend_follow":
            print("go to tabbar ind 2")
            switch state
            {
            case .Background:
                print("app is in background")
                
                print("go to this user's profile")
                
                NSNotificationCenter.defaultCenter().postNotificationName("userSubscribed", object: nil, userInfo: ["id":ID])
                
            case .Active:
                print("app is in Active")
                
                
            case .Inactive:
                print("app is in Inactive")
                
                // lets test it for inactive state, on same
                
                print("go to messagesVC")
                
                NSNotificationCenter.defaultCenter().postNotificationName("userSubscribed", object: nil, userInfo: ["id":ID])
            default:
                print("app is in unknown state")
            }
            
            
            
        case "message":
            
            switch state
            {
            case .Background:
                print("app is in background")
                
                print("go to messagesVC")
                
                NSNotificationCenter.defaultCenter().postNotificationName("msgReceivedForConversation", object: nil, userInfo: ["id":ID])
                
            case .Active:
                print("app is in Active")
                
                
            case .Inactive:
                print("app is in Inactive")
                
                // lets test it for inactive state, on same
                
                print("go to messagesVC")
                
                NSNotificationCenter.defaultCenter().postNotificationName("msgReceivedForConversation", object: nil, userInfo: ["id":ID])
            default:
                print("app is in unknown state")
            }
            
            
        default:
            print("this key needs handler")
        }
        
        
    }
    
}

