//
//  MessagesVC.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate
{

    @IBOutlet weak var other_imageView: UIImageView!
    @IBOutlet weak var other_nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var textView_height_constraint: NSLayoutConstraint!
    
    var refreshControl: UIRefreshControl!
    var messages: [Message] = []
    var conversationId = ""
    var activityId = ""
    var api_key = ""
    var isOwner = false
    var user_imgURL = ""
    var other_imgURL = ""
    var user_id = ""
    var other_id = ""
    var other_name = ""
    
    var oldLines = 1
    var numberOfLines = 1
    var extra_space: CGFloat = 0.0
    var _currentKeyboardHeight: CGFloat = 0.0
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        // Do any additional setup after loading the view.
        
        Utility.downloadImageForImageView(other_imageView, url: other_imgURL)
        other_nameLbl.text = other_name
        
        
        api_key = NSUserDefaults.standardUserDefaults().valueForKey("api_key") as! String
        self.getMessages(conversationId)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        
        oldLines = 1
        numberOfLines = 1
        textView.delegate = self
        textView.layer.borderColor = UIColor.darkGrayColor().CGColor
        textView.layer.borderWidth = 2.0
        textView.layer.cornerRadius = 5.0
        textView.text = "Type Message here..."
        textView.textColor = UIColor.grayColor()
        textView.keyboardType = .Twitter
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
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
        
        if self.conversationId == dict["id"]
        {
            getMessages(conversationId)
        }
        
        else
        {
            getConversationByID(dict["id"]!)
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
    
    
    //MARK: KeyBoard Notification Observers
    
    func keyboardWillShow(notification: NSNotification) -> Void
    {
        if let info = notification.userInfo
        {
            if let kbSize = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
            {
                _currentKeyboardHeight = kbSize.height
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) -> Void
    {
        _currentKeyboardHeight = 0.0
    }
    
    
    //MARK: textView delegate
    
    func resetTextView(textView: UITextView) -> Void
    {
        self.textViewDidChange(textView)
    }
    
    func textViewDidChange(textView: UITextView)
    {
        numberOfLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if (numberOfLines == 1)
        {
            extra_space = textView.contentSize.height - textView.font!.lineHeight;
        }
        
        if (oldLines != numberOfLines)
        {
            if (numberOfLines >= 5)
            {
                var contentSize:CGFloat = 0.0
                
                for i in 0...5
                {
                    if (i == 0)
                    {
                        contentSize = extra_space + textView.font!.lineHeight;
                    }
                    else
                    {
                        contentSize = contentSize + textView.font!.lineHeight;
                    }
                }
                self.view.layoutIfNeeded()
                textView_height_constraint.constant = contentSize;
                self.view.layoutIfNeeded()
            }
                
            else
            {
                var contentSize:CGFloat = 0.0
                
                for i in 0..<numberOfLines
                {
                    if (i == 0)
                    {
                        contentSize = extra_space + textView.font!.lineHeight;
                    }
                    else
                    {
                        contentSize = contentSize + textView.font!.lineHeight;
                    }
                }
                self.view.layoutIfNeeded()
                textView_height_constraint.constant = contentSize;
                self.view.layoutIfNeeded()
                
            }
            
            oldLines = numberOfLines;
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if (textView.text! == "Type Message here...")
        {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        self.view.layoutIfNeeded()
        bottom_constraint.constant = _currentKeyboardHeight
        
        UIView.animateWithDuration(0.3, animations: {
          
            self.view.layoutIfNeeded()
            if self.messages.count > 0
            {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
            
        })
        
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if (textView.text! == "")
        {
            textView.text = "Type Message here..."
            textView.textColor = UIColor.grayColor()
        }
        self.view.layoutIfNeeded()
        bottom_constraint.constant = _currentKeyboardHeight
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.view.layoutIfNeeded()
            
        })
    }
    
    
    // Service Call
    
    func refresh()
    {
        self.getMessages(conversationId)
    }
    
    func getConversationByID(conversationId: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["conversationId":conversationId]
            
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
                    self.conversationId = con.ID
                    self.activityId = con.activity_id
                    
                    if con.is_owner
                    {
                        self.user_id = con.owner_id
                        self.other_id = con.receiver_id
                        self.isOwner = true
                        self.user_imgURL = con.avatar_owner
                        self.other_imgURL = con.avatar_receiver
                        self.other_name = con.name_receiver
                    }
                    else
                    {
                        self.user_id = con.receiver_id
                        self.other_id = con.owner_id
                        self.isOwner = false
                        self.user_imgURL = con.avatar_receiver
                        self.other_imgURL = con.avatar_owner
                        self.other_name = con.name_owner
                    }
                    
                    Utility.downloadImageForImageView(self.other_imageView, url: self.other_imgURL)
                    self.other_nameLbl.text = self.other_name
                    
                    self.getMessages(self.conversationId)
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
    
    func getMessages(conversationId: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.stopAnimating()
            
            let dict = ["conversationId":conversationId]
            Message.getMessagesForConversationServiceWithBlock(dict, api_key: api_key, response: { (messages, error) in
                
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
                    self.messages = messages
                    self.tableView.reloadData()
                    if self.messages.count > 0
                    {
                        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                    }
                    
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
    
    func sendMsg(receiver_id: String, message: String) -> Void
    {
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let dict = ["activityId":activityId, "receiverId":receiver_id, "message":message]
            
            Message.sendMsgServiceWithBlock(dict, api_key: api_key, response: { (sent, error) in
                
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
                    
                    /*
                    let msg = Message()
                    msg.is_owner = self.isOwner
                    msg.body = message
                    
                    if self.isOwner
                    {
                        msg.avatar_owner = self.user_imgURL
                        msg.avatar_receiver = self.other_imgURL
                    }
                    else
                    {
                        msg.avatar_owner = self.other_imgURL
                        msg.avatar_receiver = self.user_imgURL
                    }
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    
                    msg.date = dateFormatter.stringFromDate(NSDate())
                    
                    self.messages.append(msg)
                    self.tableView.reloadData()
                    
                    let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
 
                    */
                    self.textView.text = "Type Message here..."
                    self.textView.textColor = UIColor.grayColor()
                    self.resetTextView(self.textView)
                    self.textView.resignFirstResponder()
                    self.getMessages(self.conversationId)
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
    
    
    //MARK: tableView DataSource, Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let msg = messages[indexPath.row]
        
        if msg.is_owner
        {
            let cell = tableView.dequeueReusableCellWithIdentifier( "OwnerMsgCell", forIndexPath: indexPath) as! OwnerMsgCell
            Utility.downloadImageForImageView(cell.imgView, url: msg.avatar)
            cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2
            
            cell.msg.text = msg.body
            cell.date_time.text = msg.date
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            return cell
        }
            
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier( "OtherUserMsgCell", forIndexPath: indexPath) as! OtherUserMsgCell
            
            Utility.downloadImageForImageView(cell.imgView, url: msg.avatar)
            cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2
            
            cell.msg.text = msg.body
            cell.date_time.text = msg.date
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == messages.count - 1
        {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
    }

    
    //MARK: Action Methods
    
    @IBAction func back(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendMsgPressed(sender: UIButton)
    {
        // call the service here
        
        if textView.text != ""  && textView.text != "Type Message here..."
        {
            self.sendMsg(other_id, message: textView.text)
        }
        
    }
    
    @IBAction func visitOtherPressed(sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VisitProfile") as! VisitProfile
        
        // send required data as well
        vc.otherUser_id = other_id
        print(vc.otherUser_id)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
