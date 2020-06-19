//
//  SportCategory.swift
//  Banana
//
//  Created by musharraf on 4/19/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class SportCategory: NSObject
{
    var ID = ""
    var name = ""
    
    static func initWithDictionary(dict: Dictionary<String,AnyObject>) -> SportCategory
    {
        let sportCategory = SportCategory()
        
        if let value = dict["id"]
        {
            sportCategory.ID = String(format: "%d", value as! Int)
        }
        
        if let value = dict["title"]
        {
            sportCategory.name = value as! String
        }
        
        return sportCategory
    }
    
    class func getSportsServiceWithBlock(api_key: String, response:(catagories: [SportCategory], challenges: [Challenge], error: NSError?) -> Void)
    {
        let method = "sports"
        
        let urlString = "\(restApiUrl)\(method)"
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "Authorizuser")
//        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET(urlString, parameters: nil, progress: { (progress) in
            
            }, success: { (task, data) in
                
                print("JSON: \(data)")
                
                var catsArray : [SportCategory] = []
                let firstCat = SportCategory()
                firstCat.name = "All Sports"
                
                catsArray.append(firstCat)
                
                let cats = data?.valueForKey("sports") as! [Dictionary<String, AnyObject>]
                for dict in cats
                {
                    let cat = SportCategory.initWithDictionary(dict)
                    catsArray.append(cat)
                }
                
                
                var chsArray : [Challenge] = []
                
                let chs = data?.valueForKey("activityTitles") as! [Dictionary<String, AnyObject>]
                for dict in chs
                {
                    let ch = Challenge.initWithDictionary(dict)
                    chsArray.append(ch)
                }
                
                
                response(catagories: catsArray, challenges: chsArray, error: nil)
                
            }) { (task, error) in
                
                print(error.localizedDescription)
                print(error.userInfo)
                response(catagories: [], challenges: [], error: error)
        }
        
        
    }    
    
}
