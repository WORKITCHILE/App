//
//  AppDelegate.swift
//  Work It
//
//  Created by qw on 02/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import FirebaseUI
import IQKeyboardManagerSwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications
import AVFoundation
import GooglePlaces
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import CoreLocation


var storageRef: StorageReference!
var ref: DatabaseReference!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let storyboard  = UIStoryboard(name: "Main", bundle: nil)
    var initialViewController = UIViewController()
    lazy var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        configureFirebase(application: application)
        setInitialController()
        handleUserLocation()
        initializeGoogleMap()
        return true
    }
    
    func handleUserLocation(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            self.createSettingsAlertController(title: "Enable Location", message: "This app requires to get current location of user for getting the nearest job.")
            break
        case .restricted:
            // Nothing you can do, app cannot use location services
            break
        default:
            break
        }
    }
    
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel){ (UIAlertAction) in
            exit(0)
        }
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    //    }
    
    func initializeGoogleMap(){
        GMSPlacesClient.provideAPIKey("AIzaSyAoQQfWXcKbUxORBjLW9-ajrF4I5cGTApo")
        GMSServices.provideAPIKey("AIzaSyAoQQfWXcKbUxORBjLW9-ajrF4I5cGTApo")
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }
    
    func setInitialController(){
        
        let initial_controller: UIViewController
        Singleton.shared.userInfo = Singleton.getUserInfo()
      
        if UserDefaults.standard.value(forKey: UD_TOKEN) as? String != nil && Singleton.shared.userInfo.status == "ACTIVE" {
            
            K_CURRENT_USER = UserDefaults.standard.value(forKey: UD_CURRENT_USER) as? String
            initial_controller = storyboard.instantiateViewController(withIdentifier: "main")
        

        }else {
            
            let signup_storyboard  = UIStoryboard(name: "signup", bundle: nil)
            initial_controller = signup_storyboard.instantiateViewController(withIdentifier:"WelcomeViewController")
        }
        //}
        
        self.window?.rootViewController = initial_controller
  
    }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func configureFirebase(application: UIApplication){
        FirebaseApp.configure()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        Auth.auth().addStateDidChangeListener { (auth, user) in
            user?.getIDToken(completion: { (token, error) in
                user?.getIDTokenForcingRefresh(true, completion: { (toke, erro) in
                    if let tok = token{
                        UserDefaults.standard.setValue(token, forKey: UD_TOKEN)
                    }
                })
            })
        }
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in
            
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    //This function work when we tap on nitification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo is [String:Any] {
            self.handleUserNotfication(info: userInfo)
           
        }
    }
    
    func handleUserNotfication(info:[AnyHashable:Any]){
        if (UserDefaults.standard.value(forKey: UD_TOKEN) as? String) != nil {
            if let data = info as? [String:Any] {
                let navigationController = self.window?.rootViewController as! UINavigationController
                switch (data["gcm.notification.type"] as! String) {
                // New Job Request
                case "1":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                    (initialViewController as! ViewJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                    
                // Bid Received for your posted job
                case "2":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
                    Singleton.shared.jobData = []
                    (initialViewController as! JobDetailViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                //Bid accepted by owner for worker bid
                case "3":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                    Singleton.shared.vendorAcceptedBids = []
                    
                    (initialViewController as! StartJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                //Bid rejected by owner for worker bid
                case "4":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                    Singleton.shared.vendorRejectedBids = []
                    (initialViewController as! ViewJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                // Job Started by worker
                case "5":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.runningJobData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.viewControllers.removeAll(where: { (vc) -> Bool in
                               if vc.isKind(of: AcceptJobViewController.self)  {
                                   return true
                               }else {
                                   return false
                               }
                    })
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                // Job finished by worker
                case "6":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.runningJobData = []
                    Singleton.shared.postedHistoryData = []
                    Singleton.shared.receivedHistoryData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                //Job Payment Release
                case "7":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.runningJobData = []
                    Singleton.shared.postedHistoryData = []
                    Singleton.shared.receivedHistoryData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "8":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.runningJobData = []
                    Singleton.shared.postedHistoryData = []
                    Singleton.shared.receivedHistoryData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "10":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.runningJobData = []
                    Singleton.shared.postedHistoryData = []
                    Singleton.shared.receivedHistoryData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "11":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                    (initialViewController as! ViewJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "12":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                    (initialViewController as! ViewJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "13":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
                    Singleton.shared.jobData = []
                    (initialViewController as! JobDetailViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "14":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    Singleton.shared.jobData = []
                    (initialViewController as! AcceptJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    (initialViewController as! AcceptJobViewController).isVendorCancelJob = true
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "15":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "EvaluationViewController") as! EvaluationViewController
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                case "16":
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                    Singleton.shared.vendorRejectedBids = []
                    Singleton.shared.vendorAcceptedBids = []
                    (initialViewController as! StartJobViewController).jobId = (data["gcm.notification.data"] as? String) ?? ""
                    navigationController.viewControllers.removeAll(where: { (vc) -> Bool in
                               if vc.isKind(of: StartJobViewController.self)  {
                                   return true
                               }else {
                                   return false
                               }
                    })
                    navigationController.pushViewController(initialViewController, animated: true)
                    break
                default:
                    break
                }
                
            }
            //        NotificationCenter.default.post(name: NSNotification.Name(N_NOTIFICATION_DATA),object: nil,userInfo: ["info": info])
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcm token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: UD_FCM_TOKEN)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print("foreground remote notification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let data = userInfo as? [String:Any] {
            if ((data["gcm.notification.type"] as! String) == "7") {
                self.handleUserNotfication(info: userInfo)
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
            }
        }
    }
}


