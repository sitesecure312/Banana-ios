//
//  SearchMembersVC.swift
//  Banana
//
//  Created by musharraf on 6/1/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class SearchMembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate
    
{
    
    @IBOutlet weak var members_tableview: UITableView!
    var api_key: String = ""
    var users: [User] = []
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var username_input: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        members_tableview.delegate = self
        members_tableview.dataSource = self
        self.username_input.delegate = self;
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        members_tableview.addSubview(refreshControl)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool)
    {
        self.getMembers()
      
    }
    override func viewWillDisappear(animated: Bool)
    {

    }

    func refresh(sender:AnyObject)
    {
        self.getMembers()
        self.refreshControl?.endRefreshing()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( "SearchMembersCell", forIndexPath: indexPath) as! SearchMembersCell
        
        let user = users[indexPath.row]
        print(user)
        cell.avatar_btn.layer.cornerRadius = cell.avatar_btn.frame.size.width / 2
        cell.avatar_btn.tag = indexPath.row
        Utility.downloadImageForButton(cell.avatar_btn, url: user.image)
        cell.username.text = user.username
        cell.user_desc.text = user.about_me
        cell.gender.text = user.gender+"/"+user.age
        
        if(user.isConnected()){
            cell.connect_btn.setTitle("Disconnect", forState: .Normal)
        }
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 117
        //        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 117
        //        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let user = users[indexPath.row]
        print(user)
        
    }
    func viewProfileTappedOfCell(cell: SearchMembersCell)
    {
        let user = users[cell.tag]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        
        vc.otherUser_id = user.user_id
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getMembers()
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            let username = username_input.text! as String
            let dict = ["username": username]
            User.findUsersServiceWithBlock(dict,api_key: api_key, response: { (users, error) in
                
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
                    self.users = users
                    self.members_tableview.reloadData()
                    
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

    
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func connectTapped(cell: SearchMembersCell) {
        // call subscription service here
        
        let user = users[cell.tag]
        let otherUser_id = user.user_id
        
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            let dict = ["friendId": otherUser_id]
            
            if(user.isConnected()){
                User.unSubscribeToUserServiceWithBlock(dict, api_key: api_key) { (success, message, error) in
                    
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
                        
                    else
                    {
                        cell.connect_btn.setTitle("Connect", forState: .Normal)
                        user.subscribe = "3"
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        
                    }
                    
                }
            }else{
                User.subscribeToUserServiceWithBlock(dict, api_key: api_key) { (success, message, error) in
                    
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
                        
                    else
                    {
                        cell.connect_btn.setTitle("Disconnect", forState: .Normal)
                        user.subscribe = "1"
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        
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
    @IBAction func searchBtnPressed(sender: UIButton) {
        getMembers()

    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == username_input {
            textField.resignFirstResponder()
            self.getMembers()
            return false
        }
        return true
    }
    
}
