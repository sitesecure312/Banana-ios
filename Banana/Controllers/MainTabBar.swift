//
//  MainTabBar.swift
//  Banana
//
//  Created by musharraf on 4/15/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController
{

    var subviewsArray: [UIView] = []
    var tabBtnsArray :[UIButton] = []
    
    var vcArray: [UIViewController] = []
    var navArray :[UINavigationController] = []
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let w: CGFloat = self.tabBar.frame.size.width
        let h: CGFloat = self.tabBar.frame.size.height
        
        let firstItem: UIButton = UIButton()
        
        firstItem.addTarget(self, action: #selector(self.tabbarItemSelected), forControlEvents: .TouchUpInside)
        firstItem.tag = -1
        firstItem.backgroundColor = UIColor(red: 39.0 / 255.0, green: 148.0 / 255.0, blue: 199.0 / 255.0, alpha: 1.0)
        firstItem.setTitle("Home", forState: .Normal)
        firstItem.setTitleColor(UIColor(red: 0.92, green: 0.92, blue: 0.91, alpha: 1.0), forState: .Normal)
//      firstItem.titleLabel!.font = UIFont.systemFontOfSize(14.0)
        firstItem.titleLabel!.font = UIFont(name: "Kozuka Gothic Pro", size: 14.0)
        firstItem.frame = CGRectMake(0, 0, w / 4, h)
        self.tabBar.addSubview(firstItem)
        
        
        let secondItem: UIButton = UIButton()
        
        secondItem.addTarget(self, action: #selector(self.tabbarItemSelected), forControlEvents: .TouchUpInside)
        secondItem.tag = -2
        secondItem.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        secondItem.setTitle("Connect", forState: .Normal)
        secondItem.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
//      secondItem.titleLabel!.font = UIFont.systemFontOfSize(14.0)
        secondItem.titleLabel!.font = UIFont(name: "Kozuka Gothic Pro", size: 14.0)
        secondItem.frame = CGRectMake(w / 4, 0, w / 4, h)
        self.tabBar.addSubview(secondItem)

        let thirdItem: UIButton = UIButton()
        
        thirdItem.addTarget(self, action: #selector(self.tabbarItemSelected), forControlEvents: .TouchUpInside)
        thirdItem.tag = -3
        thirdItem.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        thirdItem.setTitle("Activities", forState: .Normal)
        thirdItem.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
//      thirdItem.titleLabel!.font = UIFont.systemFontOfSize(14.0)
        thirdItem.titleLabel!.font = UIFont(name: "Kozuka Gothic Pro", size: 14.0)
        thirdItem.frame = CGRectMake(w / 2, 0, w / 4, h)
        self.tabBar.addSubview(thirdItem)

        let forthItem: UIButton = UIButton()
        
        forthItem.addTarget(self, action: #selector(self.tabbarItemSelected), forControlEvents: .TouchUpInside)
        forthItem.tag = -4
        forthItem.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        forthItem.setTitle("Me", forState: .Normal)
        forthItem.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
//      forthItem.titleLabel!.font = UIFont.systemFontOfSize(14.0)
        forthItem.titleLabel!.font = UIFont(name: "Kozuka Gothic Pro", size: 14.0)
        forthItem.frame = CGRectMake(w - w / 4, 0, w / 4, h)
        self.tabBar.addSubview(forthItem)
        
        subviewsArray = self.tabBar.subviews

        for view in subviewsArray
        {
            if view.isKindOfClass(UIButton) && (view.tag == -1 || view.tag == -2 || view.tag == -3 || view.tag == -4)
            {
                tabBtnsArray.append(view as! UIButton)
            }
        }
        
        vcArray = self.viewControllers!
        print("tabbar controllers count\(vcArray.count)")
        
        for vc in vcArray
        {
            if vc.isKindOfClass(UINavigationController)
            {
                navArray.append(vc as! UINavigationController)
            }
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSelectTab(_:)), name: "didSelectTab", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didSelectTab", object: nil)
    }
    
    func orientationChanged(notification: NSNotification) -> Void
    {
        self.adjustViewsForOrientation(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    func adjustViewsForOrientation(orientation: UIInterfaceOrientation) -> Void
    {
        
        switch orientation
        {
        case .Portrait, .PortraitUpsideDown:
            print("portrait")
            
            for btn in tabBtnsArray
            {
                let w: CGFloat = self.tabBar.frame.size.width
                let h: CGFloat = self.tabBar.frame.size.height
                
                if btn.tag == -1
                {
                    btn.frame = CGRect(x: 0, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -2
                {
                    btn.frame = CGRect(x: w / 4, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -3
                {
                    btn.frame = CGRect(x: w / 2, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -4
                {
                    btn.frame = CGRect(x: w - w / 4, y: 0, width: w / 4, height: h)
                }
            }
            
        case .LandscapeLeft, .LandscapeRight:
            print("Landscape")
            
            for btn in tabBtnsArray
            {
                let w: CGFloat = self.tabBar.frame.size.width
                let h: CGFloat = self.tabBar.frame.size.height
                
                if btn.tag == -1
                {
                    btn.frame = CGRect(x: 0, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -2
                {
                    btn.frame = CGRect(x: w / 4, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -3
                {
                    btn.frame = CGRect(x: w / 2, y: 0, width: w / 4, height: h)
                }
                else if btn.tag == -4
                {
                    btn.frame = CGRect(x: w - w / 4, y: 0, width: w / 4, height: h)
                }
            }

            
            
        default:
            print("Unknown Orientation")
        }
        
    }
    
    func didSelectTab(notification: NSNotification) -> Void
    {
        print("tabbar btn selected")
        
        let dict = notification.userInfo as! [String:AnyObject]
        
        let btn_tag = dict["tag"] as! Int
        
        for btn in tabBtnsArray
        {
            if btn.tag == btn_tag
            {
                let index = btn_tag * (-1) - 1
                navArray[index].popToRootViewControllerAnimated(true)
                self.selectedIndex = index
                
                btn.backgroundColor = UIColor(red: 39.0 / 255.0, green: 148.0 / 255.0, blue: 199.0 / 255.0, alpha: 1.0)
                btn.setTitleColor(UIColor(red: 0.92, green: 0.92, blue: 0.91, alpha: 1.0), forState: .Normal)
                
                if let name = dict["name"]
                {
                    let ID = dict["id"] as! String
                    switch name as! String
                    {
                    case "viewActivityDetail":
                        NSNotificationCenter.defaultCenter().postNotificationName("viewActivityDetail", object: nil, userInfo: ["id":ID])
                        
                    case "msgReceivedForConversation":
                        NSNotificationCenter.defaultCenter().postNotificationName("msgReceivedForConversation", object: nil, userInfo: ["id":ID])
                    default:
                        print("Handle other options")
                    }
                }
            }
                
            else
            {
                btn.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4);           btn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            }
        }
    }
    
    @IBAction func tabbarItemSelected(sender: UIButton)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("didSelectTab", object: nil, userInfo: ["tag":sender.tag])
    }
    
}
