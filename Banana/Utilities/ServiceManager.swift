//
//  ServiceManager.swift
//  JOBMan
//
//  Created by Muhammad Waqas on 10/3/15.
//  Copyright (c) 2015 Muhammad Jabbar. All rights reserved.
//

import Foundation
import AFNetworking

typealias SuccessBlock = (response: AnyObject?) -> Void
typealias FailureBlock = (error: NSError?) -> Void

class ServiceManager: NSObject
{
    static  let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_URL))
    
    let base_URL = "http://jobmawn.brainiacstech.com/index.php"
    
    let man = AFHTTPSessionManager(baseURL: NSURL(string: baseurl))
    
    
    
    static func postRequest(clazz: String, method: String, parameters: [String : String], image: UIImage?  , onSuccess: SuccessBlock , onFailure: FailureBlock)
    {
        if ( image != nil)
        {
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            
            let op : AFHTTPRequestOperation = manager.POST(clazz + method, parameters: parameters , constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(imageData!, name: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
                },
                success:
                {
                    (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    print(responseObject)
                    
                    print("after response")
                    
                    if (responseObject["status"] as! String == "success")
                    {
                        onSuccess(response: responseObject["response"])
                    }
                        
                    else
                    {
                        let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                        onFailure(error: error)
                    }
                },
                failure:
                { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    print(error)
                    
                    onFailure(error: error)
                })!
            
            op.start()
        }
            
        else
        {
            // manager.requestSerializer.setValue("608c6c08443c6d933576b90966b727358d0066b4", forHTTPHeaderField: "X-Auth-Token")
            let op : AFHTTPRequestOperation = manager.POST(clazz + method, parameters: parameters,
                success:
                {
                    (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    print(responseObject)
                    if (responseObject["status"] as! String == "success")
                    {
                        onSuccess(response: responseObject["response"])
                    }
                        
                    else
                    {
                        let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                        onFailure(error: error)
                    }
                    
                },
                failure:
                { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    print(error)
                    
                    onFailure(error: error)
            })!
            
            op.start()
        }
    }
    
    
    static func getRequest(clazz: String, method: String, parameters: AnyObject? , onSuccess: SuccessBlock , onFailure: FailureBlock)
    {
        //manager.requestSerializer.setValue("608c6c08443c6d933576b90966b727358d0066b4", forHTTPHeaderField: "X-Auth-Token")
        let op : AFHTTPRequestOperation = manager.GET( base_URL + clazz + method , parameters: parameters,
            success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                
                print(responseObject)
                if (responseObject["status"] as! String == "success")
                {
                    onSuccess(response: responseObject["response"])
                }
                    
                else
                {
                    let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                    onFailure(error: error)
                }
                
            },
            failure:
            { (operation: AFHTTPRequestOperation!,error: NSError!) in
                print(error)
                
                onFailure(error: error)
            })!
        op.start()
        
    }
    
    
    
    
    
    //------------------------ Below is my orignal requests---------------
    
    /*
    static  let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_URL))

    static let base_URL = "http://jobmawn.brainiacstech.com/index.php"
   
    static func postRequest(clazz: String, method: String, parameters: [String : String], image: UIImage?  , onSuccess: SuccessBlock , onFailure: FailureBlock)
    {
        if ( image != nil)
        {
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            
            let op : AFHTTPRequestOperation = manager.POST(clazz + method, parameters: parameters , constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(imageData!, name: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
                },
                success:
                {
                    (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    print(responseObject)
                    
                    print("after response")
                    
                    if (responseObject["status"] as! String == "success")
                    {
                        onSuccess(response: responseObject["response"])
                    }
                        
                    else
                    {
                        let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                        onFailure(error: error)
                    }
                },
                failure:
                { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    print(error)
                    
                    onFailure(error: error)
                })!

            op.start()
        }
        
        else
        {
            let op : AFHTTPRequestOperation = manager.POST(clazz + method, parameters: parameters,
                success:
                {
                    (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    print(responseObject)
                    if (responseObject["status"] as! String == "success")
                    {
                        onSuccess(response: responseObject["response"])
                    }
                        
                    else
                    {
                        let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                        onFailure(error: error)
                    }
                    
                },
                failure:
                { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    print(error)
                    
                    onFailure(error: error)
                })!
            
            op.start()
        }
    }
    
    
    static func getRequest(clazz: String, method: String, parameters: AnyObject? , onSuccess: SuccessBlock , onFailure: FailureBlock)
    {
        manager.requestSerializer.setValue("608c6c08443c6d933576b90966b727358d0066b4", forHTTPHeaderField: "X-Auth-Token")
        manager.GET( base_URL + clazz + method , parameters: parameters,
            success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                
                print(responseObject["response"])
                if (responseObject["status"] as! String == "success")
                {
                    onSuccess(response: responseObject["response"])
                }
                    
                else
                {
                    let error:NSError = NSError(domain: "SuperSpecialDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Something went wrong try again later!"])
                    onFailure(error: error)
                }
                
            },
            failure:
            { (operation: AFHTTPRequestOperation!,error: NSError!) in
                print(error)
                
                onFailure(error: error)
            })
        
    }
    
    */
    
}