//
//  ViewActivityRequests.swift
//  Banana
//
//  Created by musharraf on 5/2/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class ViewActivityRequests: UIViewController, UITableViewDelegate, UITableViewDataSource, HideShowBtnDelegate, PendingRequestCellDelegate, AcceptedRequestCellDelegate, RejectedRequestCellDelegate
{

    @IBOutlet weak var tableView: UITableView!
    
    var pendingArray :[ActRequest] = []
    var acceptedArray :[ActRequest] = []
    var rejectedArray :[ActRequest] = []
    
    var downBtnArray :[HideShowBtn] = []
    
    var act_id = ""
    var api_key = ""
    var user_id = ""
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
        for _ in 0..<3
        {
            let btn = HideShowBtn()
            btn.toggle = true
            btn.setImage(UIImage(named: "arrow_down"), forState: .Normal)
            downBtnArray.append(btn)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.getAllActs()

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func refresh()
    {
        self.getAllActs()
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
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    func getAllActs() -> Void
    {
        if hasInternet
        {
            
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["id":act_id]
            ActRequest.getActivityRequestsServiceWithBlock(dict, api_key: api_key, response: { (allActRequests, error) in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                else if allActRequests.count > 0
                {
                    self.pendingArray = allActRequests[0]
                    self.acceptedArray = allActRequests[1]
                    self.rejectedArray = allActRequests[2]
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                }
                
                else
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:"Some unknown error occured." , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message:"Internet Connection not available." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: tableView DataSource, Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let btn = downBtnArray[section]
        
        switch section
        {
        case 0:
            return btn.toggle ? pendingArray.count : 0
        case 1:
            return btn.toggle ? acceptedArray.count : 0
        case 2:
            return btn.toggle ? rejectedArray.count : 0
        default:
            print("default")
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        var req: ActRequest!
        
        switch indexPath.section
        {
        case 0:
            req = pendingArray[indexPath.row]
            
            print(req)
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PendingRequestCell") as! PendingRequestCell
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 250.0/255.0, blue: 231.0/255.0, alpha: 1.0)
            
            
            
            Utility.downloadImageForButton(cell.user_btn, url: req.avatar)
            cell.user_btn.layer.cornerRadius = cell.user_btn.frame.size.width / 2
            cell.user_btn.tag = indexPath.row
            cell.user_name.text = req.name
            cell.message.text = req.user_message
            cell.about_me.text = req.about_me
            cell.section = 0

            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
            
        case 1:
            req = acceptedArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("AcceptedRequestCell") as! AcceptedRequestCell
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 213.0/255.0, green: 242.0/166.0, blue: 222.0/255.0, alpha: 1.0)
            
            Utility.downloadImageForButton(cell.user_btn, url: req.avatar)
            cell.user_btn.layer.cornerRadius = cell.user_btn.frame.size.width / 2
            cell.user_btn.tag = indexPath.row
            cell.user_name.text = req.name
            cell.message.text = req.user_message
            cell.about_me.text = req.about_me
            cell.section = 0
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
            
        case 2:
            req = rejectedArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RejectedRequestCell") as! RejectedRequestCell
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 228.0/255.0, green: 236.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            Utility.downloadImageForButton(cell.user_btn, url: req.avatar)
            cell.user_btn.layer.cornerRadius = cell.user_btn.frame.size.width / 2
            cell.user_btn.tag = indexPath.row
            cell.user_name.text = req.name
            cell.message.text = req.user_message
            cell.about_me.text = req.about_me
            cell.section = 0
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        
        default:
            print("default")
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        var showHeader = false
        
        switch section
        {
        case 0:
            if pendingArray.count > 0
            {
                showHeader = true
            }
        case 1:
            if acceptedArray.count > 0
            {
                showHeader = true
            }
        case 2:
            if rejectedArray.count > 0
            {
                showHeader = true
            }
    
        default:
            print("default")
        }
        
        if showHeader
        {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 46))
            let title = UILabel(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width -  30, height: 30))
            
            let btn = downBtnArray[section]
            btn.frame = CGRect(x: self.view.frame.size.width - 46, y: 8, width: 30, height: 30)
            btn.section = section
            btn.delegate = self
            
            headerView.addSubview(btn)
            
            switch section
            {
            case 0:
                headerView.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 215.0/255.0, blue: 94.0/255.0, alpha: 1.0)
                title.text = "Pending"
                
            case 1:
                headerView.backgroundColor = UIColor(colorLiteralRed: 164.0/255.0, green: 247.0/166.0, blue: 94.0/255.0, alpha: 1.0)
                title.text = "Accepted"
                
            case 2:
                headerView.backgroundColor = UIColor(colorLiteralRed: 188.0/255.0, green: 218.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                title.text = "Rejected"
                
                
            default:
                print("default")
            }
            
            title.textColor = UIColor.blackColor()
            headerView.addSubview(title)
            
            return headerView
        }
        
        return UIView()
        
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
        // go to activity detail
        
        switch indexPath.section
        {
        case 0:
            
            let req = pendingArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = req.activity_id
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            
            let req = acceptedArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = req.activity_id
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            
            let req = rejectedArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = req.activity_id
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("default")
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch section
        {
        case 0:
            if pendingArray.count == 0
            {
                return 0
            }
        case 1:
            if acceptedArray.count == 0
            {
                return 0
            }
        case 2:
            if rejectedArray.count == 0
            {
                return 0
            }
        
        default:
            print("default")
        }
        return 46
    }
    
    //MARK: HideShowButton Delegate
    
    func buttonTapped(btn: HideShowBtn)
    {
        print("btn tapped at section \(btn.section)")
        if btn.toggle
        {
            // close cells
            btn.setImage(UIImage(named: "arrow_up"), forState: .Normal)
        }
        else
        {
            // open up cell
            btn.setImage(UIImage(named: "arrow_down"), forState: .Normal)
        }
        
        btn.toggle = !btn.toggle
        downBtnArray[btn.section!] = btn
        tableView.reloadData()
    }
    
    
    //MARK: PendingRequestCell Delegate
    func viewProfilePressedOfPendingRequestCell(cell: PendingRequestCell)
    {
        let req = pendingArray[cell.tag]
        if req.user_id == user_id
        {
            self.tabBarController?.selectedIndex = 3
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
            
            // send required data as well
            vc.otherUser_id = req.user_id
            print(vc.otherUser_id)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func acceptPressedOfPendingRequestCell(cell: PendingRequestCell)
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let req = self.pendingArray[cell.tag]
            
            let dict = ["activityId":req.activity_id, "userId":req.user_id, "date":"2016-05-05 18:00"]
            ActRequest.acceptActRequestServiceWithBlock(dict, api_key: self.api_key, response:  { (success, error) in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if success
                {
                    self.getAllActs()
                }
                    
                else
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
    
    func messagePressedOfPendingRequestCell(cell: PendingRequestCell)
    {
        if hasInternet
        {
            let alertController = UIAlertController(title: "Write Message Below", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            let send = UIAlertAction(title: "Send", style: .Default, handler: { (action) in
                
                let msgTF = alertController.textFields![0] as UITextField
                
                if (msgTF.text != "")
                {
                    if hasInternet
                    {
                        self.view.userInteractionEnabled = false
                        activityIndicator.startAnimating()
                        
                        let req = self.pendingArray[cell.tag]
                        
                        let dict = ["activityId":req.activity_id, "receiverId":req.user_id, "message":msgTF.text!]
                        ActRequest.messageFromOwnerForActRequestServiceWithBlock(dict, api_key: self.api_key, response:  { (success, error) in
                            
                            if let error = error
                            {
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                                
                                //Create and add the Cancel action
                                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                                    //Do some stuff
                                }
                                alertController.addAction(cancelAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                                
                            else if success
                            {
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "", message:"Message sent successfully." , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                                
                                let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
            })
            
            alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
                textField.placeholder = "Write message here..."
            }
            
            
            alertController.addAction(send)
            alertController.addAction(cancel)
            
            self.presentViewController(alertController, animated: true, completion: nil)
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
    
    func rejectPressedOfPendingRequestCell(cell: PendingRequestCell)
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let req = pendingArray[cell.tag]
            
            let dict = ["activityId":req.activity_id, "userId":req.user_id]
            ActRequest.rejectActRequestServiceWithBlock(dict, api_key: api_key, response:  { (success, error) in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if success
                {
                    print("request rejected")
                    self.getAllActs()
                }
                    
                else
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
    
    
    //MARK: AcceptedRequestCell Delegate
    
    func viewProfilePressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
    {
        let req = acceptedArray[cell.tag]
        if req.user_id == user_id
        {
            self.tabBarController?.selectedIndex = 3
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
            
            // send required data as well
            vc.otherUser_id = req.user_id
            print(vc.otherUser_id)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func messagePressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
    {
        if hasInternet
        {
            let alertController = UIAlertController(title: "Write Message Below", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            let send = UIAlertAction(title: "Send", style: .Default, handler: { (action) in
                
                
                let msgTF = alertController.textFields![0] as UITextField
                
                if (msgTF.text != "")
                {
                    if hasInternet
                    {
                        self.view.userInteractionEnabled = false
                        activityIndicator.startAnimating()
                        
                        let req = self.acceptedArray[cell.tag]
                        
                        let dict = ["activityId":req.activity_id, "receiverId":req.user_id, "message":msgTF.text!]
                        ActRequest.messageFromOwnerForActRequestServiceWithBlock(dict, api_key: self.api_key, response:  { (success, error) in
                            
                            if let error = error
                            {
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                                
                                //Create and add the Cancel action
                                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                                    //Do some stuff
                                }
                                alertController.addAction(cancelAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                                
                            else if success
                            {
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "", message:"Message sent successfully." , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                                
                                let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                        let alertController : UIAlertController = UIAlertController(title: "Attention!", message:"Internet Connection not available." , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
            })
            
            alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
                textField.placeholder = "Write message here..."
            }
            
            
            alertController.addAction(send)
            alertController.addAction(cancel)
            
            self.presentViewController(alertController, animated: true, completion: nil)
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
    
    func cancelPressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let req = acceptedArray[cell.tag]
            
            let dict = ["activityId":req.activity_id, "userId":req.user_id]
            ActRequest.cancelAcceptedActRequestServiceWithBlock(dict, api_key: api_key, response:  { (success, error) in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if success
                {
                    print("accepted ActRequest canceled.")
                    self.getAllActs()
                }
                    
                else
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
    
    
    //MARK: RejectedRequestCell Delegate
    
    func viewProfilePressedOfRejectedRequestCell(cell: RejectedRequestCell)
    {
        let req = rejectedArray[cell.tag]
        if req.user_id == user_id
        {
            self.tabBarController?.selectedIndex = 3
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
            
            // send required data as well
            vc.otherUser_id = req.user_id
            print(vc.otherUser_id)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func deletePressedOfRejectedRequestCell(cell: RejectedRequestCell)
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let req = rejectedArray[cell.tag]
            
            let dict = ["activityId":req.activity_id, "userId":req.user_id]
            ActRequest.deleteRejectedActRequestServiceWithBlock(dict, api_key: api_key, response:  { (success, error) in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else if success
                {
                    print("rejected ActRequest deleted.")
                    self.getAllActs()
                }
                    
                else
                {
                    self.view.userInteractionEnabled = true
                    activityIndicator.stopAnimating()
                    
                    let alertController : UIAlertController = UIAlertController(title: "Error", message:"Unknown error occured" , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
    
    
    //MARK: Action Methods
    
    @IBAction func back(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
}
