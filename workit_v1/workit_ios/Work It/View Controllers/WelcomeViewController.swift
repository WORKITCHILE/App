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
    @IBOutlet weak var buttonLogin: UIButton!
    
    var googleData = GIDGoogleUser()
    var fbData = [String:Any]()
    var loginFrom = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.emailField.placeholderTextColor = .black
        
        self.buttonLogin.alpha = 0.5
        self.buttonLogin.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
         
    }
    
    func callSocialLoginAPI(type: Int, gId: String?,fId: String?, email: String){
        
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_SOCIAL_LOGIN)\(type)&social_handle=\((type == 1 ? gId : fId) ?? "")"
       
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: SocialLogin.self, requestCode: U_SOCIAL_LOGIN) { response in
            
            if(response?.data?.user_id == nil){
                
                
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
                } else if(type == 2){
                    let picture: [String: Any] = self.fbData["picture"] as! [String : Any]
                   
                    let pictureData : [String: Any] = picture["data"] as! [String : Any]
                    myVC.socialPicture = pictureData["url"]! as! String
                         
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
            
            guard AccessToken.current != nil else {
                return
            }
            
            self.getFBUserData()
        }
    }
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let data = result as? [String:Any]{
                        self.fbData = data
                        self.callSocialLoginAPI(type: 2, gId: nil, fId: (data["id"] as! String), email: data["email"] as! String)
                    }
                }
            })
        }
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
    
    @IBAction private func nameChanged(_ sender: UITextField) {
        
        let isEmail = sender.text!.isValidEmail()
        self.buttonLogin.alpha = isEmail ? 1.0 : 0.5
        self.buttonLogin.isEnabled = isEmail
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signin" {
            let loginVC = segue.destination as! LoginViewController
            loginVC.email = self.emailField.text ?? ""
        }
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

