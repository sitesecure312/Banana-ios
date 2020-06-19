//
//  ActRequest.swift
//  Banana
//
//  Created by musharraf on 5/3/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class ActRequest: NSObject
{
    var ID = ""
    var about_me = ""
    var activity_id = ""
    var avatar = ""
    var name = ""
    var status = false
    var user_id = ""
    var user_message = ""
    
    static func initWithDictionary(dict: Dictionary<String, AnyObject>) -> ActRequest
    {
        let req = ActRequest()
        
        if let value = dict["id"]
        {
            req.ID = String(format: "%d", value as! Int)
        }
        
        if let value = dict["activity_id"]
        {
            req.activity_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["user_id"]
        {
            req.user_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["about_me"]
        {
            req.about_me =  value as! String
        }
        
        if let value = dict["avatar"]
        {
            req.avatar = String(format: "\(restApiUrl)%@", value as! String)
        }
        
        if let value = dict["name"]
        {
            req.name =  value as! String
        }
        
        if let value = dict["user_message"]
        {
            if !(value is NSNull)
            {
                req.user_message =  value as! String
            }
        }
        
        return req
    }
    
    class func getActivityRequestsServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(allActRequests: [[ActRequest]] , error: NSError?) -> Void)
    {
        let method = "activityrequests"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramsDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                if let error = data?.valueForKey("error")
                {
                    if error as! Bool == false
                    {
                        var toBeReturned : [[ActRequest]] = []
                        
                        if let requests = data?.valueForKey("requests") as? Dictionary<String, [AnyObject]>
                        {
                            var tempArray : [ActRequest] = []
                            
                            if let pending = requests["pending"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in pending
                                {
                                    let req = ActRequest.initWithDictionary(dict)
                                    tempArray.append(req)
                                }
                                toBeReturned.append(tempArray)
                            }
                            
                            tempArray = []
                            
                            if let accepted = requests["accepted"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in accepted
                                {
                                    let req = ActRequest.initWithDictionary(dict)
                                    tempArray.append(req)
                                }
                                toBeReturned.append(tempArray)
                            }
                            
                            tempArray = []
                            
                            if let rejected = requests["rejected"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in rejected
                                {
                                    let req = ActRequest.initWithDictionary(dict)
                                    tempArray.append(req)
                                }
                                toBeReturned.append(tempArray)
                            }
                            
                            response(allActRequests: toBeReturned, error: nil)
                            
                        }
                    }
                        
                    else
                    {
                        response(allActRequests: [], error: nil)
                    }
                }
                
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(allActRequests: [], error: error)
        })
        
    }

    class func acceptActRequestServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(success: Bool, error: NSError?) -> Void)
    {
        let method = "acceptactivity"
        
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
                
                response(success: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(success: false, error: error)
        })
    }
    
    class func messageFromOwnerForActRequestServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(success: Bool, error: NSError?) -> Void)
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
                
                response(success: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(success: false, error: error)
        })
    }
    
    class func rejectActRequestServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(success: Bool, error: NSError?) -> Void)
    {
        let method = "rejectactivity"
        
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
                
                response(success: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(success: false, error: error)
        })
    }
    
    class func cancelAcceptedActRequestServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(success: Bool, error: NSError?) -> Void)
    {
        let method = "cancelactivity"
        
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
                
                response(success: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(success: false, error: error)
        })
    }
    
    class func deleteRejectedActRequestServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(success: Bool, error: NSError?) -> Void)
    {
        let method = "deleterequest"
        
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
                
                response(success: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(success: false, error: error)
        })
    }
    
    
    
    
}
