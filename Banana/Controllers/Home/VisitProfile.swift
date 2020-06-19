//
//  VisitProfile.swift
//  Banana
//
//  Created by musharraf on 4/21/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class VisitProfile: UIViewController, UITableViewDelegate, UITableViewDataSource, AllActivitiesCellDelegate
{
    @IBOutlet weak var activities_tableView: UITableView!
    @IBOutlet weak var user_imgView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var about_me: UITextView!
    @IBOutlet weak var formatted_address: UILabel!
    @IBOutlet weak var subscribe_btn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var otherUser_id: String = ""
    var api_key: String = ""
    var activities: [Activity] = []
    var hasSubscribed = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        getUserProfile(otherUser_id)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.viewActivityDetail(_:)), name: "viewActivityDetail", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.msgReceivedForConversation(_:)), name: "msgReceivedForConversation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.userSubscribed(_:)), name: "userSubscribed", object: nil)
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
        getUserProfile(dict["id"]!)
    }
    
    
    
    //MARK: Service Call
    
    func getUserProfile(otherUser_id: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["id": otherUser_id]
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
                    Utility.downloadImageForImageView(self.user_imgView, url: (user?.image)!)
                    self.user_imgView.layer.cornerRadius = self.user_imgView.frame.size.width / 2
                    self.name.text = user?.username
                    self.age.text = user?.age
                    self.gender.text = user?.gender
                    self.about_me.text = user?.about_me
                    self.formatted_address.text = String(format: "%@, %@", (user?.city)!, (user?.country)!)
                    
                    if user?.subscribe == "1"
                    {
                        self.hasSubscribed = true
                        self.subscribe_btn.setTitle("Disconnect", forState: .Normal)
                    }
                    
                    else if user?.subscribe == "3"
                    {
                        self.hasSubscribed = false
                        self.subscribe_btn.setTitle("Connect", forState: .Normal)
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
    
    func getAllActivities()
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["id": otherUser_id]
            Activity.getOtherUserActivitiesServiceWithBlock(dict, api_key: api_key, response: { (activities, error) in
                
                if error != nil
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else
                {
                    self.activities = activities
                    self.activities_tableView.reloadData()
                    
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
    
    
    //MARK: tableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( "AllActivitiesCell", forIndexPath: indexPath) as! AllActivitiesCell
        
        // Configure the cell...
        
        let act = activities[indexPath.row]
        cell.activity_challenge.text = act.activity_challange
        cell.address.text = act.formatted_address
        cell.date_time.text = String(format: "%@ at %@", act.date, act.time)
        cell.sport_type.text = act.sports_title
        
        Utility.downloadImageForButton(cell.owner_btn, url: act.avatar)
        
        cell.owner_btn.layer.cornerRadius = cell.owner_btn.frame.size.width / 2
        cell.owner_btn.tag = indexPath.row
        cell.owner_btn.userInteractionEnabled = false
//        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    //MARK: UITableViewCell Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // go to activity detail VC
        
        let act = activities[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
        vc.act_id = act.ID
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func buttonTappedOfCell(cell: AllActivitiesCell)
    {
        let act = activities[cell.tag]
        if act.owner_id == NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
        {
            self.tabBarController?.selectedIndex = 3
        }
            
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
            
            // send required data as well
        
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    //MARK: Action Methods
    
    @IBAction func back(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didPressedSegControlBtn(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 1
        {
            // show tableView
            activities_tableView.hidden = false
            getAllActivities()
            
        }
        else
        {
            // hide tableView
            activities_tableView.hidden = true
        }
    }

    @IBAction func settingPressed(sender: UIButton)
    {
        // show action sheet
        let alertController : UIAlertController = UIAlertController(title: "", message: "" , preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        
        //Create and add the Cancel action
        let blockAction: UIAlertAction = UIAlertAction(title: "Block", style: .Default) { action -> Void in
            //Do some stuff
            
            // block user here
            
            
        }
        
        //Create and add the Cancel action
        let reportAction: UIAlertAction = UIAlertAction(title: "Report", style: .Default) { action -> Void in
            //Do some stuff
            
            // report user here
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func subscribePressed(sender: UIButton)
    {
        // call subscription service here
        
        if hasInternet
        {
            let dict = ["friendId": otherUser_id]
            
            if hasSubscribed
            {
                User.unSubscribeToUserServiceWithBlock(dict, api_key: api_key, response: { (success, message, error) in
                   
                    if error != nil
                    {
                        let alertController : UIAlertController = UIAlertController(title: "Error!", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                        
                    else
                    {
                        // change subscription status to subscribed
                        self.hasSubscribed = !self.hasSubscribed
                        self.subscribe_btn.setTitle("Connect", forState: .Normal)
                    }
                })
            }
                
            else
            {
                User.subscribeToUserServiceWithBlock(dict, api_key: api_key) { (success, message, error) in
                    
                    if error != nil
                    {
                        let alertController : UIAlertController = UIAlertController(title: "Error!", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                        
                    else
                    {
                        // change subscription status to subscribed
                        self.hasSubscribed = !self.hasSubscribed
                        self.subscribe_btn.setTitle("Disconnect", forState: .Normal)
                    }
                    
                }
            }
            
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
    func deleteActivityPressed(cell: AllActivitiesCell)
    {
        
    }
    
}
