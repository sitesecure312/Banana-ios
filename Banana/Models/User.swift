//
//  User.swift
//  Banana
//
//  Created by musharraf on 4/13/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class User: NSObject
{
    var user_id = ""
    var username = ""
    var age = ""
    var gender = ""
    var about_me = ""
    var subscribe = ""
    var api_key = ""
    var image = ""
    var largeimage = ""
    var email = ""
    var password = ""
    var latitude = ""
    var longitude = ""
    var city = ""
    var country = ""
    var formatted_address = ""
    var fb_id = ""
    var tw_id = ""
    
    
    static func initWithAnyDictionary(dict: Dictionary<String,AnyObject>) -> User
    {
        let user = User()
        
        if let value = dict["apiKey"]
        {
            user.api_key = value as! String
        }
        
        if let value = dict["id"]
        {
            user.user_id = String(format: "%d", value as! Int)
        }
        
        if let value = dict["age"]
        {
            user.age = String(format: "%d", value as! Int)
        }
        
        if let value = dict["gender"]
        {
            user.gender = value as! String
        }
        
        if let value = dict["about_me"]
        {
            user.about_me = value as! String
        }
        
        if let value = dict["subscribe"]
        {
            if value is String
            {
                user.subscribe = value as! String
            }
            else
            {
                user.subscribe = String(format: "%d", value as! Int)
            }
        }
        
        if let value = dict["username"]
        {
            user.username = value as! String
        }
        
        if let value = dict["name"]
        {
            user.username = value as! String
        }
        
        if let value = dict["avatar"]
        {
            user.image = String(format: "\(restApiUrl)%@", value as! String)
        }

        if let value = dict["largeavatar"]
        {
            user.largeimage = String(format: "\(restApiUrl)%@", value as! String)
        }
        
        if let value = dict["email"]
        {
            user.email = value as! String
        }
        
        if let value = dict["password"]
        {
            user.password = value as! String
        }
        
        if let value = dict["longitude"]
        {
            user.longitude = value as! String
        }
        
        if let value = dict["latitude"]
        {
            user.latitude = value as! String
        }
        
        if let value = dict["city"]
        {
            if !(value is NSNull)
            {
                user.city = value as! String
            }
        }
        
        if let value = dict["country"]
        {
            if !(value is NSNull)
            {
                user.country = value as! String
            }
        }
        
        if let value = dict["fb_id"]
        {
            user.fb_id = value as! String
        }
        
        if let value = dict["tw_id"]
        {
            user.tw_id = value as! String
        }
        
        
        return user
    }
    
    class func userRegistrationServiceWithBlock(paramsDict: [String : String], image: UIImage?, response:(user: User? , message: String, error: NSError?) -> Void)
    {
    
            
        let method = "signup"
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.POST(urlString, parameters: nil, constructingBodyWithBlock: { (formData) in
            
            for key in paramsDict.keys
            {
                let tempData = NSMutableData()
                tempData.appendData((paramsDict[key]?.dataUsingEncoding(NSUTF8StringEncoding))!)
                formData.appendPartWithFormData(tempData, name: key)
            }
            
            if image != nil
            {
                formData.appendPartWithFileData(imageData!, name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg");
            }
            
            }, progress: { (progress) in
                
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                if let error = data?.objectForKey("error")
                {
                    if error as!Bool == true
                    {
                        // registration failed
                        let message = data?.valueForKey("message") as! String
                        response(user: nil, message: message, error: nil)
                        
                    }
                    else
                    {
                        // successfully registered
                        
                        let message = data?.valueForKey("message") as! String
                        let dict : [String : AnyObject] = data as! Dictionary
                        let user = User.initWithAnyDictionary(dict)
                        
                        print(user.api_key)
                        
                        response(user: user, message: message, error: nil)
                    }
                }
                
                
            }) { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(user: nil, message: error.localizedDescription, error: error)
                
        }
    }
    
    class func userLoginServiceWithBlock(paramsDict: [String : String], response:(user: User?, userExists: Bool, message: String , error: NSError?) -> Void)
    {
        let method = "login"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
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
                
                // if user exists create user with initwithdictionary
                if let userExists = data?.objectForKey("userExist")
                {
                    if userExists as!Bool == true
                    {
                        if let error = data?.objectForKey("error")
                        {
                            if error as!Bool == true
                            {
                                // login failed
                                let message = data?.valueForKey("message") as! String
                                response(user: nil, userExists: true, message: message, error: nil)
                                
                            }
                            else
                            {
                                // successfully logged in
                                
                                let message = data?.valueForKey("message") as! String
                                let dict : [String : AnyObject] = data as! Dictionary
                                let user = User.initWithAnyDictionary(dict)
                                
                                print(user.api_key)
                                
                                response(user: user, userExists: true, message: message, error: nil)
                            }
                        }
                    }
                    else
                    {
                        if let error = data?.objectForKey("error")
                        {
                            if error as! Bool == true
                            {
                                // do sign up
                                let message = data?.valueForKey("message") as! String
                                response(user: nil, userExists: false, message: message, error: nil)
                                
                            }
                        }
                    }
                }
                
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            response(user: nil, userExists: false, message: "", error: error)
        }
    }
    
    // to get own / other user profile
    
    class func getUserProfileServiceWithBlock(paramsDict: [String : String]?, api_key: String, response:(user: User? , error: NSError?) -> Void)
    {
        let method = "user"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramsDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                let tempArray = data?.valueForKey("user") as! [Dictionary<String, AnyObject>]
                
                let dict : [String : AnyObject] = tempArray[0]
                let user = User.initWithAnyDictionary(dict)
                
                response(user: user, error: nil)
            
            }, failure: { (task, error) in
                
                response(user: nil, error: error)
        })        
    }
    
    class func subscribeToUserServiceWithBlock(paramsDict: [String : String], api_key: String, response:(success: Bool , message: String, error: NSError?) -> Void)
    {
        let method = "addconnection"
        
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
                
                response(success: true, message: "Successfully subscribed.", error: nil)
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(success: false, message: error.localizedDescription, error: error)
            
        }
        
        
    }
    
    class func unSubscribeToUserServiceWithBlock(paramsDict: [String : String], api_key: String, response:(success: Bool , message: String, error: NSError?) -> Void)
    {
        let method = "leaveconnection"
        
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
                
                response(success: true, message: "Successfully Unsubscribed.", error: nil)
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(success: false, message: error.localizedDescription, error: error)
            
        }
        
        
    }
    
    class func userLogoutServiceWithBlock(paramsDict: [String : String], api_key: String, response:(success: Bool , message: String, error: NSError?) -> Void)
    {
        let method = "logout"
        
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
                
                response(success: true, message: "Successfully Logged Out.", error: nil)
                
        }) { (task, error) in
            
            //print(error.localizedDescription)
            //print(error.userInfo)
            response(success: false, message: error.localizedDescription, error: error)
            
        }
        
        
    }
    
    class func updateProfileServiceWithBlock(paramsDict: [String : String], api_key: String, image: UIImage?, response:(success: Bool , message: String, error: NSError?) -> Void)
    {
        let method = "updateprofile"
        
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
       

        
        
        let urlString = "\(restApiUrl)\(method)"
        
        print(urlString);
        
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
            if image != nil
            {
//                formData.appendPartWithFileData:imageData name:@"avatar" fileName:@"file.jpg" mimeType:@"image/jpeg";
                formData.appendPartWithFileData(imageData!, name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg");
                
//                formData.appendPartWithFormData(imageData!, name: "avatar")
                // handle image processing here
            }
            
            }, progress: { (progress) in
                
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                if let error = data?.objectForKey("error")
                {
                    if error as!Bool == false
                    {
                        response(success: true, message: "Successfully updated.", error: nil)
                    }
                    else
                    {
                        response(success: false, message: "Update failed.", error: nil)
                    }
                }
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(success: false, message: error.localizedDescription, error: error)
            
        }
        
        
    }
    class func getUserConnectionsServiceWithBlock(api_key: String, response:(users: [User] , error: NSError?) -> Void)
    {
        let method = "myconnections"
        
        let urlString = "\(restApiUrl)\(method)"
        print(api_key)
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var usersArray : [User] = []
                
                let users = data?.valueForKey("connections") as! [Dictionary<String, AnyObject>]
                for dict in users
                {
                    let user = User.initWithAnyDictionary(dict)
                    usersArray.append(user)
                }
                
                response(users: usersArray, error: nil)
                
            }, failure: { (task, error) in
                print(error)
                response(users: [], error: error)
        })
    }

    class func findUsersServiceWithBlock(paramsDict: [String : String],api_key: String, response:(users: [User] , error: NSError?) -> Void)
    {
        let method = "members"
        
        let urlString = "\(restApiUrl)\(method)"
        print(api_key)
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: paramsDict, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var usersArray : [User] = []
                
                let users = data?.valueForKey("members") as! [Dictionary<String, AnyObject>]
                for dict in users
                {
                    let user = User.initWithAnyDictionary(dict)
                    usersArray.append(user)
                }
                
                response(users: usersArray, error: nil)
                
            }, failure: { (task, error) in
                print(error)
                response(users: [], error: error)
        })
    }
    func isConnected() -> Bool{
        var connected: Bool = false
        if(self.subscribe == "1"){
            connected = true
        }
        return connected
    }
    class func resetPasswordServiceWithBlock(paramsDict: [String : String], response:(success: Bool , message: String, error: NSError?) -> Void)
    {
        let method = "resetpassword"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
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
                let message = data?.objectForKey("message") as! String
                if let error = data?.objectForKey("error")
                {
                    if error as!Bool == false
                    {
                        response(success: true, message: message, error: nil)
                    }
                    else
                    {
                        response(success: false, message: message, error: nil)
                    }
                }
                
        }) { (task, error) in
            
            print(error.localizedDescription)
            print(error.userInfo)
            response(success: false, message: error.localizedDescription, error: error)
            
        }
        
        
    }


}
