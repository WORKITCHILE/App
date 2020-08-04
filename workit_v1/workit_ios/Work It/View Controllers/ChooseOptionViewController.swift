//
//  ChooseOptionViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAuth

class ChooseOptionViewController: UIViewController {
    
    var remoteConfig: RemoteConfig!
    var responseOk =  false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "workit_color")
        
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "firebaseConfigInfo")
        self.getProfileData()
        fetchConfig()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUnauthorized), name: NSNotification.Name(N_USER_UNAUTHORIZED), object: nil)
    }
    
   @objc func userUnauthorized(){
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(N_USER_UNAUTHORIZED), object: nil)
    UserDefaults.standard.removeObject(forKey: UD_TOKEN)
    ActivityIndicator.hide()
    Singleton.shared.showToast(text: "User unauthorized. Please login again.")
    let myVC = self.storyboard?.instantiateViewController(withIdentifier:"WelcomeViewController") as! WelcomeViewController
    self.navigationController?.pushViewController(myVC, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUnauthorized), name: NSNotification.Name(N_USER_UNAUTHORIZED), object: nil)
    }
    
    func getProfileData(){
        if let id = UserDefaults.standard.value(forKey: UD_USER_ID) as? String{
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
                Singleton.shared.userInfo = response.data!
                Singleton.saveUserInfo(data:Singleton.shared.userInfo)
                
                self.responseOk = true
                ActivityIndicator.hide()
            }
        }else{
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            self.navigationController?.pushViewController(myVC, animated: false)
        }
              
    }
    
    func selectUserRole(type: String){
        ActivityIndicator.show(view: self.view)
        self.view.isUserInteractionEnabled = true
        let param: [String : Any] = [
            "type": type,
            "uid": Singleton.shared.userInfo.user_id!
        ]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_CHANGE_USER_ROLE, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CHANGE_USER_ROLE) { (response) in
            K_CURRENT_USER = type
            UserDefaults.standard.set(type, forKey: UD_CURRENT_USER)
            if(type == K_POST_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "main")
                self.view.window?.rootViewController = myVC
            }else if(type == K_WANT_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            ActivityIndicator.hide()
        }
    }
    
    func fetchConfig() {
     //        if(remoteConfig["update_soft_ios"].stringValue == "false"){
     //            self.showPopup(title: "Update", msg: "New Version is available on App Store",action:2)
     //        }
             var expirationDuration = 3600
             if remoteConfig.configSettings.isDeveloperModeEnabled {
                 expirationDuration = 0
             }
             
             remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
                 if status == .success {
                     self.remoteConfig.activateFetched()
                 } else {
                     print("Config not fetched")
                     print("Error \(error!.localizedDescription)")
                 }
                 self.display()
             }
         }
    
    func display() {
            let softUpdate =  "update_soft_ios"
            let updateRequired = "force_update_required_ios"
            let currentVersion = "force_update_current_version_ios"
            _ = "force_update_store_url_ios"
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            if(remoteConfig[updateRequired].stringValue == "true"){
               if(remoteConfig[currentVersion].stringValue == appVersion){
                   return
               }else{
                   if(remoteConfig[softUpdate].stringValue == "false"){
                       self.showPopup(title: "Update", msg: "New Version is available on App Store",action:2)
                   }else{
                       self.showPopup(title: "Update", msg:  "New Version is available on App Store",action: 1)
                   }
               }
            }else {
               return
            }
       }
       
       func showPopup(title: String, msg: String,action:Int?) {
           let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
           let yesBtn = UIAlertAction(title:"Update", style: .default) { (UIAlertAction) in
               self.yesButtonAction()
           }
           let noBtn = UIAlertAction(title: "Cancel", style: .default){
               (UIAlertAction) in
               if(action != 1){
                   self.forceUpdate()
               }
           }
           
           alert.addAction(yesBtn)
           alert.addAction(noBtn)
           
           present(alert, animated: true, completion: nil)
       }
       
       func yesButtonAction(){
           let string = remoteConfig["force_update_store_url_ios"].stringValue!
           let url  = NSURL(string: string)//itms   https
           if UIApplication.shared.canOpenURL(url! as URL) {
               UIApplication.shared.openURL(url! as URL)
           }
       }
       
       func forceUpdate() {
           exit(0);
       }
    
    
    @IBAction func hireAction(_ sender: Any) {
        if(responseOk){
         self.selectUserRole(type: K_POST_JOB)
        }
    }
    
    @IBAction func workAction(_ sender: Any) {
        if(responseOk){
         self.selectUserRole(type: K_WANT_JOB)
        }
    }

}
