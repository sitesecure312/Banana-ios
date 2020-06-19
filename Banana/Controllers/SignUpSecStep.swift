//
//  SignUpSecStep.swift
//  Banana
//
//  Created by musharraf on 4/13/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import CoreLocation



class SignUpSecStep: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var profile_imageView: UIImageView!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var about_me: UITextView!

    var toolbar: UIToolbar = UIToolbar()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var datePicker: UIDatePicker = UIDatePicker()
    var genderPicker: UIPickerView = UIPickerView()
    var genderArray: [String] = ["Male", "Female"]
    
    var email = ""
    var password = ""
    var age_str = ""
    var gender_str = ""
    var name_str = ""
    var imgURL_str = ""
    var user_age = 0
    var lat = ""
    var long = ""
    var formatted_address = ""
    
//    var manager: OneShotLocationManager?
//    var locationManager : CLLocationManager?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        
        
        if age_str != ""
        {
            age.text = "\(age_str) Years"
        }
        
        gender.text = gender_str
        name.text = name_str
        
        if imgURL_str != ""
        {
            Utility.downloadImageForImageView(profile_imageView, url: imgURL_str)
        }
        
        profile_imageView.layer.cornerRadius = profile_imageView.frame.size.width/2;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        datePicker.datePickerMode = .Date
        
        let date = NSDate()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        components.year = components.year - 150;
        datePicker.minimumDate = NSCalendar.currentCalendar().dateFromComponents(components)
        components.year = components.year + 150 - 12;
        datePicker.maximumDate = NSCalendar.currentCalendar().dateFromComponents(components)
        
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.blackColor()
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.selectRow(0, inComponent: 0, animated: true)
        
        about_me.text = "About Yourself"
        about_me.textColor = UIColor.lightGrayColor()
        about_me.delegate = self
        about_me.layer.cornerRadius = 5
        about_me.layer.borderWidth = 0.5
        about_me.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.hidden = true;
        activityIndicator.center = self.view.center;
        self.view.addSubview(activityIndicator)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.logOut), name: loggedOut, object: nil)
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logOut() -> Void
    {
        self.dismissViewControllerAnimated(true)
        {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    //MARK: TextView Delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n") {
            print("Passs isFirstResponder")
            about_me.resignFirstResponder()
            return false
        } else {
            return textView.text.characters.count + (text.characters.count - range.length) <= 250
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.text == "About Yourself"
        {
            about_me.text = "";
            about_me.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if textView.text == ""
        {
            about_me.text = "About Yourself";
            about_me.textColor = UIColor.lightGrayColor()
        }
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if (textField != name)
        {
            setPickerToolBar()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if (textField == age)
        {
            textField.inputView = datePicker;
            textField.inputAccessoryView = toolbar;
        }
            
        else if (textField == gender)
        {
            textField.inputView = genderPicker;
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
        if age.isFirstResponder()
        {
            let cal = NSCalendar.currentCalendar()
            let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
           
            

            let picker_comps: NSDateComponents = cal.components(unitFlags, fromDate: (datePicker.date))
            let nowComps: NSDateComponents = cal.components(unitFlags, fromDate: NSDate())
            
            var years = nowComps.year - picker_comps.year;
            let months = nowComps.month - picker_comps.month;
            let days = nowComps.day - picker_comps.day;
            
            print("%ld , %ld , %ld ", years, months, days)
            
            if ((months > 0 && days > 0 ) || (months > 0 && days == 0 ) || (months == 0 && days > 0 ))
            {
                years += 1;
            }
                
            else if ((months < 0 && days < 0 ) || (months < 0 && days == 0 ) || (months == 0 && days < 0 ))
            {
                years -= 1;
            }
            
            age.text = "\(years) Years"
            user_age = years;
            age.resignFirstResponder()
        }
        
        else if gender.isFirstResponder()
        {
            gender.text = genderArray[(genderPicker.selectedRowInComponent(0))];
            gender.resignFirstResponder()
        }
    }
    
    func cancelPressed()
    {
        if age.isFirstResponder()
        {
            age.resignFirstResponder()
        }
        else if gender.isFirstResponder()
        {
            gender.resignFirstResponder()
        }
    }
    
    
    //MARK: ImagePicker DataSource
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true) { 
            
            // do something here if needed
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        profile_imageView.image = chosenImage
        
        picker.dismissViewControllerAnimated(true) { 
            
            // do something here if needed
            
        }
    }
    
    
    //MARK: PickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return genderArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return genderArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // do something here if needed
    }
    
    
    //MARK: IBAction Methods
    
    @IBAction func imagePickerBtnPressed(sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: "Choose or take photos", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let galleryAction = UIAlertAction(title: "Open Gallery", style: .Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
            {
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(self.imagePicker, animated: true, completion: {
                    
                })
                
            }
            else
            {
                let ac = UIAlertController(title: nil, message: "Gallery not available", preferredStyle: .ActionSheet)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                    
                }
                ac.addAction(cancelAction)
                
                self.presentViewController(ac, animated: true, completion: {
                    
                })
            }
        }
        alertController.addAction(galleryAction)
        
        let camAction = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.Camera)
            {
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .Camera
                if UIImagePickerController.isCameraDeviceAvailable(.Front)
                {
                    self.imagePicker.cameraDevice = .Front;
                }
                self.presentViewController(self.imagePicker, animated: true, completion: {
                    
                })
                
            }
            
            else
            {
                let ac = UIAlertController(title: nil, message: "Camere not available", preferredStyle: .ActionSheet)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                    
                }
                ac.addAction(cancelAction)
                
                self.presentViewController(ac, animated: true, completion: {
                    
                })
            }
        }
        alertController.addAction(camAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }

    @IBAction func goPressed(sender: UIButton)
    {
        if !(name.text!.isEmpty) && !(age.text!.isEmpty) && !(gender.text!.isEmpty) && !(about_me.text!.isEmpty)
        {
            if about_me.text != "About Yourself"
            {
                if hasInternet
                {
                    if let userLocation = LocationManager.sharedInstance.userLocation
                    {
                        lat = String(format: "%f", userLocation.coordinate.latitude)
                        long = String(format: "%f", userLocation.coordinate.longitude)
                        
                        print(lat)
                        print(long)
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        if let address = defaults.valueForKey("location")
                        {
                            formatted_address = address as! String
                        }
                        
                        if (lat != "") && (long != "") && (formatted_address != "")
                        {
                            if hasInternet
                            {
                                var device_token = ""
                                if let token = NSUserDefaults.standardUserDefaults().valueForKey("tokenString")
                                {
                                    device_token = token as! String
                                }
                                
                                self.view.userInteractionEnabled = false
                                activityIndicator.startAnimating()
                                
                                let dict = ["name":name.text!, "email":email, "password":password, "age":"\(user_age)", "gender":gender.text!, "aboutMe":about_me.text!, "location[location]": formatted_address, "location[latitude]": lat, "location[longitude]": long, "location[formatted_address]": formatted_address, "pushId": device_token, "pushType":"ios"]
                                
                                print(dict)
                                
                                User.userRegistrationServiceWithBlock(dict, image: profile_imageView.image, response: { (user, message, error) in
                                    
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
                                        
                                    else if user != nil
                                    {
                                        // signup successful
                                        // save user to defaults
                                        
                                        
                                        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                        defaults.setValue(user?.user_id, forKey: "user_id")
                                        defaults.setValue(user?.api_key, forKey: "api_key")
                                        defaults.synchronize()
                                        
                                        // go to tabbar
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBar") as! MainTabBar
                                        self.presentViewController(vc, animated: true, completion: {
                                            
                                            print("tabbar presented")
                                            
                                            self.view.userInteractionEnabled = true
                                            activityIndicator.stopAnimating()
                                            
                                            self.navigationController?.popToRootViewControllerAnimated(false)
                                        })
                                        
                                        
                                    }
                                        
                                    else
                                    {
                                        
                                        self.view.userInteractionEnabled = true
                                        activityIndicator.stopAnimating()
                                        
                                        let alertController : UIAlertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                                        
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
                                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Not Internet connection found." , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                        let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Your location is not found, make sure you are connected to Internet, and have granted location access in settings." , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        let settingAction: UIAlertAction = UIAlertAction(title: "Open Settings", style: .Default) { action -> Void in
                            //Do some stuff
                            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                                UIApplication.sharedApplication().openURL(appSettings)
                            }
                        }
                        alertController.addAction(settingAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
                else
                {
                    let alertController : UIAlertController = UIAlertController(title: "Attention!", message: " Internet connection Not found." , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Add something about yourself" , preferredStyle: UIAlertControllerStyle.Alert)
                
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
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Please fill required fields" , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
    
}