//
//  CreateActivityVC.swift
//  Banana
//
//  Created by musharraf on 4/19/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import GoogleMaps
import StoreKit

class CreateActivityVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, GMSMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{

    @IBOutlet weak var sport_type: UITextField!
    
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var time: UITextField!
    
    @IBOutlet weak var challenge_type: UITextField!
    
    @IBOutlet weak var participants: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var skill: UITextField!
    @IBOutlet weak var gender: UITextField!
    
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var desc: UITextView!
    
    var toolbar: UIToolbar = UIToolbar()
    var pickerView: UIPickerView = UIPickerView()
    var datePicker: UIDatePicker = UIDatePicker()
    
    var sport_typeArray: [SportCategory]!
    var challenge_typeArray: [Challenge]!
    
    var participantsArray: [String]!
    var ageArray: [String]!
    var skillArray: [String]!
    var genderArray: [String]!
    
    var api_key = ""
    
    var categoryId = ""
    var lat = ""
    var long = ""
    
    var placePicker : GMSPlacePicker?
    
    var products = [SKProduct]()
    var paymentParams: [String:String] = [:]
    let uncheckedImage = UIImage(named: "checkbox_unchecked")! as UIImage
    let checkedImage = UIImage(named: "checkbox_checked")! as UIImage
    
    @IBOutlet weak var sponsor_checkbox: CheckBox!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        
        
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.blackColor()
        
        if sport_typeArray.count > 0
        {
            let sport = sport_typeArray[0]
            categoryId = sport.ID
            sport_type.text = sport.name
            
            let ch = challenge_typeArray[0]
            challenge_type.text = ch.name
        }
        else
        {
            getCategories()
        }
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        date.text = formatter.stringFromDate(NSDate())
        
        formatter.dateFormat = "HH:mm"
        time.text = formatter.stringFromDate(NSDate().dateByAddingTimeInterval(30*60))
        
        participantsArray = ["Any", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
        ageArray = ["Any", "Teen Age", "20 - 29", "30 - 39", "40 - 49", "41 - 59", "50 - 59", "60+"]
        skillArray = ["Any", "Expert", "Perfect", "Middle", "Average"]
        genderArray = ["Any", "Male", "Female"]
        
        participants.text = "Any"
        age.text = "Any"
        skill.text = "Any"
        gender.text = "Any"
        
        desc.text = "Activity Description"
        desc.textColor = UIColor.lightGrayColor()
        desc.delegate = self
        desc.layer.cornerRadius = 5
        desc.layer.borderWidth = 0.5
        desc.layer.borderColor = UIColor.darkGrayColor().CGColor
        let defaults = NSUserDefaults.standardUserDefaults()
        api_key = defaults.valueForKey("api_key") as! String
        
        if let userLocation = LocationManager.sharedInstance.userLocation
        {
            lat = String(format: "%f", userLocation.coordinate.latitude)
            long = String(format: "%f", userLocation.coordinate.longitude)
            
            print(lat)
            print(long)
            
            
            if let address = defaults.valueForKey("location")
            {
                location.text = address as? String
            }
        }
        
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(self.cancelPressed))
        self.view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateActivityVC.handlePurchaseNotification(_:)),
                                                         name: IAPHelper.IAPHelperPurchaseNotification,
                                                         object: nil)
     
        products = []
        self.view.userInteractionEnabled = false
        activityIndicator.startAnimating()
        BananaProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                print(products)
                print("Products received")
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
            }else{
                print("Products not received")
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int)
    {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
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
    
    // Service Call
    
    func getCategories()
    {
        if hasInternet
        {
            SportCategory.getSportsServiceWithBlock(api_key, response: { (catagories, challenges, error) in
                if error != nil
                {
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
                    // check if sports count and challenges count > 0 after processing
                    
                    self.sport_typeArray = catagories
                    
                    self.sport_typeArray.removeAtIndex(0)
                    
                    let sport = self.sport_typeArray[0]
                    self.categoryId = sport.ID
                    self.sport_type.text = sport.name
                    
                    self.challenge_typeArray = challenges
                    
                    let ch = self.challenge_typeArray[0]
                    self.challenge_type.text = ch.name
                    
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
    
    
    //MARK: TextView Delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n") {
            print("Passs isFirstResponder")
            participants.becomeFirstResponder()
            
            textView.resignFirstResponder()
            return false
        } else {
            return textView.text.characters.count + (text.characters.count - range.length) <= 250
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.text == "Activity Description"
        {
            desc.text = "";
            desc.textColor = UIColor.blackColor()
        }
    }
    
    func textViewShouldReturn(textView: UITextView!) -> Bool {
//        self.view.endEditing(true);
        
        if desc.resignFirstResponder() {
            print("Passs isFirstResponder")
            participants.becomeFirstResponder()
        }
        
        return true;
    }
    
    
    func textViewDidEndEditing(textView: UITextView)
    {
        
         if desc.isFirstResponder()
        {
            participants.becomeFirstResponder()
            print("Passs becomeFirstResponder")
        }
        
        if textView.text == ""
        {
            desc.text = "Activity Description";
            desc.textColor = UIColor.lightGrayColor()
            participants.resignFirstResponder()
        }
    }
    
    
    //MARK: TextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        if (textField == date || textField == time)
        {
            setPickerToolBar()
            textField.inputView = datePicker;
            textField.inputAccessoryView = toolbar;
            
            if textField == date
            {
                datePicker.minimumDate = NSDate()
                datePicker.datePickerMode = .Date
            }
                
            else
            {
                datePicker.minimumDate = NSDate().dateByAddingTimeInterval(30*60)
                datePicker.datePickerMode = .Time
            }
        }
            
        else if textField != location
        {
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.reloadAllComponents()
            setPickerToolBar()
            textField.inputView = pickerView;
            textField.inputAccessoryView = toolbar;
        }
            
        else if textField == location
        {
            pickPlace()
            return false
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool
    {
        if textField == date
        {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let dateTime = formatter.stringFromDate(datePicker.date)
            let orignalDate = formatter.dateFromString(dateTime)!
            
            let nowDateString: String = formatter.stringFromDate(NSDate())
            let now = formatter.dateFromString(nowDateString)!
            
            let diff_comps = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: orignalDate, toDate: now, options: [])
            
            if  diff_comps.year == 0 && diff_comps.month == 0 && diff_comps.day == 0
            {
                formatter.dateFormat = "HH:mm"
                time.text = formatter.stringFromDate(NSDate().dateByAddingTimeInterval(30*60))
            }
        }
        
        return true
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
        if sport_type.isFirstResponder()
        {
            let sport = sport_typeArray[pickerView.selectedRowInComponent(0)]
            categoryId = sport.ID
            sport_type.text = sport.name
            sport_type.resignFirstResponder()
            
        }
            
        
        
            
        else if challenge_type.isFirstResponder()
        {
            let challange = challenge_typeArray[pickerView.selectedRowInComponent(0)]
            challenge_type.text = challange.name
            challenge_type.resignFirstResponder()
        }
            
        else if participants.isFirstResponder()
        {
            participants.text = participantsArray[pickerView.selectedRowInComponent(0)]
            participants.resignFirstResponder()
        }
            
        else if age.isFirstResponder()
        {
            age.text =  ageArray[pickerView.selectedRowInComponent(0)]
            age.resignFirstResponder()
        }
            
        else if skill.isFirstResponder()
        {
            skill.text = skillArray[pickerView.selectedRowInComponent(0)]
            skill.resignFirstResponder()
        }
            
        else if gender.isFirstResponder()
        {
            gender.text =  genderArray[pickerView.selectedRowInComponent(0)]
            gender.resignFirstResponder()
        }
        
        else if date.isFirstResponder()
        {
            
            let formatter = NSDateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            
            formatter.dateFormat = "yyyy-MM-dd"
//            formatter.timeZone = NSTimeZone(abbreviation: "UTC")
            
            date.text = formatter.stringFromDate(datePicker.date)
            date.resignFirstResponder()
        }
        else if time.isFirstResponder()
        {
            let formatter = NSDateFormatter()            
            formatter.dateFormat = "HH:mm"
            
            time.text = formatter.stringFromDate(datePicker.date)
            time.resignFirstResponder()
        }
    }
    
    func cancelPressed()
    {
        self.view.endEditing(true)
    }
    
    
    //MARK: PickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if sport_type.isFirstResponder()
        {
            return sport_typeArray.count
        }
        else if challenge_type.isFirstResponder()
        {
            return challenge_typeArray.count
        }
        
        else if participants.isFirstResponder()
        {
            return participantsArray.count
        }
        
        else if age.isFirstResponder()
        {
            return ageArray.count
        }
        
        else if skill.isFirstResponder()
        {
            return skillArray.count
        }
        
        else if gender.isFirstResponder()
        {
            print(genderArray.count)
            return genderArray.count
        }
        
        return  0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if sport_type.isFirstResponder()
        {
            let sport = sport_typeArray[row]
            return sport.name
        }
        else if challenge_type.isFirstResponder()
        {
            let challange = challenge_typeArray[row]
            return challange.name
        }
            
        else if participants.isFirstResponder()
        {
            return participantsArray[row]
        }
            
        else if age.isFirstResponder()
        {
            return ageArray[row]
        }
            
        else if skill.isFirstResponder()
        {
            return skillArray[row]
        }
            
        else if gender.isFirstResponder()
        {
            print(genderArray.count)
            return genderArray[row]
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // do something here if needed
    }
    
    
    //MARK: Action Methods
    
    @IBAction func back(sender: UIButton)
    {
        BananaProducts.store.restorePurchases()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func postActivity(sender: UIButton)
    {
        self.view.endEditing(true)
        
        if desc.text ==  "Activity Description"
        {
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Add some description about this activity." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        if hasInternet
        {
            self.view.userInteractionEnabled = false
            activityIndicator.startAnimating()
            
            if (lat != "") && (long != "") && (location.text != "")
            {
                var dict = ["categoryId":categoryId, "date":date.text!, "time":time.text!, "activity": challenge_type.text!, "description":desc.text!, "number":participants.text!, "startAge": age.text!, "endAge":"Any", "skill": skill.text!, "gender": gender.text!, "location[location]": location.text!, "location[latitude]": lat, "location[longitude]": long, "location[formatted_address]": location.text!]
                
                if(isChecked){
                    dict["payment[product_id]"] = paymentParams["product_id"]
                    dict["payment[transaction_id]"] = paymentParams["transaction_id"]
                    dict["payment[date]"] = paymentParams["date"]
                    dict["payment[order_id]"] = paymentParams["order_id"]
                    dict["payment[amount]"] = paymentParams["amount"]
                    dict["payment[status]"] = paymentParams["status"]
                }
                
                Activity.createActivityServiceWithBlock(dict, api_key: api_key, response: { (activity_id,created, error) in
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
                    
                    else if created
                    {
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        sender.setTitle("Already posted", forState: .Normal)
                        sender.userInteractionEnabled = false
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewControllerWithIdentifier("ActivityDetail") as! ActivityDetail
                        vc.act_id = activity_id
                        self.navigationController?.pushViewController(vc, animated: true)
                  
                    }
                        
                    else
                    {
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        let alertController : UIAlertController = UIAlertController(title: "Error!", message: "Cannot create activity." , preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Choose a valid place." , preferredStyle: UIAlertControllerStyle.Alert)
                
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
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Internet connection not found." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // The code snippet below shows how to create a GMSPlacePicker
    // centered on Sydney, and output details of a selected place.
    func pickPlace()
    {
        if let userLocation = LocationManager.sharedInstance.userLocation
        {
            let center = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
            let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            placePicker = GMSPlacePicker(config: config)
            
            
            placePicker!.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
                if let error = error
                {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let place = place
                {
                    print("Place name \(place.name)")
                    
                    self.lat = String(format: "%f", place.coordinate.latitude)
                    self.long = String(format: "%f", place.coordinate.longitude)
                    if let p = place.formattedAddress
                    {
                        self.location.text = p
                    }
                    
                    
                }
                else
                {
                    print("No place selected")
                }
            })
            
        }
        
        else
        {
            let alertController : UIAlertController = UIAlertController(title: "Error!", message: "Your location is not valid." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }

    @IBAction func sponsorActivity(sender: AnyObject) {
        print("Sponsor my activity")
        isChecked = !isChecked
        if(isChecked){
            print("Button CHecked")
            BananaProducts.store.buyProduct(self.products[0])
        }else{
            BananaProducts.store.restorePurchases()
        }
    }
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                sponsor_checkbox.setImage(checkedImage, forState: .Normal)
            } else {
                sponsor_checkbox.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    func handlePurchaseNotification(notification: NSNotification) {
        guard let transaction = notification.object as? SKPaymentTransaction else {isChecked = false; return }
        print(transaction)
        guard let userInfo = notification.userInfo as? [String:String]else{
            isChecked = false; return}
        if let type = userInfo["type"] {
            if(type == "complete"){
                isChecked = true
                let trasactionDate = "2016-06-08"
                let identifier = transaction.transactionIdentifier!
                let product = self.products[0]
                let productPrice: String = CreateActivityVC.priceFormatter.stringFromNumber(product.price)!
                paymentParams = ["product_id":transaction.payment.productIdentifier,"transaction_id":identifier,"date":trasactionDate,"order_id":identifier,"amount":productPrice,"status":"1"]
                print(paymentParams)
            }else{
                isChecked = false
            }
        }else{
            isChecked = false
        }
        
    }
    static let priceFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.formatterBehavior = .BehaviorDefault
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()

}
