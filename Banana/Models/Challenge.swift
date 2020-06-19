//
//  Challenge.swift
//  Banana
//
//  Created by musharraf on 4/20/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class Challenge: NSObject
{
    var ID = ""
    var name = ""
    
    static func initWithDictionary(dict: Dictionary<String,AnyObject>) -> Challenge
    {
        let challenge = Challenge()
        
        if let value = dict["id"]
        {
            challenge.ID = String(format: "%d", value as! Int)
        }
        
        if let value = dict["title"]
        {
            challenge.name = value as! String
        }
        
        return challenge
    }
    
    class func getChallengesServiceWithBlock(api_key: String, response:(challenges: [Challenge], error: NSError?) -> Void)
    {
        let method = "sports"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var chsArray : [Challenge] = []
                
                let chs = data?.valueForKey("activityTitles") as! [Dictionary<String, AnyObject>]
                for dict in chs
                {
                    let ch = Challenge.initWithDictionary(dict)
                    chsArray.append(ch)
                }
                
                response(challenges: chsArray, error: nil)
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(challenges: [], error: error)
        }
        
        
    }
}
