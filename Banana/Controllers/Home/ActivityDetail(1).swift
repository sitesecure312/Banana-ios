//
//  ActivityDetail.swift
//  Banana
//
//  Created by musharraf on 4/21/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import GoogleMaps
import Social



class ActivityDetail: UIViewController, GMSMapViewDelegate
{

    @IBOutlet weak var map: GMSMapView!

    @IBOutlet weak var activity_challenge: UILabel!
    @IBOutlet weak var owner_btn: UIButton!
    @IBOutlet weak var sport_type: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var dateNtime: UILabel!
    
    @IBOutlet weak var formatted_address: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var skill: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var participants: UILabel!
    @IBOutlet weak var ask_btn: UIButton!
    @IBOutlet weak var lblcorner: UILabel!
    
    @IBOutlet var view_comment_box: UIView!
    var api_key = ""
    var user_id = ""
    var owner_id = ""
    var act_id = ""
    
    var requestSent = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        user_id = defaults.valueForKey("user_id") as! String
        api_key = defaults.valueForKey("api_key") as! String
        
        desc.text = ""
        formatted_address.text = ""
        gender.text = ""
        skill.text = ""
        age.text = ""
        participants.text = ""
        
//        let path = UIBezierPath(roundedRect:view_comment_box.bounds, byRoundingCorners:[.TopRight, .BottomLeft], cornerRadii: CGSizeMake(8, 8))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.CGPath
//        view_comment_box.layer.mask = maskLayer
        
//        view_comment_box.roundCorners([.TopLeft , .BottomLeft], radius: 10)
        
//        view_comment_box.roundCorners([.TopRight], radius: 8)
//        view_comment_box.roundCorners([.BottomLeft], radius: 8)
//        view_comment_box.roundCorners([.BottomRight], radius: 8)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.getActDetil(act_id)
        
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
        getActDetil(dict["id"]!)
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
    
    func getActDetil(act_id : String)
    {
        if  hasInternet
        {
            
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["id":act_id]
            Activity.getActDetailServiceWithBlock(dict, api_key: api_key, response: { (activity, error) in
                if let error  = error
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
                
                else if let act = activity
                {
                    
                    self.owner_id = act.owner_id
                    self.act_id = act.ID
                    
                    self.map.delegate = self
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(act.latitude, longitude: act.longitude, zoom: 12)
                    self.map.camera = camera
                    
                    let marker = GMSMarker()
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
                    
//                    marker.icon 
                    
                    // Resize image
//                    let pinImage = UIImage(named: "pin maps.png")
                    let size = CGSize(width: 27, height: 40)
                    UIGraphicsBeginImageContext(size)
                    marker.icon!.drawInRect(CGRectMake(0, 0, size.width, size.height))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                  
                    marker.icon = resizedImage
                    
                    
                    
                    
                    
                    marker.title = act.formatted_address
                    marker.map = self.map
                    
                    self.map.animateToLocation(marker.position)
                    self.map.animateToBearing(0)
                    self.map.animateToViewingAngle(0)
                    self.map.animateToZoom(15)
                    
                    self.activity_challenge.text = act.activity_challange
                    self.desc.text = act.desc
                    self.dateNtime.text = String(format: "%@ at %@", act.date, act.time)
                    Utility.downloadImageForButton(self.owner_btn, url: act.avatar)
                    self.owner_btn.layer.cornerRadius = self.owner_btn.frame.size.width / 2
                    self.owner_btn.userInteractionEnabled = false
                    self.sport_type.text = act.sports_title
                    self.formatted_address.text = act.formatted_address
                    self.gender.text = act.gender
                    self.age.text = act.age
                    self.skill.text = act.skill
                    self.participants.text = act.participants
                    
                    // ask_btn logic here
                    if self.owner_id == self.user_id
                    {
                        if activity?.request_status == "0"
                        {
                            self.ask_btn.setTitle("No Request Yet", forState: .Normal)
                            self.ask_btn.userInteractionEnabled = false
                        }
                        else
                        {
                            self.ask_btn.setTitle("View Request(s)", forState: .Normal)
                        }
                    }
                    
                    else
                    {
                        if activity?.request_status == ""
                        {
                            self.ask_btn.setTitle("Ask to Join", forState: .Normal)
                            self.requestSent = false
                        }
                        else if activity?.request_status == "0"
                        {
                            self.ask_btn.setTitle("Cancel Request", forState: .Normal)
                            self.requestSent = true
                        }
                        else if activity?.request_status == "1"
                        {
                            // requests has been accepted by owner
                            self.ask_btn.setTitle("Request Accepted", forState: .Normal)
                        }
                        else if activity?.request_status == "2"
                        {
                            // requests has been accepted by owner
                            self.ask_btn.setTitle("Request Rejected", forState: .Normal)
                        }
                    }
                    
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
    
    @IBAction func askPressed(sender: UIButton)
    {
        // do something
    
        if hasInternet
        {
            var dict : [String: String] = [:]
            
            if user_id == owner_id
            {
                // go to viewRequests VC
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("ViewActivityRequests") as! ViewActivityRequests
                vc.act_id = act_id
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            else
            {
                if requestSent
                {
                    self.view.userInteractionEnabled = false
                    activityIndicator.startAnimating()
                    
                    dict = ["activityId":self.act_id]
                    Activity.cancelRequestServiceWithBlock(dict, api_key: api_key, response: { (success, error) in
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
                            self.ask_btn.setTitle("Ask to Join", forState: .Normal)
                            self.requestSent = false
                            
                            self.view.userInteractionEnabled = true
                            activityIndicator.stopAnimating()
                            
                        }
                    })
                }
                    
                else
                {
                    self.sendRequest()
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

    
    func sendRequest() -> Void
    {
        var dict : [String: String] = [:]
        let alertController = UIAlertController(title: "Write Message Below", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let send = UIAlertAction(title: "Send", style: .Default, handler: { (action) in
            
            let msgTF = alertController.textFields![0] as UITextField
            
            if (msgTF.text != "")
            {
                if hasInternet
                {
                    self.view.userInteractionEnabled = false
                    activityIndicator.startAnimating()
                    
                    dict = ["activityId":self.act_id,"ownerId":self.owner_id, "userMessage": msgTF.text!]
                    Activity.askToJoinServiceWithBlock(dict, api_key: self.api_key, response: { (success, error) in
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
                            self.ask_btn.setTitle("Cancel Request", forState: .Normal)
                            self.requestSent = true
                            
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
                
            else
            {
                let ac = UIAlertController(title: "Attention!", message: "Write something to activity owner.", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
                    
                    self.sendRequest()
                })
                
                ac.addAction(cancel)
                self.presentViewController(ac, animated: true, completion: nil)
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Write your message here..."
        }
        
        
        alertController.addAction(send)
        alertController.addAction(cancel)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func back(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func shareButtonPressed(sender: UIButton)
    {
        var sharingItems = [AnyObject]()
        if var text = self.activity_challenge.text {
            text = text + "\n" + self.desc.text! + "\n" + self.dateNtime.text! + "\n"
            sharingItems.append(text)
        }
        if let url = NSURL(string: "https://thebananaapp.com/") {
            sharingItems.append(url)
        }

        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    
}
