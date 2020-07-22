//
//  WelcomeViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    //MARK: IBOUtlets
    @IBOutlet weak var emailField: DesignableUITextField!
    
    var googleData = GIDGoogleUser()
    var fbData = [String:Any]()
    var loginFrom = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //self.logOut()
        self.emailField.placeholderTextColor = .black
        
    }
    
    func callSocialLoginAPI(type: Int,gId: String?,fId: String?, email: String){
        ActivityIndicator.show(view: self.view)
        var url = String()
        if(type == 1){
            url = U_BASE + U_SOCIAL_LOGIN + "\(type)&social_handle=" + (gId ?? "")
        }else if(type == 2){
            url = U_BASE + U_SOCIAL_LOGIN + "\(type)&social_handle=" + (fId ?? "")
        }
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: SocialLogin.self, requestCode: U_SOCIAL_LOGIN) { (response) in
            if(response.data?.user_id == nil){
                self.openSuccessPopup(img: #imageLiteral(resourceName: "information-button copy"), msg: "New user, please create account on workit and continue", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                myVC.googleId = gId ?? ""
                myVC.facebookId = fId ?? ""
                myVC.userEmail = email
                if(type == 1){
                    var components = self.googleData.profile.name.components(separatedBy: " ")
                    if(components.count > 0){
                        let firstName = components.removeFirst()
                        let lastName = components.joined(separator: " ")
                        myVC.fName = firstName
                        myVC.lName = lastName
                    }
                }else if(type == 2){
                    myVC.fName = self.fbData["first_name"] as? String ?? ""
                    myVC.lName = self.fbData["last_name"] as? String ?? ""
                }
                self.navigationController?.pushViewController(myVC, animated: true)
            }else{
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                myVC.email = email
                self.navigationController?.pushViewController(myVC, animated: true)
            }
        }
    }
    
    
    func getFacebookUserInfo(){
        let loginManager = LoginManager()
        LoginManager().loginBehavior = .browser
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            self.getFBUserData()
        }
    }
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    if let data = result as? [String:Any]{
                        self.fbData = data
                        self.callSocialLoginAPI(type: 2, gId: nil, fId: data["id"] as! String, email: data["email"] as! String)
                    }
                }
            })
        }
    }
    
    
    //    func handleNavigation(response: SignUp) {
    //        //              let userData = try! JSONEncoder().encode(response.response)
    //        //              UserDefaults.standard.set(userData, forKey:UD_USER_DETAIl)
    //        //              Singleton.shared.userDetail = response.response
    //        //              UserDefaults.standard.set(response.response.token, forKey: UD_TOKEN)
    //        //              if (Singleton.shared.selectedLocation.id != nil){
    //        //                  if(self.popFromOrderPage){
    //        //                      let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
    //        //                      self.navigationController?.pushViewController(myVC, animated: true)
    //        //                  }else {
    //        //                      if(self.popUpView){
    //        //                       self.navigationController?.popViewController(animated: true)
    //        //                      }else {
    //        //                       NavigationController.shared.pushHome(controller: self)
    //        //                      }
    //        //                  }
    //        //              }else {
    //        //                  let myVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
    //        //                  currentPageView = K_MAP_PAGE_VIEW
    //        //                  myVC.hideCrossView = true
    //        //                  self.navigationController?.pushViewController(myVC, animated: true)
    //        //              }
    //    }
    //
    
    
    
    //MARK: IBActions
    @IBAction func loginAction(_ sender: Any) {
        if(emailField.text!.isEmpty){
            Singleton.shared.showToast(text: "Please enter Email Address")
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            myVC.email = self.emailField.text ?? ""
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        
    }
    
    @IBAction private func logOut() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    @IBAction func fbAction(_ sender: Any) {
        loginFrom = 1
        self.getFacebookUserInfo()
    }
    
    @IBAction func googleAction(_ sender: Any) {
        loginFrom = 2
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func createAccountAction(_ sender: Any){
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    
}

extension WelcomeViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            return
        }
        self.googleData = user
        self.callSocialLoginAPI(type: 1, gId: user.userID, fId:nil,email: user.profile.email)
    }
    
    func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
        //Singleton.shared.showToast(message: "erro logging in")
    }
    
    func googleSignin(_ signIn: GIDSignIn!,
                      presentViewController viewController: UIViewController!) {
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(_ signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}

