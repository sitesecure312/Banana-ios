//
//  Utility.swift
//  Banana
//
//  Created by musharraf on 4/14/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import AFNetworking

class Utility: NSObject
{

    class func isValidEmail(testStr:String) -> Bool
    {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    class func downloadImageForImageView(imageView: UIImageView, url: String) -> Void
    {
        let imageRequest = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60)
        
        imageView.setImageWithURLRequest(imageRequest, placeholderImage: UIImage(named: "person"), success: nil, failure: nil)
    }
    
    class func downloadImageForButton(button: UIButton, url: String) -> Void
    {
        let imageRequest = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60)
        
        button.setBackgroundImageForState(.Normal, withURLRequest: imageRequest, placeholderImage: UIImage(named: "person"), success: nil, failure: nil)
    }
    static let numberFormater: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.formatterBehavior = .BehaviorDefault
        return formatter
    }()
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
