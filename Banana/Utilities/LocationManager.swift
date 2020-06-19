//
//  LocationManager.swift
//  Eet
//
//  Created by Yasir Ali on 10/23/15.
//  Copyright © 2015 MenuSpring. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

class LocationManager : NSObject, CLLocationManagerDelegate
{
    private var lastLocation : CLLocation?
    private let lmanager = CLLocationManager()
    
    var location : String = ""
    var accessGranted = false

    
    static let sharedInstance = LocationManager()
    
    override private init()
    {
        super.init()
        
        if self.lmanager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization))
        {
            self.lmanager.requestWhenInUseAuthorization()
        }
        self.lmanager.startUpdatingLocation()
        self.lmanager.desiredAccuracy = kCLLocationAccuracyBest
        self.lmanager.delegate = self
    }
    
    var userLocation : CLLocation?   {
        return lastLocation
    }
    
    
    private func startLocationManager(timer: NSTimer)
    {
        self.lmanager.startUpdatingLocation()
        timer.invalidate()
    }
    
    func locationManager(lmanager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation = locations.last! as CLLocation
        
        //if lastLocation == nil || lastLocation! != currentLocation
        if lastLocation == nil || lastLocation != currentLocation
        {
            lastLocation = currentLocation
            reversGeoCode()
            accessGranted = true
        }

    }
    
    func reversGeoCode()
    {
         CLGeocoder().reverseGeocodeLocation(lastLocation!, completionHandler: {(placemarks, error) -> Void in
            
            print(self.lastLocation)
            
            if error != nil
            {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0
            {
                let pm = placemarks![0] as CLPlacemark
                print(pm.locality)
                print(pm.administrativeArea)
                print(pm.country)
                print(self.lastLocation?.coordinate.latitude)
                print(self.lastLocation?.coordinate.longitude)
 
                if((pm.locality == nil)) {
                    self.location = String(format: "%@, %@", pm.administrativeArea!, pm.country!)
                }else {
                    self.location = String(format: "%@, %@, %@", pm.locality!, pm.administrativeArea!, pm.country!)
                }

                
                let defaults = NSUserDefaults.standardUserDefaults()
                //defaults.setValue(String(format: "%@", (self.lastLocation?.coordinate.latitude)! ), forKey: "lat")
                //defaults.setValue(String(format: "%@", (self.lastLocation?.coordinate.longitude)! ), forKey: "long")

                defaults.setValue(self.location , forKey: "location")
                defaults.synchronize()
                
            }
            else
            {
                print("Problem with the data received from geocoder.")
            }
        })
    }
    
    
    func locationManager(lmanager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        accessGranted = false
        switch (status)
        {
        case .Restricted:
            print("Restricted Access to location.")
            break
        case .Denied:
            print("User denied access to location.")
            break
        case .NotDetermined:
            print("Status not determined.")
            break
        case .AuthorizedWhenInUse:
            print("Allowed to location Access when InUse.")
            accessGranted = true
            break
        case .AuthorizedAlways:
            print("Allowed to location Access for always.")
            accessGranted = true
            break
        default:
            print("LocationManager default msg.")
            accessGranted = true
        }
        
        if accessGranted == true
        {
            self.lmanager.delegate = self
            self.lmanager.startUpdatingLocation()
        }
    }
    
    func  showLocationError()
    {
        
//         if let topController = UIApplication.topViewController()
//         {
//            AlertController.showConfirm("Restricted Access to location", message: "In order to work, app needs your location.", noButtonTitle: "Cancel", yesButtonTitle: "OK", noActionHander: nil, yesActionHander: {
//                self.openAppSettings()
//         }, presenterController: topController)
//         }
        
    }
    func openAppSettings()
    {
        let settingUrl :  NSURL = NSURL.init(string:UIApplicationOpenSettingsURLString)!
        let application : UIApplication  = UIApplication.sharedApplication()
        if(application.canOpenURL(settingUrl))
        {
            application.openURL(settingUrl)
        }
    }
    
    static func startMonitoring()
    {
        self.sharedInstance.lmanager.startUpdatingLocation()
    }
    
    static func stopMonitoring()
    {
        self.sharedInstance.lmanager.stopUpdatingLocation()
    }
    
}
