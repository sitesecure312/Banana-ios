//
//  ReachabilityManager.swift
//  Eet
//
//  Created by Yasir Ali on 30/06/2015.
//  Copyright (c) 2015 MenuSpring. All rights reserved.
//

import Foundation
//import ReachabilitySwift

class ReachabilityManager {
    
    private(set) var isConnected : Bool = false
    private(set) var isConnectedViaWiFi: Bool = false
    private(set) var isConnectedViaCellualar: Bool = false
    private(set) static var isConnectedErrorShow: Bool = false

    private var reachability : Reachability!


    static let notificationQ = dispatch_queue_create("ViewControllerNotificationQ", DISPATCH_QUEUE_CONCURRENT)

    static let sharedInstance = ReachabilityManager()
    
    static func isNetworkConnected() -> Bool
    {
        return sharedInstance.isConnected
    }
    
    private init()  {
        self.isConnected = false
        self.isConnectedViaCellualar = false
        self.isConnectedViaWiFi = false
        
        do{
            try self.reachability = Reachability()
        }
        catch   {
            print(error)
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    static func startMonitoring()  {
        
        let manager = self.sharedInstance
        do  {
            try manager.reachability.startNotifier()
            
            manager.reachability.whenReachable = { reachability in
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                    manager.isConnected = true
                    manager.isConnectedViaWiFi = true
                    manager.isConnectedViaCellualar = false
                    
                } else {
                    print("Reachable via Cellular")
                    manager.isConnected = true
                    manager.isConnectedViaCellualar = true
                    manager.isConnectedViaWiFi = false
                }
            }
            self.sharedInstance.reachability.whenUnreachable = { reachability in
                print("Not reachable")
                manager.isConnected = false
            }
            manager.isConnected = manager.reachability.isReachable()
            manager.isConnectedViaWiFi = manager.reachability.isReachableViaWiFi()
            manager.isConnectedViaCellualar = manager.reachability.isReachableViaWWAN()
        }   catch   {
            debugPrint(error)
        }
        
    }
        static func stopMonitoring()   {
        self.sharedInstance.reachability.stopNotifier()
    }
}
