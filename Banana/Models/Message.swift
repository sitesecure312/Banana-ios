//
//  Message.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class Message: NSObject
{
    var body = ""
    
    var activity_id = ""
    var activity = ""
    
    var owner_id = ""
    var avatar_owner = ""
    var name_owner = ""
    
    var receiver_id = ""
    var avatar_receiver = ""
    var name_receiver = ""
    
    var is_owner = false
    
    var avatar = ""
    var date = ""
    
    
    static func initWithDictionary(dict: Dictionary<String,AnyObject>) -> Message
    {
        let msg = Message()
        
        if let value = dict["body"]
        {
            msg.body = value as! String
        }
        
        if let value = dict["date"]
        {
            msg.date = value as! String
        }
        
        if let value = dict["is_owner"]
        {
            msg.is_owner = value as! Bool
        }
        
        if let value = dict["avatar"]
        {
            msg.avatar = String(format: "\(restApiUrl)%@", value as! String)
        }
        
//        if let value = dict["activity"]
//        {
//            msg.activity = value as! String
//        }
//        
//        
//        if let value = dict["is_owner"]
//        {
//            msg.is_owner = value as! Bool
//        }
//        
//        
//        if let value = dict["owner_id"]
//        {
//            msg.owner_id = String(format: "%d", value as! Int)
//        }
//        
//        if let value = dict["name_owner"]
//        {
//            msg.name_owner = value as! String
//        }
//        
//        if let value = dict["avatar_owner"]
//        {
//            msg.avatar_owner = String(format: "\(restApiUrl)%@", value as! String)
//        }
//        
//        
//        if let value = dict["receiver_id"]
//        {
//            msg.receiver_id = String(format: "%d", value as! Int)
//        }
//        
//        if let value = dict["name_receiver"]
//        {
//            msg.name_receiver = value as! String
//        }
//        
//        if let value = dict["avatar_receiver"]
//        {
//            msg.avatar_receiver = String(format: "\(restApiUrl)%@", value as! String)
//        }
//        
//        if let value = dict["message"]
//        {
//            msg.message = value as! String
//        }
//        
//        if let value = dict["date"]
//        {
//            msg.date = value as! String
//        }
        
        return msg
    }
    
    class func getMessagesForConversationServiceWithBlock(paramDict: [String:String], api_key: String, response:(messages: [Message], error: NSError?) -> Void)
    {
        let method = "messages"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var msgArray : [Message] = []
                
                let msgs = data?.valueForKey("messages") as! [Dictionary<String, AnyObject>]
                for dict in msgs
                {
                    let msg = Message.initWithDictionary(dict)
                    msgArray.append(msg)
                }
                
                response(messages: msgArray, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(messages: [], error: nil)
        })
        
        
    }
    
    class func sendMsgServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(sent: Bool, error: NSError?) -> Void)
    {
        let method = "sendmessage"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: paramsDict, constructingBodyWithBlock: { (formData) in
            
            for key in paramsDict.keys
            {
                let tempData = NSMutableData()
                tempData.appendData((paramsDict[key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                formData.appendPartWithFormData(tempData, name: key)
            }
            
            
            }, progress: { (progress) in
                
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                response(sent: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(sent: false, error: error)
        })
    }

}
