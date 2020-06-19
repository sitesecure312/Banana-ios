//
//  MyConnectionsVC.swift
//  Banana
//
//  Created by musharraf on 5/31/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class MyConnectionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource

{

    
    @IBOutlet weak var connections_tableview: UITableView!
    var api_key: String = ""
    var users: [User] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        connections_tableview.delegate = self
        connections_tableview.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        connections_tableview.addSubview(refreshControl)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool)
    {
        self.getConnections()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        
        
    }
    
    func refresh()
    {
        self.getConnections()
        self.refreshControl?.endRefreshing()
    }
    

    //MARK: tableView DataSource
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier( "MyConnectionsCell", forIndexPath: indexPath) as! MyConnectionsCell
        
        let user = users[indexPath.row]
        print(user)
        cell.avatar_btn.layer.cornerRadius = cell.avatar_btn.frame.size.width / 2
        cell.avatar_btn.tag = indexPath.row
        Utility.downloadImageForButton(cell.avatar_btn, url: user.image)
        cell.username.text = user.username
        cell.user_desc.text = user.about_me
        cell.gender.text = user.gender+"/"+user.age
        
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
    func viewProfileTappedOfCell(cell: MyConnectionsCell)
    {
        let user = users[cell.tag]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        
        vc.otherUser_id = user.user_id
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getConnections()
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            User.getUserConnectionsServiceWithBlock(api_key, response: { (users, error) in
                
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
                    self.connections_tableview.reloadData()
                    
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

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func unsubscribePressed(cell: MyConnectionsCell) {
        // call subscription service here
        
        let user = users[cell.tag]
        let otherUser_id = user.user_id
        
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["friendId": otherUser_id]
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
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        self.users.removeAtIndex(cell.tag)
                        self.connections_tableview.reloadData()
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
 
    
}
