//
//  MyActivitiesVC.swift
//  Banana
//
//  Created by musharraf on 4/25/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class MyActivitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, HideShowBtnDelegate, AllActivitiesCellDelegate
{

    
    @IBOutlet weak var tableView: UITableView!
    
    var pendingArray :[Activity] = []
    var currentArray :[Activity] = []
    var followedArray :[Activity] = []
    var pastArray :[Activity] = []
    
    var downBtnArray :[HideShowBtn] = []
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
        
        for _ in 0..<4
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
        
        
        self.getAllActs()
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
    
    func getAllActs() -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.stringFromDate(NSDate())
            
            formatter.dateFormat = "HH:mm"
            let time = formatter.stringFromDate(NSDate())
            let dict = ["date":date, "time":time]
            Activity.getMyActivitiesServiceWithBlock(dict, api_key: api_key) { (allActivities, error) in
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
                    
                else if allActivities.count > 0
                {
                    
                    self.pendingArray = allActivities[0]
                    self.currentArray = allActivities[1]
                    self.followedArray = allActivities[2]
                    self.pastArray = allActivities[3]
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
            }
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
        self.getAllActs()
    }
    
    
    //MARK: tableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let btn = downBtnArray[section]
        
        switch section
        {
        case 0:
            return btn.toggle ? pendingArray.count : 0
        case 1:
            return btn.toggle ? currentArray.count : 0
        case 2:
            return btn.toggle ? followedArray.count : 0
        case 3:
            return btn.toggle ? pastArray.count : 0
        default:
            print("default")
        }
        
        return 0
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AllActivitiesCell") as! AllActivitiesCell
        
        var act: Activity!
        
        switch indexPath.section
        {
        case 0:
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 250.0/255.0, blue: 231.0/255.0, alpha: 1.0)
            act = pendingArray[indexPath.row]
        case 1:
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 213.0/255.0, green: 242.0/166.0, blue: 222.0/255.0, alpha: 1.0)
            act = currentArray[indexPath.row]
        case 2:
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 228.0/255.0, green: 236.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            act = followedArray[indexPath.row]
        case 3:
            cell.contentView.backgroundColor = UIColor(colorLiteralRed: 230.0/255.0, green: 230.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            act = pastArray[indexPath.row]
        default:
            print("default")
        }
        
        
        cell.activity_challenge.text = act.activity_challange       //String(format: "Act Challenge %d", indexPath.row)
        cell.address.text = act.formatted_address       //String(format: "Address %d", indexPath.row)
        cell.date_time.text = String(format: "%@ at %@", act.date, act.time)
        Utility.downloadImageForButton(cell.owner_btn, url: act.avatar)
        cell.owner_btn.layer.cornerRadius = cell.owner_btn.frame.size.width / 2
        cell.owner_btn.tag = indexPath.row
        cell.sport_type.text = act.sports_title
        cell.tag = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
        cell.activity_id = act.ID
        
        cell.activity_delete_btn.hidden = true
        if(act.is_owner){
            cell.activity_delete_btn.hidden = false
        }
        
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
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
            if currentArray.count > 0
            {
                showHeader = true
            }
        case 2:
            if followedArray.count > 0
            {
                showHeader = true
            }
        case 3:
            if pastArray.count > 0
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
                title.text = "Current"
                
            case 2:
                headerView.backgroundColor = UIColor(colorLiteralRed: 188.0/255.0, green: 218.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                title.text = "People You Follow"
                
            case 3:
                headerView.backgroundColor = UIColor(colorLiteralRed: 196.0/255.0, green: 197.0/255.0, blue: 201.0/255.0, alpha: 1.0)
                title.text = "Past"
                
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
            
            let act = pendingArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = act.ID
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            
            let act = currentArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = act.ID
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            
            let act = followedArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = act.ID
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 3:
            
            let act = pastArray[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
            vc.act_id = act.ID
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
            if currentArray.count == 0
            {
                return 0
            }
        case 2:
            if followedArray.count == 0
            {
                return 0
            }
        case 3:
            if pastArray.count == 0
            {
                return 0
            }
        default:
            print("default")
        }
        return 46
    }
    
    
    //MARK: DownButton Delegate
    
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
        
//        let indexSet = NSMutableIndexSet()
//        indexSet.addIndex(btn.section!)
//        tableView.reloadSections(indexSet, withRowAnimation: .Automatic)
        
        
        tableView.reloadData()
        
    }
    
    
    //MARK: AllActivitiesCell Delegate
    
    func buttonTappedOfCell(cell: AllActivitiesCell)
    {
        // go to userProfileVC and load profile with user_id
        
        switch cell.section
        {
        case 0:
            
            let act = pendingArray[cell.tag]
            if act.owner_id == user_id
            {
                self.tabBarController?.selectedIndex = 3
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
                
                // send required data as well
                vc.otherUser_id = act.owner_id
                print(vc.otherUser_id)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 1:
            
            let act = currentArray[cell.tag]
            
            if act.owner_id == user_id
            {
                self.tabBarController?.selectedIndex = 3
            }
                
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
                
                // send required data as well
                vc.otherUser_id = act.owner_id
                print(vc.otherUser_id)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 2:
            
            let act = followedArray[cell.tag]
            
            if act.owner_id == user_id
            {
                self.tabBarController?.selectedIndex = 3
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
                
                // send required data as well
                vc.otherUser_id = act.owner_id
                print(vc.otherUser_id)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 3:
            
            let act = pastArray[cell.tag]
            
            if act.owner_id == user_id
            {
                self.tabBarController?.selectedIndex = 3
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
                
                // send required data as well
                vc.otherUser_id = act.owner_id
                print(vc.otherUser_id)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        default:
            print("default")
        }
    }
    
    func deleteActivityPressed(cell: AllActivitiesCell)
    {
        if(!hasInternet){
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message:"Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)

            return
        }
        
        self.view.userInteractionEnabled = false
        activityIndicator.startAnimating()
        
        let activityId = cell.activity_id
        let dict = ["activityId":activityId]
        Activity.deleteActivityServiceWithBlock(dict, api_key: api_key, response: { (message,deleted, error) in
            if error  != nil
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
                
            else if deleted
            {
                
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                self.deleteCellRow(cell)
                self.tableView.reloadData()
            }
                
            else
            {
                
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                let alertController : UIAlertController = UIAlertController(title: "Error!", message: "Failed to delete activity" , preferredStyle: UIAlertControllerStyle.Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    func deleteCellRow(cell: AllActivitiesCell){
        switch cell.section
        {
        case 0:
            self.pendingArray.removeAtIndex(cell.tag)
        case 1:
            self.currentArray.removeAtIndex(cell.tag)
        case 2:
            self.followedArray.removeAtIndex(cell.tag)
        case 3:
            self.pastArray.removeAtIndex(cell.tag)
        default:
            print("default")
        }
    }
    
}