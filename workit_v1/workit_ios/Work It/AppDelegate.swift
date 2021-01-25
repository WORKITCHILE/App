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
import FBSDKShareKit

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
        
        
        //FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        return true
    }
    
    func handleUserLocation(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            self.createSettingsAlertController(title: "Activa el GPS", message: "Esta aplicación require obtener la ubicación del usuario para obtener el trabajo más cercano. ")
            break
        case .restricted:
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
    
    
    func initializeGoogleMap(){
        let key = "AIzaSyAFNJwycb9jul04lJHbJyXV7prNO3utPDU" // AIzaSyAoQQfWXcKbUxORBjLW9-ajrF4I5cGTApo
        GMSPlacesClient.provideAPIKey(key)
        GMSServices.provideAPIKey(key)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }
    
    func setInitialController(){
        
        let initial_controller: UIViewController
        Singleton.shared.userInfo = Singleton.getUserInfo()
      
        if UserDefaults.standard.value(forKey: UD_TOKEN) as? String != nil && Singleton.shared.userInfo.status == "ACTIVE" {
            
            K_CURRENT_USER = UserDefaults.standard.value(forKey: UD_CURRENT_USER) as? String
            initial_controller = storyboard.instantiateViewController(withIdentifier: "main")
        

        } else {
            
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
                    if token != nil{
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
    
    func retrieveJoFromId(_ jobId : String, _ mode : String, _ bid: BidResponse?){
        ActivityIndicator.show(view: (self.window?.rootViewController?.view)!)
        
        let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(jobId)"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) {
            
            ActivityIndicator.hide()
            
            
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            let nav = storyboard.instantiateViewController(withIdentifier: "BidDetailContainer") as! UINavigationController
            let myVC = nav.viewControllers[0] as! BidDetailViewController
            myVC.fromNotification = true
            nav.modalPresentationStyle = .fullScreen
            
            myVC.jobData = $0?.data
            if(bid != nil){
                myVC.bidData = bid
            }
            myVC.mode = mode
            
            self.window?.rootViewController?.present(nav, animated: true, completion: nil)
            
         
            
        }
    }
    
    func retrieveBidFromId(_ bidId : String, _ jobId: String){
        ActivityIndicator.show(view: (self.window?.rootViewController?.view)!)
        
        let url = "\(U_BASE)\(U_GET_SINGLE_BID_WORKER)\(bidId)"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleBid.self, requestCode: U_GET_SINGLE_BID_WORKER) { [self] repsonse in
            
            ActivityIndicator.hide()
            if(repsonse != nil){
                retrieveJoFromId(jobId, "HIRE", repsonse!.data)
            }
          
            
        }
    }
    
    func handleUserNotfication(info:[AnyHashable:Any]){
       
     
        if (UserDefaults.standard.value(forKey: UD_TOKEN) as? String) != nil {
            if let data = info as? [String:Any] {
                
             
                   let jobId = data["job_id"] as? String
                   let bidId = data["bid_id"] as? String

                   let userId = Singleton.shared.userInfo.user_id
                   let senderId = data["sender_id"] as? String
                   let notificationType = data["gcm.notification.type"] as! String
               
                   if(notificationType == "17"){
                    self.showJobDetail(jobId: jobId!)
                   } else if(notificationType == "9"){
                       
                       let nav = storyboard.instantiateViewController(withIdentifier: "InboxContainer") as! UINavigationController
                       let myVC = nav.viewControllers[0] as! InboxViewController
                       myVC.fromNotification = true
                        myVC.jobIdFromNotification = jobId!
                       nav.modalPresentationStyle = .fullScreen
                       self.window?.rootViewController?.present(nav, animated: true, completion: nil)
                       
                   } else if(notificationType == "15"){
                       let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                  
                       let nav = storyboard.instantiateViewController(withIdentifier: "EvaluationViewContainer") as! UINavigationController
                       let myVC = nav.viewControllers[0] as! EvaluationViewController
                       myVC.fromNotification = true
                       nav.modalPresentationStyle = .fullScreen
                       self.window?.rootViewController?.present(nav, animated: true, completion: nil)
                   } else if(notificationType == "2"){
                      
                    self.retrieveBidFromId(bidId!, jobId!)
                       
                   } else if(notificationType == "4"){
                    self.showJobDetail(jobId: jobId!)
                   } else if(notificationType == "14"){
                    self.retrieveJoFromId(jobId! , "HIRE", nil)
                   } else {
                    self.retrieveJoFromId(jobId! , (userId == senderId) ? "HIRE" : "WORK", nil)
                   }
 
              
                
            }
        }
        
    }
    
    
    func showJobDetail(jobId : String){
        let storyboard  = UIStoryboard(name: "Home", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "JobDetailContainer") as! UINavigationController
        let myVC = nav.viewControllers[0] as! JobDetailViewController
        myVC.jobId = jobId
        myVC.modeView = 1
        myVC.fromNotification = true
        nav.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(nav, animated: true, completion: nil)
    }
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.standard.set(fcmToken, forKey: UD_FCM_TOKEN)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

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


