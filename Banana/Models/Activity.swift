//
//  Activity.swift
//  Banana
//
//  Created by musharraf on 4/19/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class Activity: NSObject
{
    var ID = ""
    var name = ""
    var date = ""
    var time = ""
    var activity_challange = ""
    var desc = ""
    var participants = ""
    var age = ""
    var skill = ""
    var gender = ""
    var owner_id = ""
    var latitude = 0.0
    var longitude = 0.0
    var formatted_address = ""
    var sports_title = ""
    var avatar = ""
    var sports_id = ""
    var request_status = ""
    var user_message = ""
    var sponsored = 0
    var is_owner = false
    
    static func initWithDictionary(dict: Dictionary<String, AnyObject>) -> Activity
    {
        let activty = Activity()
        
        if let value = dict["activity_id"]
        {
            activty.ID = String(format: "%d", value as! Int)
        }
        
        if let value = dict["date"]
        {
            activty.date = value as! String
        }
        
        if let value = dict["time"]
        {
            activty.time = value as! String
        }
        
        if let value = dict["activity"]
        {
            activty.activity_challange = value as! String
        }
        
        if let value = dict["description"]
        {
            activty.desc = value as! String
        }
        
        if let value = dict["number"]
        {
            activty.participants = value as! String
        }
        
        if let value = dict["start_age"]
        {
            activty.age = value as! String
        }
        
        if let value = dict["skill"]
        {
            activty.skill = value as! String
        }
        
        if let value = dict["gender"]
        {
            activty.gender = value as! String
        }
        
        if let value = dict["latitude"]
        {
            activty.latitude = value as! Double
        }
        
        if let value = dict["longitude"]
        {
            activty.longitude = value as! Double
        }
        
        if let value = dict["formatted_address"]
        {
            activty.formatted_address = value as! String
        }
        
        if let value = dict["sports_title"]
        {
            activty.sports_title = value as! String
        }

        if let value = dict["name"]
        {
            activty.name = value as! String
        }
        
        if let value = dict["avatar"]
        {
            activty.avatar = String(format: "\(restApiUrl)%@", value as! String)
        }
        
        if let value = dict["owner_id"]
        {
            activty.owner_id = String(format: "%d", value as! Int)
        }

        if let value = dict["sports_id"]
        {
            activty.sports_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["category_id"]
        {
            activty.sports_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["request_status"]
        {
            if !(value is NSNull)
            {
                activty.request_status = String(format: "%d", value as! Int)
            }
        }
        
        if let value = dict["user_message"]
        {
            if !(value is NSNull)
            {
                activty.user_message = value as! String
            }
        }
        
        if let value = dict["user_id"]
        {
            if !(value is NSNull)
            {
                activty.user_message = value as! String
            }
        }
        if let value = dict["sponsored"]
        {

            activty.sponsored = value as! Int
        }
        if let value = dict["is_owner"]
        {
            if !(value is NSNull)
            {
                activty.is_owner = value as! Bool
            }
        }
        
        return activty
    }
    
    class func createActivityServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(activity_id: String,created: Bool, error: NSError?) -> Void)
    {
        let method = "activity"
        
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
                let activity_id = numberFormater.stringFromNumber((data?.objectForKey("activity_id"))! as! NSNumber)
                response(activity_id: activity_id!,created: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(activity_id: "0",created: false, error: error)
        })
    }
    
    class func getActivitiesServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(activities: [Activity], error: NSError?) -> Void)
    {
        let method = "activities"
        
        let urlString = "\(restApiUrl)\(method)"
        
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: paramsDict, constructingBodyWithBlock: { (formData) in
            
            if paramsDict?.keys.count > 0
            {
                for key in paramsDict!.keys
                {
                    let tempData = NSMutableData()
                    tempData.appendData((paramsDict![key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                    formData.appendPartWithFormData(tempData, name: key)
                }
            }
            
            
            }, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var actArray : [Activity] = []
                
                let acts = data?.valueForKey("activities") as! [Dictionary<String, AnyObject>]
                for dict in acts
                {
                    let act = Activity.initWithDictionary(dict)
                    actArray.append(act)
                }
                
                response(activities: actArray, error: nil)
                
        }, failure: { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(activities: [], error: error)
        })
        
    }
    
    class func getOtherUserActivitiesServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(activities: [Activity], error: NSError?) -> Void)
    {
        let method = "profileactivities"
        let urlString = "\(restApiUrl)\(method)"

        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramsDict, progress: { (progress) in
                
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var actArray : [Activity] = []
                
                let acts = data?.valueForKey("activities") as! [Dictionary<String, AnyObject>]
                for dict in acts
                {
                    let act = Activity.initWithDictionary(dict)
                    actArray.append(act)
                }
                
                response(activities: actArray, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(activities: [], error: error)
        })
        
        
    }
    
    class func getActDetailServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(activity: Activity?, error: NSError?) -> Void)
    {
        let method = "getactivity"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramsDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                            
                let act = Activity.initWithDictionary(data?.valueForKey("activities") as! Dictionary<String, AnyObject>)
                //print(act);
                
                response(activity: act, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(activity: nil, error: nil)
        })
        
        
    }
    
    class func askToJoinServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(success: Bool , error: NSError?) -> Void)
    {
        let method = "joinrequest"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: paramsDict, constructingBodyWithBlock: { (formData) in
            
            if paramsDict?.keys.count > 0
            {
                for key in paramsDict!.keys
                {
                    let tempData = NSMutableData()
                    tempData.appendData((paramsDict![key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                    formData.appendPartWithFormData(tempData, name: key)
                }
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
    
    class func cancelRequestServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(success: Bool , error: NSError?) -> Void)
    {
        let method = "cancelrequest"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: paramsDict, constructingBodyWithBlock: { (formData) in
            
            if paramsDict?.keys.count > 0
            {
                for key in paramsDict!.keys
                {
                    let tempData = NSMutableData()
                    tempData.appendData((paramsDict![key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                    formData.appendPartWithFormData(tempData, name: key)
                }
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
    
    class func getMyActivitiesServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(allActivities: [[Activity]] , error: NSError?) -> Void)
    {
        let method = "myactivities"
        
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
                        var toBeReturnedAllActs : [[Activity]] = []
                        
                        var tempArray : [Activity] = []
                        
                        let pending = data?.valueForKey("pendingactivities") as! [Dictionary<String, AnyObject>]
                        for dict in pending
                        {
                            let act = Activity.initWithDictionary(dict)
                            tempArray.append(act)
                        }
                        toBeReturnedAllActs.append(tempArray)
                        
                        
                        tempArray = []
                        
                        let current = data?.valueForKey("currentactivities") as! [Dictionary<String, AnyObject>]
                        for dict in current
                        {
                            let act = Activity.initWithDictionary(dict)
                            tempArray.append(act)
                        }
                        toBeReturnedAllActs.append(tempArray)
                        
                        
                        tempArray = []
                        
                        let followed = data?.valueForKey("followedactivities") as! [Dictionary<String, AnyObject>]
                        for dict in followed
                        {
                            let act = Activity.initWithDictionary(dict)
                            tempArray.append(act)
                        }
                        toBeReturnedAllActs.append(tempArray)
                        
                        
                        tempArray = []
                        let past = data?.valueForKey("pastactivities") as! [Dictionary<String, AnyObject>]
                        for dict in past
                        {
                            let act = Activity.initWithDictionary(dict)
                            tempArray.append(act)
                        }
                        toBeReturnedAllActs.append(tempArray)
                        
                        
                        
                        response(allActivities: toBeReturnedAllActs, error: nil)
                    }
                    
                    else
                    {
                        response(allActivities: [], error: nil)
                    }
                }
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(allActivities: [], error: error)
        })
        
    }
    
    class func getActivityRequestsServiceWithBlock(paramsDict: [String : String]? , api_key: String, response:(allActivities: [[Activity]] , error: NSError?) -> Void)
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
                        var toBeReturnedAllActs : [[Activity]] = []
                        
                        if let requests = data?.valueForKey("requests") as? Dictionary<String, [AnyObject]>
                        {
                            var tempArray : [Activity] = []
                            
                            if let pending = requests["pending"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in pending
                                {
                                    let act = Activity.initWithDictionary(dict)
                                    tempArray.append(act)
                                }
                                toBeReturnedAllActs.append(tempArray)
                            }
                            
                            tempArray = []
                            
                            if let accepted = requests["accepted"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in accepted
                                {
                                    let act = Activity.initWithDictionary(dict)
                                    tempArray.append(act)
                                }
                                toBeReturnedAllActs.append(tempArray)
                            }
                            
                            tempArray = []
                            
                            if let rejected = requests["rejected"] as? [Dictionary<String, AnyObject>]
                            {
                                for dict in rejected
                                {
                                    let act = Activity.initWithDictionary(dict)
                                    tempArray.append(act)
                                }
                                toBeReturnedAllActs.append(tempArray)
                            }
                            
                            response(allActivities: toBeReturnedAllActs, error: nil)
                            
                        }
                    }
                        
                    else
                    {
                        response(allActivities: [], error: nil)
                    }
                }
                
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(allActivities: [], error: error)
        })
        
    }
    static let numberFormater: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.formatterBehavior = .BehaviorDefault
        return formatter
    }()
    class func deleteActivityServiceWithBlock(paramsDict: [String : String] , api_key: String, response:(message: String, deleted: Bool , error: NSError?) -> Void)
    {
        let method = "deleteactivity"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: nil, constructingBodyWithBlock: { (formData) in
            
            for key in paramsDict.keys
            {
                let tempData = NSMutableData()
                tempData.appendData((paramsDict[key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                formData.appendPartWithFormData(tempData, name: key)
            }
            
            
            }, progress: { (progress) in
                
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                let message = data?.objectForKey("message") as? String
                response(message: message!,deleted: true, error: nil)
                
            }, failure: { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(message: "Failed to delete activity",deleted: false, error: error)
        })
    }
}
