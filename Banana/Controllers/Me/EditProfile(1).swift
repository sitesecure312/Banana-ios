//
//  EditProfile.swift
//  Banana
//
//  Created by musharraf on 5/6/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import GoogleMaps

class EditProfile: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, GMSMapViewDelegate
{
    @IBOutlet weak var profile_imageBtn: UIButton!
    
    @IBOutlet weak var name_TF: UITextField!
    @IBOutlet weak var age_TF: UITextField!
     @IBOutlet weak var gender_TF: UITextField!
    @IBOutlet weak var desc_textView: UITextView!
    @IBOutlet weak var location_TF: UITextField!
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var toolbar: UIToolbar = UIToolbar()
    var datePicker: UIDatePicker = UIDatePicker()
    var genderPicker: UIPickerView = UIPickerView()
    var genderArray: [String] = ["Male", "Female"]
    
    var placePicker : GMSPlacePicker?
    
    var image : UIImage?
    var name = ""
    var age = ""
    var gender = ""
    var desc = ""
    var location = ""
//    let chosenImage 
    var user_age = 0
    var lat = ""
    var long = ""
    var formatted_address = ""
    var api_key = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let img = image
        {
            profile_imageBtn.setBackgroundImage(img, forState: .Normal)
            profile_imageBtn.layer.cornerRadius = profile_imageBtn.frame.size.height / 2
        }
        else
        {
            profile_imageBtn.setBackgroundImage(UIImage(named: "person"), forState: .Normal)
            profile_imageBtn.layer.cornerRadius = profile_imageBtn.frame.size.height / 2
        }
        user_age = Int(age)!
        name_TF.text = name
        age_TF.text = age
        gender_TF.text = gender
        location_TF.text = location
        
        profile_imageBtn.layer.cornerRadius = profile_imageBtn.frame.size.height / 2
        
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
        
        if desc == ""
        {
            desc_textView.text = "About Yourself"
            desc_textView.textColor = UIColor.lightGrayColor()
        }
        else
        {
            desc_textView.text = desc
            desc_textView.textColor = UIColor.blackColor()
        }
        
        desc_textView.delegate = self
        desc_textView.layer.cornerRadius = 5
        desc_textView.layer.borderWidth = 0.5
        desc_textView.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.hidden = true;
        activityIndicator.center = self.view.center;
        self.view.addSubview(activityIndicator)
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

    
    //MARK: ImagePicker DataSource
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true) {
            
            // do something here if neededimagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
            
        }
    }
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        
//        let imageName = imageURL.path!.lastPathComponent
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
//        let localPath = documentDirectory.stringByAppendingPathComponent(imageName)
//        
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        let data = UIImagePNGRepresentation(image)
//        data.writeToFile(localPath, atomically: true)
//        
//        let imageData = NSData(contentsOfFile: localPath)!
//        let photoURL = NSURL(fileURLWithPath: localPath)
//        let imageWithData = UIImage(data: imageData)!
//        
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
       
        
        profile_imageBtn.setBackgroundImage(chosenImage, forState: .Normal)
        profile_imageBtn.layer.cornerRadius = profile_imageBtn.frame.size.height / 2
        image = chosenImage
        picker.dismissViewControllerAnimated(true) {
            
            // do something here if needed
            
        }
    }
    
    
    //MARK: TextView Delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        
        if(text == "\n") {
            print("Passs isFirstResponder")
            
            desc_textView.resignFirstResponder()
            return false
        } else {
            return textView.text.characters.count + (text.characters.count - range.length) <= 250
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.text == "About Yourself"
        {
            desc_textView.text = "";
            desc_textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if textView.text == ""
        {
            desc_textView.text = "About Yourself";
            desc_textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if (textField == age_TF || textField == gender_TF)
        {
            setPickerToolBar()
        }
        
        else if textField == location_TF
        {
            pickPlace()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if (textField == age_TF)
        {
            textField.inputView = datePicker;
            textField.inputAccessoryView = toolbar;
        }
            
        else if (textField == gender_TF)
        {
            textField.inputView = genderPicker;
            textField.inputAccessoryView = toolbar;
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
        if age_TF.isFirstResponder()
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
            
            age_TF.text = "\(years) Years"
            user_age = years;
            age_TF.resignFirstResponder()
        }
            
        else if gender_TF.isFirstResponder()
        {
            gender_TF.text = genderArray[(genderPicker.selectedRowInComponent(0))];
            gender_TF.resignFirstResponder()
        }
    }
    
    func cancelPressed()
    {
        if age_TF.isFirstResponder()
        {
            age_TF.resignFirstResponder()
        }
        else if gender_TF.isFirstResponder()
        {
            gender_TF.resignFirstResponder()
        }
    }
    
    
    //MARK: Action Methods
    
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
    
    @IBAction func back(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func update(sender: UIButton)
    {
        if age_TF.text != "" && gender_TF.text != "" && name_TF.text != "" && desc_textView.text != ""
        {
            if hasInternet
            {
                self.view.userInteractionEnabled = false
                activityIndicator.startAnimating()
                
                let age = String(format: "%d", user_age)
                
                let dict = ["name":name_TF.text!, "age":age, "gender":gender_TF.text!, "aboutMe":desc_textView.text!]
                User.updateProfileServiceWithBlock(dict, api_key: api_key,image: image, response: { (success, message, error) in
                    
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
                    else
                    {
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        let alertController : UIAlertController = UIAlertController(title: "Well Done!", message: "Profile Updated Successfully." , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
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
            
        else
        {
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "No Field should be empty." , preferredStyle: UIAlertControllerStyle.Alert)
            
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
                        self.location_TF.text = p
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
}
