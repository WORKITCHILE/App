//
//  LoginViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class LoginViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var emailAddress: UILabel!
    
    @IBOutlet weak var password: DesignableUITextField!
    
    var email = String()
    let authUI = FUIAuth.defaultAuthUI()
    var isNewUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddress.text = self.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func sendFcmToken(userId: String){
        DispatchQueue.global(qos: .background).async {
            let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
            let param : [String: String] = [
                "user_id": userId,
                "fcm_token": fcmToken! as String
            ]
            
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_ADD_FCM_TOKEN, method: .post, parameter: param, objectClass: Response.self, requestCode: U_ADD_FCM_TOKEN) { (response) in
                
            }
        }
    }
    
    func getProfileData(id: String){
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + id, method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
                Singleton.shared.userInfo = response.data!
                Singleton.saveUserInfo(data:Singleton.shared.userInfo)
                if(Singleton.shared.userInfo.is_email_verified != 1){
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                    myVC.isNewuser = true
                    self.navigationController?.pushViewController(myVC, animated: true)
                }else {
                    
                    Singleton.shared.showToast(text: "Successfully Logged In")
                    let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "main")
                    self.view.window?.rootViewController = myVC
                    
                    
                }
                
                ActivityIndicator.hide()
            }
    }

    
    @IBAction func loginAction(_ sender: Any) {
        self.password.resignFirstResponder()
        
        K_CURRENT_USER = K_POST_JOB
        
        if(self.password.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter your password")
        }else {
            
            
            ActivityIndicator.show(view: self.view)
            Auth.auth().signIn(withEmail: self.emailAddress.text ?? "", password: self.password.text ?? "") { [weak self] authResult, error in
                
                debugPrint(error as Any)
                
                guard self != nil else { return }
                if(authResult == nil){
                    Singleton.shared.showToast(text: "Wrong credentials")
                    ActivityIndicator.hide()
                }else {
                    self?.sendFcmToken(userId: authResult?.user.uid ?? "")
                    
                    Singleton.shared.userInfo.name = authResult?.user.displayName
                    Singleton.shared.userInfo.token = authResult?.user.refreshToken
                    Singleton.shared.userInfo.user_id = authResult?.user.uid ?? ""
                    Singleton.shared.userInfo.email = authResult?.user.email
//                    if(self!.isNewUser){
//                     Singleton.shared.userInfo.is_email_verified = 0
//                    }else{
//                        Singleton.shared.userInfo.is_email_verified = 1
//                    }
                    Singleton.shared.userInfo.profile_picture = authResult?.user.photoURL?.absoluteString
                    UserDefaults.standard.set(authResult?.user.uid ?? "", forKey: UD_USER_ID)
                    Singleton.shared.userInfo.contact_number = authResult?.user.phoneNumber
                    authResult?.user.getIDToken(completion: { (token, error) in
                        if(error == nil){
                            UserDefaults.standard.setValue(token ?? "", forKey: UD_TOKEN)
                        }
                    })
                    ActivityIndicator.hide()
                    self?.getProfileData(id:  authResult?.user.uid ?? "")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! ForgotPasswordViewController
        myVC.emailAdd = self.email
    }
    
   
}
