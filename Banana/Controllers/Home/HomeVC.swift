//
//  HomeVC.swift
//  Banana
//
//  Created by musharraf on 4/19/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import GoogleMaps

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}


class HomeVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, AllActivitiesCellDelegate
{
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hideButton2bottom: NSLayoutConstraint!
    @IBOutlet weak var sport_TF: UITextField!
    @IBOutlet weak var hide_btn: UIButton!
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var toolbar: UIToolbar = UIToolbar()
    var pickerView: UIPickerView = UIPickerView()
    var sport_typeArray: [SportCategory] = []
    var challenge_typeArray: [Challenge] = []
    var activities: [Activity] = []
    
    var api_key = ""
    var bottom_constraint: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        map.addSubview(hide_btn);
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        sport_TF.rightViewMode = .Always
        let rightView = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 16))
        rightView.image = UIImage(named: "arrow_down")
        rightView.contentMode = .Center
        sport_TF.rightView = rightView
        
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.blackColor()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        print(api_key)
        
        //bottom_constraint = 0.0;

        //bottom_constraint =  self.hideButton2bottom.constant
        bottom_constraint =  266.0
        
    
            
        self.getCategories()
        self.getAllActivities()
        
        map.delegate = self
        
        if let userLocation = LocationManager.sharedInstance.userLocation
        {
            let camera = GMSCameraPosition.cameraWithLatitude(userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15)
            map.camera = camera
            map.myLocationEnabled = true
            
            //if let mylocation = map.myLocation
            if map.myLocation != nil
            {
                //print("User's location: \(mylocation)")
                self.focusOnCoordinate(userLocation.coordinate)
            }
            
            else
            {
                print("User's location is unknown.")
            }
            
        }
        
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
        
        if sport_typeArray.count > 0
        {
            let sport = sport_typeArray[(pickerView.selectedRowInComponent(0))]
            self.getActivitesByID(sport.ID)
        }
        
        
        hide_btn.roundCorners([.TopLeft], radius: 20)
        //hide_btn.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,50)
        
        map.layer.borderWidth = 5
        map.layer.borderColor = UIColor(red: 44.0 / 255.0, green: 165.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0).CGColor
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
        //print(dict)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
        vc.act_id = dict["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
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
        //print(dict)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        vc.otherUser_id = dict["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Services
    
    func getCategories()
    {
        if hasInternet
        {
            
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            SportCategory.getSportsServiceWithBlock(api_key, response: { (catagories, challenges, error) in
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
                    self.sport_typeArray = catagories
                    self.challenge_typeArray = challenges
                    
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
            
            Activity.getActivitiesServiceWithBlock(nil, api_key: api_key, response: { (activities, error) in
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
                    self.drawPins()
                    self.tableView.reloadData()
                    
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
    
    func getActivitesByID(sport_id: String)
    {
        self.activities = []
        self.tableView.reloadData()
        self.map.clear()
        
        if hasInternet
        {
            
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict: [String: String] = ["categoryId":sport_id]
            Activity.getActivitiesServiceWithBlock(dict, api_key: api_key, response: { (activities, error) in
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
                    if activities.count > 0
                    {
                        self.activities = activities
                        self.drawPins()
                        self.tableView.reloadData()
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                    }
                    else
                    {
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        let alertController : UIAlertController = UIAlertController(title: "", message:"No Activity found for selected sport." , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
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
    
    
    //MARK: TextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        setPickerToolBar()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if (textField == sport_TF)
        {
            textField.inputView = pickerView;
            textField.inputAccessoryView = toolbar;
        }
    }
    
    
    //MARK: Toolbar setup
    
    func setPickerToolBar()
    {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        let doneBtn : UIBarButtonItem = UIBarButtonItem.init(title: "Done", style: .Done, target: self, action: #selector(self.donePressed))
        doneBtn.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Normal)
        
        let cancelBtn : UIBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .Done, target: self, action: #selector(self.cancelPressed))
        cancelBtn.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Normal)
        
        toolbar.setItems([cancelBtn, flexibleSpace, doneBtn], animated: true)
    }
    
    func donePressed()
    {
        if sport_TF.isFirstResponder()
        {
            if sport_typeArray.count > 0
            {
                let sport = sport_typeArray[(pickerView.selectedRowInComponent(0))]
                sport_TF.text = sport.name
                sport_TF.resignFirstResponder()
                self.getActivitesByID(sport.ID)
            }
            else
            {
                sport_TF.resignFirstResponder()
            }
        }
    }
    
    func cancelPressed()
    {
        if sport_TF.isFirstResponder()
        {
            sport_TF.resignFirstResponder()
        }
    }
    
    
    //MARK: PickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return  sport_typeArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let sport = sport_typeArray[row]
        return sport.name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // do something here if needed
    }
    
    
    //MARK: GoogleMaps Delegate
    
    func drawPins()
    {
        map.clear()
        var i = 0
        for act in activities
        {
            
            let marker = GMSMarker()
            marker.userData = act
            marker.position = CLLocationCoordinate2DMake(act.latitude, act.longitude)
            
            switch act.sports_id {
            case "1": //Cricket
                marker.icon = UIImage(named: "pin_01")
            case "2": //Football
                marker.icon = UIImage(named: "pin_02")
            case "3":  //Tennis
                marker.icon = UIImage(named: "pin_03")
            case "4":  //Running
                marker.icon = UIImage(named: "pin_04")
            case "5":  //Hockey
                marker.icon = UIImage(named: "pin_05")
            case "6":  //Baseball
                marker.icon = UIImage(named: "pin_06")
            case "7":  //Cycling
                marker.icon = UIImage(named: "pin_07")
            case "8":  //Golf
                marker.icon = UIImage(named: "pin_08")
            case "9":  //Hunting
                marker.icon = UIImage(named: "pin_09")
            case "10":  //Wrestling
                marker.icon = UIImage(named: "pin_10")
            case "11":  //Martial Arts
                marker.icon = UIImage(named: "pin_11")
            case "12":  //Shooting
                marker.icon = UIImage(named: "pin_12")
            case "13":  //Mountain Biking
                marker.icon = UIImage(named: "pin_13")
            case "14":  //Soccer
                marker.icon = UIImage(named: "pin_14")
            case "15":  //Volleyball
                marker.icon = UIImage(named: "pin_15")
            case "16":  //Fishing
                marker.icon = UIImage(named: "pin_16")
            default:
                marker.icon = UIImage(named: "pin_00")
                //print("default")
            }
            
            let size = CGSize(width: 27, height: 40)
            UIGraphicsBeginImageContext(size)
            marker.icon!.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            marker.icon = resizedImage
            
            marker.title = act.formatted_address
//            marker.snippet = "Australia"
            marker.map = self.map
            if i == 0
            {
                self.focusOnCoordinate(marker.position)
                i = 1
            }
        }
        
    }
    
    func focusOnCoordinate(coordinate: CLLocationCoordinate2D) -> Void
    {
        map.animateToLocation(coordinate)
        map.animateToBearing(0)
        map.animateToViewingAngle(0)
        map.animateToZoom(15)
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker)
    {
        let act = marker.userData as! Activity
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
        vc.act_id = act.ID
        self.navigationController?.pushViewController(vc, animated: true)
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
        cell.activity_challenge.text =  String(format: "%@ %@", act.name, act.activity_challange)  + " for " + act.sports_title
        
        cell.address.text = act.formatted_address
        
        let ActDateTime = act.date + " " + act.time
        //print(myDateTime)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let DTObj = dateFormatter.dateFromString(ActDateTime)
        
        //now convert the above date object in required format
        dateFormatter.dateFormat = "EEEE, MMMM dd yyyy hh:mm a"
        let conDate = dateFormatter.stringFromDate(DTObj!)

        cell.date_time.text = conDate
      //cell.date_time.text = String(format: "%@ at %@", act.date, act.time)
        
        cell.sport_type.text = act.sports_title
        
        Utility.downloadImageForButton(cell.owner_btn, url: act.avatar)
        
        cell.owner_btn.layer.cornerRadius = cell.owner_btn.frame.size.width / 2
        cell.owner_btn.tag = indexPath.row
        cell.delegate = self
        cell.tag = indexPath.row
        
        if(act.sponsored == 1){
            cell.backgroundColor = Utility.hexStringToUIColor("#ffc2cd")
        }else{
            cell.backgroundColor = UIColor.whiteColor()
        }
        
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
    
    //MARK: AllActivitiesCell Delegate
    
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
        // go to userProfileVC and load profile with user_id
        let act = activities[cell.tag]
        if act.owner_id == NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
        {
            NSNotificationCenter.defaultCenter().postNotificationName("didSelectTab", object: nil, userInfo: ["tag":-4])
        }
            
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
            
            // send required data as well
            vc.otherUser_id = act.owner_id
            //print(vc.otherUser_id)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK: Action Methods
    
    @IBAction func createActivity(sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CreateActivityVC") as! CreateActivityVC
        
        vc.challenge_typeArray = self.challenge_typeArray
        vc.sport_typeArray = self.sport_typeArray
        vc.sport_typeArray.removeAtIndex(0)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func toggleFullMap(sender: UIButton)
    {
        self.view.layoutIfNeeded()
        if self.bottom_constraint > 0.0
        {
            hide_btn.setTitle(" Show", forState: .Normal)
            hide_btn.setImage(UIImage(named: "arrow_up"), forState: UIControlState.Normal);
            //hide_btn.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,50)
            self.tableViewHeightConstraint.constant = 0
            self.bottom_constraint = 0
            self.view.layoutIfNeeded()
        }
        else
        {
            hide_btn.setTitle(" Hide", forState: .Normal)
            hide_btn.setImage(UIImage(named: "arrow_down"), forState: UIControlState.Normal);
            
            //hide_btn.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,50)
            self.tableViewHeightConstraint.constant = 266
            self.bottom_constraint = 266
            self.view.layoutIfNeeded()
        }
    }
    func deleteActivityPressed(cell: AllActivitiesCell)
    {
        
    }

}
