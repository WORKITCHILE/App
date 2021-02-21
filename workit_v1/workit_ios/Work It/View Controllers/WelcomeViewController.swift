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
import AuthenticationServices
import CryptoKit
import UIKit
import FirebaseAuth




class WelcomeViewController: UIViewController {
    
    //MARK: IBOUtlets
    @IBOutlet weak var emailField: DesignableUITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var top1 : NSLayoutConstraint!
    @IBOutlet weak var top2 : NSLayoutConstraint!
    
    var googleData = GIDGoogleUser()
    var appleData: ASAuthorizationAppleIDCredential? = nil
    var fbData = [String:Any]()
    var loginFrom = 1
    private var currentNonce: String?

    private weak var window: UIWindow!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.emailField.placeholderTextColor = .black
        
        self.buttonLogin.alpha = 0.5
        self.buttonLogin.isEnabled = false
        
    
        if(self.view.frame.size.height == 667.0 || self.view.frame.size.height == 736.0){
            self.top1.constant = 20
            self.top2.constant = 20
        }
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
         
    }
    
  
    
    func getFacebookUserInfo(){
        let loginManager = LoginManager()
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
                
                debugPrint("ERROR FACEBOOK", error as Any)
                
                if (error == nil){
                    self.authFacebook()
                    
                }
            })
        }
    }
    
    func authFacebook(){
        ActivityIndicator.show(view: self.view)
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if(error == nil){
                let userId = authResult?.user.uid
                let firstName = authResult?.additionalUserInfo?.profile!["first_name"]
                let lastName = authResult?.additionalUserInfo?.profile!["last_name"]
                var father_last_name = ""
                var mother_last_name = ""
                let email = authResult?.additionalUserInfo?.profile!["email"]
                
                if(lastName != nil){
                    let lastNameComponents = (lastName  as? String)?.components(separatedBy: " ")
                    father_last_name = lastNameComponents![0]
                    mother_last_name = lastNameComponents![1]
                }
                
                let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
                let picture = authResult?.additionalUserInfo?.profile!["picture"] as? [String: NSDictionary]
                let pictureData = picture!["data"]
                
                
                let params : [String: String] = [
                    "user_id": userId! ,
                    "email": (email as! String) ,
                    "name": (firstName as! String) ,
                    "father_last_name":father_last_name,
                    "mother_last_name": mother_last_name,
                    "profile_picture": (pictureData!["url"] as? String) ?? "",
                    "fcm_token": fcmToken ?? ""
                ]
                
            
                self.getProfileSocialData(params: params)
            } else {
                
                ActivityIndicator.hide()
            }
        }
    }
    
    
    func getProfileSocialData(params: [String: String?]){
        

            ActivityIndicator.show(view: self.view)
        
            let url = "\(U_BASE)\(U_GET_PROFILE_SOCIAL)"
       
       
            SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: params, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE_SOCIAL) { (response) in
            
                debugPrint("-->", response)
                
                 if(response != nil){
                 
                     Singleton.shared.userInfo = response!.data!
                     Singleton.saveUserInfo(data:Singleton.shared.userInfo)
                     
                    
                    let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "main")
                    self.view.window?.rootViewController = myVC
                 }
                 
              
                
               
            }
    }
    
    func getProfileData(id: String){
        

            ActivityIndicator.show(view: self.view)
        
            let url = "\(U_BASE)\(U_GET_PROFILE)\(id)"
       
       
            SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
            
                ActivityIndicator.hide()
               
                if(response != nil){
                
                    Singleton.shared.userInfo = response!.data!
                    Singleton.saveUserInfo(data:Singleton.shared.userInfo)
                    
                    let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "main")
                    self.view.window?.rootViewController = myVC
                }
                
               
            }
    }
    
    @IBAction func aplpeAction(_ sender: Any){
        loginFrom = 3
        self.showAppleLogin()
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
    
    private func showAppleLogin() {
           let nonce = randomNonceString()
           currentNonce = nonce
           let appleIDProvider = ASAuthorizationAppleIDProvider()
           let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
           request.nonce = sha256(nonce)
        

           
           performSignIn(using: [request])
       }

    
    
    private func performSignIn(using requests: [ASAuthorizationRequest]) {
        
   
           guard let currentNonce = self.currentNonce else {
               return
           }
        

           let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
      
           authorizationController.performRequests()
        
   
        
       }
    
    private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""
            var remainingLength = length

            while remainingLength > 0 {
                let randoms: [UInt8] = (0 ..< 16).map { _ in
                    var random: UInt8 = 0
                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    if errorCode != errSecSuccess {
                        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    }
                    return random
                }

                randoms.forEach { random in
                    if length == 0 {
                        return
                    }

                    if random < charset.count {
                        result.append(charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }

            return result
        }

        @available(iOS 13.0, *)
        private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                    return String(format: "%02x", $0)
            }.joined()

            return hashString
        }
    
    
}

extension WelcomeViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}


enum SignInWithAppleToFirebaseResponse {
    case success
    case error
}

@available(iOS 13.0, *)
extension WelcomeViewController: ASAuthorizationControllerDelegate {

    func firebaseLogin(credential: ASAuthorizationAppleIDCredential) {
           // 3
           guard let nonce = currentNonce else {
             fatalError("Invalid state: A login callback was received, but no login request was sent.")
           }
           guard let appleIDToken = credential.identityToken else {
             print("Unable to fetch identity token")
             return
           }
           guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
             print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
             return
           }
        
        self.appleData = credential

        
        // LOGIN WITH APPLE
        
        debugPrint("FULLNAME",self.appleData?.fullName)
        debugPrint("EMAIL",self.appleData?.email)
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                       rawNonce: nonce)
     
        Auth.auth().signIn(with: credential) { (authResult, error) in
          
            if(error == nil){
                let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
               
              
                let email = authResult?.additionalUserInfo?.profile!["email"]
              
                let userId =  authResult?.user.uid
            
                
                let params : [String: String] = [
                    "user_id": (userId!) ,
                    "email": email as! String ,
                    "name": "" ,
                    "father_last_name": "",
                    "mother_last_name": "",
                    "profile_picture": "",
                    "fcm_token": fcmToken ?? ""
                ]
                
                self.getProfileSocialData(params: params)
                
              
            }
           
       
            
        }
     
      
       }
       private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
           // 1
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = credential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
     
        self.appleData = credential
        
        let currentCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                       rawNonce: nonce)
     
        Auth.auth().signIn(with: currentCredential) { (authResult, error) in
          
            if(error == nil){
                let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
               
              
                let email = credential.email
              
                let userId =  authResult?.user.uid
                var name = credential.fullName?.givenName ?? ""
                var father_last_name = ""
                var mother_last_name = ""
                
                let components = credential.fullName?.familyName!.components(separatedBy: " ")
                
                if(components?.count == 1){
                    father_last_name = components![0]
                } else if(components?.count == 2){
                    father_last_name = components![0]
                    mother_last_name = components![1]
                }
                
                let params : [String: String] = [
                    "user_id": (userId!) ,
                    "email": (email!) ,
                    "name": name,
                    "father_last_name": father_last_name,
                    "mother_last_name": mother_last_name,
                    "profile_picture": "",
                    "fcm_token": fcmToken ?? ""
                ]
                
                self.getProfileSocialData(params: params)
                
              
            }
           
       
            
        }
       }

       private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
           self.firebaseLogin(credential: credential)
       }


       func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
           switch authorization.credential {
           case let appleIdCredential as ASAuthorizationAppleIDCredential:
               if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                   registerNewAccount(credential: appleIdCredential)
               } else {
                   signInWithExistingAccount(credential: appleIdCredential)
               }
               break
           default:
               break
           }
       }

       func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
          
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
      
        let credential = GoogleAuthProvider.credential(withIDToken:   user.authentication.idToken,
                                                            accessToken:   user.authentication.accessToken)
        
       
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
         
            if(error == nil){

                let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
               
                var firstName = authResult?.additionalUserInfo?.profile!["name"] as! String
                let family_name = authResult?.additionalUserInfo?.profile!["family_name"]
                let email = authResult?.additionalUserInfo?.profile!["email"]
                let profile_picture = authResult?.additionalUserInfo?.profile!["picture"]
                var father_last_name = ""
                var mother_last_name = ""
                let userId =  authResult?.user.uid
                
                firstName = firstName.components(separatedBy: " ")[0]
                
                let components = (family_name as! String).components(separatedBy: " ")
         
                if(components.count > 0){
                    father_last_name = components[0]
                    
                    if(components.count > 1){
                        mother_last_name  = components[1]
                    }
                }
                
                let params : [String: String] = [
                    "user_id": (userId!) ,
                    "email": (email as! String) ,
                    "name": firstName ,
                    "father_last_name": father_last_name,
                    "mother_last_name": mother_last_name,
                    "profile_picture": (profile_picture as! String),
                    "fcm_token": fcmToken ?? ""
                ]
                
                self.getProfileSocialData(params: params)
           
            } else {
          
                ActivityIndicator.hide()
            }
        }
    }
    
    func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
       
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

