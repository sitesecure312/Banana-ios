//
//  ConnectionsVC.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit


class ConnectionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AllConversationCellDelegate
{

    @IBOutlet weak var conversations_tableView: UITableView!
    
    var api_key: String = ""
    var user_id: String = ""
    var conversations: [Conversation] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        conversations_tableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.getAllConversations()
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
        
        if let ID = dict["id"]
        {
            getConversationByID(ID)
        }
        
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
    
    func getAllConversations()
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            Conversation.getAllConversationsServiceWithBlock(api_key, response: { (conversations, error) in
                
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
                    self.conversations = conversations
                    self.conversations_tableView.reloadData()
                    
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                }
                
            })
        }
            
        else
        {
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message:"Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func getConversationByID(conv_id: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["conversationId":conv_id]
            
            Conversation.getConversationByIDServiceWithBlock(dict, api_key: api_key, response: { (conv, error) in
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error!", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if let con = conv
                {
                    // go to messages screen
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MessagesVC") as! MessagesVC
                    vc.conversationId = con.ID
                    vc.activityId = con.activity_id
                    
                    if con.is_owner
                    {
                        vc.user_id = con.owner_id
                        vc.other_id = con.receiver_id
                        vc.isOwner = true
                        vc.user_imgURL = con.avatar_owner
                        vc.other_imgURL = con.avatar_receiver
                        vc.other_name = con.name_receiver
                    }
                    else
                    {
                        vc.user_id = con.receiver_id
                        vc.other_id = con.owner_id
                        vc.isOwner = false
                        vc.user_imgURL = con.avatar_receiver
                        vc.other_imgURL = con.avatar_owner
                        vc.other_name = con.name_owner
                    }
                    
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            
            })
        }
            
        else
        {
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message:"Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func refresh()
    {
        self.getAllConversations()
    }
    
    
    //MARK: tableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( "AllConversationCell", forIndexPath: indexPath) as! AllConversationCell
        
        let con = conversations[indexPath.row]
        cell.profile_btn.layer.cornerRadius = cell.profile_btn.frame.size.width / 2
        cell.profile_btn.tag = indexPath.row
        
        if con.is_owner
        {
            Utility.downloadImageForButton(cell.profile_btn, url: con.avatar_receiver)
            cell.username.text = con.name_receiver
        }
        
        else
        {
            Utility.downloadImageForButton(cell.profile_btn, url: con.avatar_owner)
            cell.username.text = con.name_owner
        }
        
        cell.activity_challenge.text = con.activity
        cell.date_time.text = con.date
        cell.message.text = con.message
        
        cell.delegate = self
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // go to activity detail VC
        
        let conv = conversations[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
        vc.act_id = conv.activity_id
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    //MARK: AllConversationCell Delegate
    
    func viewProfileTappedOfCell(cell: AllConversationCell)
    {
        let con = conversations[cell.tag]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        
        if con.is_owner
        {
            vc.otherUser_id = con.receiver_id
        }
            
        else
        {
            vc.otherUser_id = con.owner_id
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func viewConversationTappedOfCell(cell: AllConversationCell)
    {
        let con = conversations[cell.tag]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MessagesVC") as! MessagesVC
        vc.conversationId = con.ID
        vc.activityId = con.activity_id
        
        if con.is_owner
        {
            vc.user_id = con.owner_id
            vc.other_id = con.receiver_id
            vc.isOwner = true
            vc.user_imgURL = con.avatar_owner
            vc.other_imgURL = con.avatar_receiver
            vc.other_name = con.name_receiver
        }
        else
        {
            vc.user_id = con.receiver_id
            vc.other_id = con.owner_id
            vc.isOwner = false
            vc.user_imgURL = con.avatar_receiver
            vc.other_imgURL = con.avatar_owner
            vc.other_name = con.name_owner
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
