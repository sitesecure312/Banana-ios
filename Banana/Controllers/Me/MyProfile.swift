//
//  MyProfile.swift
//  Banana
//
//  Created by musharraf on 4/21/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class MyProfile: UIViewController
{
    
    @IBOutlet weak var user_imgView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var about_me: UITextView!
    @IBOutlet weak var formatted_address: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var myconnection: UIButton!

    var api_key: String = ""
    var user_id : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        
         user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        getUserProfile(user_id)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.viewActivityDetail(_:)), name: "viewActivityDetail", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.msgReceivedForConversation(_:)), name: "msgReceivedForConversation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userSubscribed(_:)), name: "userSubscribed", object: nil)
        
        if scrollView.hidden
        {
            let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
            getUserProfile(user_id)
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "viewActivityDetail", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "msgReceivedForConversation", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "userSubscribed", object: nil)
    }
    
    
    //MARK: Push Notification Observers
    
    func viewActivityDetail(notification: NSNotification) -> Void
    {
        let dict = notification.userInfo as! [String:String]
        let ID = dict["id"]
        NSNotificationCenter.defaultCenter().postNotificationName("didSelectTab", object: nil, userInfo: ["tag":-1, "id":ID!, "name":"viewActivityDetail"])
    }
    
    func msgReceivedForConversation(notification: NSNotification) -> Void
    {
        let dict = notification.userInfo as! [String:String]
        let ID = dict["id"]
        NSNotificationCenter.defaultCenter().postNotificationName("didSelectTab", object: nil, userInfo: ["tag":-2, "id":ID!, "name":"msgReceivedForConversation"])
    }
    
    func userSubscribed(notification: NSNotification) -> Void
    {
        let dict = notification.userInfo as! [String:String]
        print(dict)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        vc.otherUser_id = dict["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Service Call
    
    func getUserProfile(user_id: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["id": user_id]
            User.getUserProfileServiceWithBlock(dict, api_key: api_key, response: { (user, error) in
                
                if error != nil
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error!", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if user != nil
                {
                    user?.image 
                    Utility.downloadImageForImageView(self.user_imgView, url: (user?.largeimage)!)
                    self.user_imgView.layer.cornerRadius = self.user_imgView.frame.size.width / 2
                    self.name.text = user?.username
                    self.age.text = user?.age
                    self.gender.text = user?.gender
                    self.about_me.text = user?.about_me
                    if (!((user?.city)! .isEmpty) && !((user?.country)! .isEmpty))
                    {
                        self.formatted_address.text = String(format: "%@, %@", (user?.city)!, (user?.country)!)
                    }else {
                        self.formatted_address.text = String(format: "%@ %@", (user?.city)!, (user?.country)!)
                    }
                    
                    self.scrollView.hidden = false
                    
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                }
            })
        }
            
        else
        {
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Action Methods
    
    @IBAction func settingPressed(sender: UIButton)
    {
        // show action sheet
        let alertController : UIAlertController = UIAlertController(title: "", message: "" , preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        
        let signoutAction: UIAlertAction = UIAlertAction(title: "Sign Out", style: .Default) { action -> Void in
            //Do some stuff
            if hasInternet
            {
                self.view.userInteractionEnabled = false
                activityIndicator.startAnimating()
                var device_token = ""
                if let token = NSUserDefaults.standardUserDefaults().valueForKey("tokenString")
                {
                    device_token = token as! String
                }
                
                let dict = ["pushId":device_token]
                User.userLogoutServiceWithBlock(dict, api_key: self.api_key, response: { (success, message, error) in
                    
                    if let error = error
                    {
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        let alertController : UIAlertController = UIAlertController(title: "Error!", message: error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                        
                    else if success
                    {
//                        let appDomain = NSBundle.mainBundle().bundleIdentifier
//                        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)

                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setValue(nil, forKey: "user_id")
                        defaults.setValue(nil, forKey: "api_key")
                        defaults.synchronize()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(loggedOut, object: nil)
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                    }
                        
                    else
                    {
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        
                        let alertController : UIAlertController = UIAlertController(title: "Error!", message: "Some Unknown Error occured, try later." , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                })
            }
                
            else
            {
                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        let supportAction: UIAlertAction = UIAlertAction(title: "Support", style: .Default) { action -> Void in
            //Do some stuff
            
            
        }
        
        let accountSettingAction: UIAlertAction = UIAlertAction(title: "Account Setting", style: .Default) { action -> Void in
            //Do some stuff
            
            // report user here
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(accountSettingAction)
        alertController.addAction(supportAction)
        alertController.addAction(signoutAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editProfilePressed(sender: UIButton)
    {
        // go to edit profile VC
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("EditProfile") as! EditProfile
        vc.api_key = api_key
        vc.image = user_imgView.image
        
        if let str = age.text
        {
            vc.age = str
        }
        
        if let str = name.text
        {
            vc.name = str
        }
        
        if let str = gender.text
        {
            vc.gender = str
        }
        
        if let str = about_me.text
        {
            vc.desc = str
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myconnection(sender: UIButton) {
        print("My Connections");
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MyConnectionsVC") as! MyConnectionsVC
        vc.api_key = api_key
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func searchMembersPressed(sender: UIButton) {
        print("Search Members Pressed");
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SearchMembersVC") as! SearchMembersVC
        vc.api_key = api_key
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
