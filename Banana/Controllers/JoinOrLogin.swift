//
//  JoinOrLogin.swift
//  Banana
//
//  Created by musharraf on 4/13/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Fabric
import TwitterKit

let hasInternet = Reachability.isConnectedToNetwork()
let loggedOut = "loggedOut"
var activityIndicator = UIActivityIndicatorView()

class JoinOrLogin: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate
{

    @IBOutlet weak var email_TF: UITextField!
    @IBOutlet weak var password_TF: UITextField!
    @IBOutlet weak var forgotPassLabel: UILabel!
    
    var loginManager = FBSDKLoginManager()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.forgotPassChecked(_:)))
        tapGesture.numberOfTapsRequired = 1
        forgotPassLabel!.userInteractionEnabled =  true
        forgotPassLabel!.addGestureRecognizer(tapGesture)
        
        
        // add activity indicator
        // and handle where needed
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.logOut), name: loggedOut, object: nil)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    func logOut() -> Void
    {
        if (self.presentedViewController != nil)
        {
            self.dismissViewControllerAnimated(true, completion: {
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.email_TF.text = ""
                self.password_TF.text = ""
                
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")
        {
            if user_id as! String != ""
            {
                // go to tabbar
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBar") as! MainTabBar
                self.presentViewController(vc, animated: true, completion: {
                    
                    print("tabbar presented.")
                    
                })
            }
        }
    }

    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if email_TF.isFirstResponder()
        {
            password_TF.becomeFirstResponder()
        }
        else
        {
            password_TF.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func fbPressed(sender: UIButton)
    {
        self.email_TF.text = ""
        self.password_TF.text = ""
        
        loginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            
            if error != nil
            {
                print("error occured with login \(error.localizedDescription)")
            }
                
            else if result.isCancelled
            {
                print("login canceled")
            }
            
            else
            {
                if FBSDKAccessToken.currentAccessToken() != nil
                {
                    FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, userResult, error) in
                        
                        if error != nil
                        {
                            print("error occured \(error.localizedDescription)")
                        }
                        else if userResult != nil
                        {
                            print("Login with FB is success")
                            print(userResult)
                            
                            self.view.userInteractionEnabled = false
                            activityIndicator.startAnimating()
                            
                            let img_URL: String = (userResult.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                            
                            let email = (userResult.objectForKey("email") as? String)!
                            let password = "1234567890" //(userResult.objectForKey("id") as? String)!
                            let name = (userResult.objectForKey("name") as? String)!
                            
                            // now run the login service and check if this user exist in DB?
                            // if yes, login the user
                            // otherwise, navigate to second step vc
                            
                            if Utility.isValidEmail(email)
                            {
                                if hasInternet
                                {
                                    var device_token = ""
                                    if let token = NSUserDefaults.standardUserDefaults().valueForKey("tokenString")
                                    {
                                       device_token = token as! String
                                    }
                                    
                                    
                                    let dict = ["email":email, "password":password, "pushId": device_token, "pushType":"ios"]
                                    
                                    User.userLoginServiceWithBlock(dict, response: { (user, userExists, message, error) in
                                        
                                        if error != nil
                                        {
                                            self.view.userInteractionEnabled = true
                                            activityIndicator.stopAnimating()
                                            
                                            let alertController : UIAlertController = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                                            
                                            //Create and add the Cancel action
                                            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                                                //Do some stuff
                                            }
                                            alertController.addAction(cancelAction)
                                            
                                            self.presentViewController(alertController, animated: true, completion: nil)
                                        }
                                        
                                        else if userExists
                                        {
                                            if user != nil
                                            {
                                                // login successfull
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
                                                    
                                                })
                                                
                                            }
                                                
                                            else
                                            {
                                                // login failed
                                                // do nothing except activity indicator stopping
                                                
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
                                        }
                                            
                                        else
                                        {
                                            // go to second step for registration
                                            
                                            self.view.userInteractionEnabled = true
                                            activityIndicator.stopAnimating()
                                            
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewControllerWithIdentifier("SignUpSecStep") as! SignUpSecStep
                                            
                                            vc.email = email
                                            vc.password = password
                                            vc.name_str = name
                                            vc.imgURL_str = img_URL
                                            
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                        
                                    })
                                }
                                    
                                    //no internet
                                else
                                {
                                    self.view.userInteractionEnabled = true
                                    activityIndicator.stopAnimating()
                                    let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Check Internet connection" , preferredStyle: UIAlertControllerStyle.Alert)
                                    
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
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Not a valid email" , preferredStyle: UIAlertControllerStyle.Alert)
                                
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
                
            }
            
        }
    }
    
    @IBAction func twitterPressed(sender: UIButton)
    {
        print("Twitter pressed")
        
        if(!hasInternet){
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Check Internet connection" , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)

            return
        }
        
        
        
        Twitter.sharedInstance().startWithConsumerKey("Nx0RfawYvTfTxTHYG9KnuKxAc", consumerSecret: "ZQ6ZFBi7wy5Ms4SuT30Fzn9mH7v0HyyoZR0HwjnkROXISvigPB")
        
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                
                self.view.userInteractionEnabled = false
                activityIndicator.startAnimating()
                
                let client = TWTRAPIClient.clientWithCurrentUser()
                let request = client.URLRequestWithMethod("GET",
                    URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                    parameters: ["include_email": "true", "skip_status": "true"],
                    error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                    
                    if connectionError != nil {
                        print("Error: \(connectionError)")
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                        let alertController : UIAlertController = UIAlertController(title: "Error", message: "Unable to connect to twitter" , preferredStyle: UIAlertControllerStyle.Alert)
                        
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                            //Do some stuff
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)

                        
                    }else{
                        do {
                            let twitterJson = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                            print("json: \(twitterJson)")
                            self.loginWithTwitter(twitterJson)
                            
                        } catch let jsonError as NSError {
                            print("json error: \(jsonError.localizedDescription)")

                            self.view.userInteractionEnabled = true
                            activityIndicator.stopAnimating()
                            
                            let alertController : UIAlertController = UIAlertController(title: "Error", message: "Error parsing json response from twitter" , preferredStyle: UIAlertControllerStyle.Alert)
                            
                            //Create and add the Cancel action
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                                //Do some stuff
                            }
                            alertController.addAction(cancelAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)

                        }
                    }
                    
                }
                
            } else {
                print("error: \(error!.localizedDescription)");
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                let alertController : UIAlertController = UIAlertController(title: "Error", message: "Unable to open twitter session" , preferredStyle: UIAlertControllerStyle.Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func joinORLoginPressed(sender: UIButton)
    {
        if !(email_TF.text!.isEmpty) && !(password_TF.text!.isEmpty)
        {
            if Utility.isValidEmail(email_TF.text!)
            {
                if password_TF.text?.characters.count >= 8
                {
                    if hasInternet
                    {
                        self.view.userInteractionEnabled = false
                        activityIndicator.startAnimating()
                        
                        var device_token = ""
                        if let token = NSUserDefaults.standardUserDefaults().valueForKey("tokenString")
                        {
                            device_token = token as! String
                        }
                        
                        let dict = ["email":email_TF.text!, "password":password_TF.text!, "pushId": device_token, "pushType":"ios"]
                        
                        User.userLoginServiceWithBlock(dict, response: { (user, userExists, message, error) in
                            
                            if error != nil
                            {
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let alertController : UIAlertController = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                                
                                //Create and add the Cancel action
                                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                                    //Do some stuff
                                }
                                alertController.addAction(cancelAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                                
                            else if userExists
                            {
                                if user != nil
                                {
                                    // login successfull
                                    // save user to defaults
                                    
                                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setValue(user?.user_id, forKey: "user_id")
                                    defaults.setValue(user?.api_key, forKey: "api_key")
                                    defaults.synchronize()
                                    
                                    // go to tabbar
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBar") as! MainTabBar
                                    self.presentViewController(vc, animated: true, completion: {
                                        
                                        self.view.userInteractionEnabled = true
                                        activityIndicator.stopAnimating()
                                        
                                    })
                                    
                                }
                                    
                                else
                                {
                                    // login failed
                                    // do nothing except activity indicator stopping
                                    
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
                            }
                                
                            else
                            {
                                // go to second step for registration
                                
                                self.view.userInteractionEnabled = true
                                activityIndicator.stopAnimating()
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("SignUpSecStep") as! SignUpSecStep
                                
                                
                                vc.email = self.email_TF.text!
                                vc.password = self.password_TF.text!
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        })
                    }
                        
                        //no internet
                    else
                    {
                        let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Check Internet connection" , preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                    let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Password should be at-least 8 characters long." , preferredStyle: UIAlertControllerStyle.Alert)
                    
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
                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Not a valid email" , preferredStyle: UIAlertControllerStyle.Alert)
                
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
    func forgotPassChecked(recognizer: UITapGestureRecognizer) {
        showPasswordInputDialog()
    }
    func showPasswordInputDialog() {
        //print("Show Dialogue")
        let alert = UIAlertController(title: "Reset Your Password", message: "Please enter the email address you signed up with, we will send a reset password link to that email.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            let valid: Int = self.validateResetEmail(textField)
            if(valid == 0 || valid == 2){  //empty email or invalid email
                var message: String = "Please fill email field."
                
                if(valid == 2){
                    message = "Please enter valid email address."
                }
                let alertController : UIAlertController = UIAlertController(title: "Attention!", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)

                
            }else{//Valid email
                self.doResetPass(textField.text!)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(false, completion: nil)
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter Your Email"
            textField.keyboardType = .EmailAddress
            textField.text = self.email_TF?.text!
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func validateResetEmail(textField: UITextField)-> Int{
        var valid: Int = 0
        if(textField.text?.characters.count > 0){
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if(emailTest.evaluateWithObject(textField.text)){
                valid = 1
            }else{
                valid = 2
            }
        }
        return valid
    }
    func doResetPass(email: String){
        self.view.userInteractionEnabled = false
        activityIndicator.startAnimating()
        
        if Reachability.isConnectedToNetwork(){
            let dict = ["email":email]
            User.resetPasswordServiceWithBlock(dict, response: { (success, message, error) in
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                var title: String = "Attention!"
                var alertMessage: String = message
                if let error = error
                {
                    title = "Error!"
                    alertMessage = error.localizedDescription
                    
                }
                
                let alertController : UIAlertController = UIAlertController(title: title, message: alertMessage , preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in}
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            })

        }else{
            self.view.userInteractionEnabled = true
            activityIndicator.stopAnimating()
            let alertController : UIAlertController = UIAlertController(title: "Attention!", message: "Check Internet connection please." , preferredStyle: UIAlertControllerStyle.Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        
    }
    func loginWithTwitter(twitterJson: AnyObject){
        let displayName = twitterJson.objectForKey("name") as! String
        let profileImageUrl = twitterJson.objectForKey("profile_image_url") as! String
        let userEmail = twitterJson.objectForKey("email") as! String
        //let userEmail: String = "ahmad1234@mail.com"
        let userPassword: String = userEmail
        
        if(userEmail.isEmpty){
            self.view.userInteractionEnabled = true
            activityIndicator.stopAnimating()
            
            let alertController : UIAlertController = UIAlertController(title: "Error", message: "Invalid email from twitter" , preferredStyle: UIAlertControllerStyle.Alert)
            
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
        
        var device_token = ""
        if let token = NSUserDefaults.standardUserDefaults().valueForKey("tokenString")
        {
            device_token = token as! String
        }
        
        let dict = ["email":userEmail, "password":userPassword, "pushId": device_token, "pushType":"ios"]
        
        User.userLoginServiceWithBlock(dict, response: { (user, userExists, message, error) in
            
            if error != nil
            {
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                let alertController : UIAlertController = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
                
            else if userExists
            {
                if user != nil
                {
                    // login successfull
                    // save user to defaults
                    
                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue(user?.user_id, forKey: "user_id")
                    defaults.setValue(user?.api_key, forKey: "api_key")
                    defaults.synchronize()
                    
                    // go to tabbar
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBar") as! MainTabBar
                    self.presentViewController(vc, animated: true, completion: {
                        
                        self.view.userInteractionEnabled = true
                        activityIndicator.stopAnimating()
                        
                    })
                    
                }
                    
                else
                {
                    // login failed
                    // do nothing except activity indicator stopping
                    
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
            }
                
            else
            {
                // go to second step for registration
                
                self.view.userInteractionEnabled = true
                activityIndicator.stopAnimating()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("SignUpSecStep") as! SignUpSecStep
                
                
                vc.email = userEmail
                vc.password = userPassword
                vc.name_str = displayName
                vc.imgURL_str = profileImageUrl

                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        })

    }
}
