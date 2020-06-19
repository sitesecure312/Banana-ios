//
//  Conversation.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class Conversation: NSObject
{
    var ID = ""
    
    var activity_id = ""
    var activity = ""
    
    var owner_id = ""
    var avatar_owner = ""
    var name_owner = ""
    
    var receiver_id = ""
    var avatar_receiver = ""
    var name_receiver = ""
    
    var is_owner = false
    
    var message = ""
    var date = ""
    
    static func initWithDictionary(dict: Dictionary<String,AnyObject>) -> Conversation
    {
        let conv = Conversation()
        
        if let value = dict["conversation_id"]
        {
            conv.ID = String(format: "%d", value as! Int)
        }
        
        if let value = dict["activity_id"]
        {
            conv.activity_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["activity"]
        {
            conv.activity = value as! String
        }
        
        
        if let value = dict["is_owner"]
        {
            conv.is_owner = value as! Bool
        }
        
        
        if let value = dict["owner_id"]
        {
            conv.owner_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["name_owner"]
        {
            conv.name_owner = value as! String
        }
        
        if let value = dict["avatar_owner"]
        {
            conv.avatar_owner = String(format: "\(restApiUrl)%@", value as! String)
        }
        
        
        if let value = dict["receiver_id"]
        {
            conv.receiver_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["name_receiver"]
        {
            conv.name_receiver = value as! String
        }
        
        if let value = dict["avatar_receiver"]
        {
            conv.avatar_receiver = String(format: "\(restApiUrl)%@", value as! String)
        }
        
        if let value = dict["message"]
        {
            conv.message = value as! String
        }
        
        if let value = dict["date"]
        {
            conv.date = value as! String
        }
    
        return conv
    }
    
    class func getAllConversationsServiceWithBlock(api_key: String, response:(conversations: [Conversation], error: NSError?) -> Void)
    {
        let method = "conversations"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var convArray : [Conversation] = []
                
                let convs = data?.valueForKey("conversations") as! [Dictionary<String, AnyObject>]
                for dict in convs
                {
                    let con = Conversation.initWithDictionary(dict)
                    convArray.append(con)
                }
                
                response(conversations: convArray, error: nil)
                
        }, failure: { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(conversations: [], error: nil)
        })
        
        
    }
    
    class func getConversationByIDServiceWithBlock(paramDict: [String:String], api_key: String, response:(conv: Conversation?, error: NSError?) -> Void)
    {
        let method = "conversations"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                let tempArray = data?.valueForKey("conversations") as! [Dictionary<String, AnyObject>]
                if tempArray.count > 0
                {
                    let dict = tempArray[0]
                    let con = Conversation.initWithDictionary(dict)
                    response(conv: con, error: nil)
                }
                
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(conv: nil, error: nil)
        })
        
        
    }
    

}
