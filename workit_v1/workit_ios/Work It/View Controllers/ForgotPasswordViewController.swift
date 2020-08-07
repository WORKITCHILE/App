//
//  ForgotPasswordViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SwiftyCodeView


class ForgotPasswordViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var codeView: SwiftyCodeView!
    @IBOutlet weak var email: DesignableUITextField!
    @IBOutlet weak var codeMainView: UIView!
    @IBOutlet weak var sendOTPView: View!
    @IBOutlet weak var headingLabel: DesignableUILabel!
    
    var emailAdd = String()
    var isNewuser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isNewuser {
            self.email.isUserInteractionEnabled = true
            self.email.text = Singleton.shared.userInfo.email
            self.headingLabel.text = "Verify Email"
        } else {
            self.email.text = self.emailAdd
            self.email.isUserInteractionEnabled = false
        }
        
        self.sendOTPView.isHidden = false
        self.email.placeholderTextColor = .white
        
        setTransparentHeader()
        setNavigationBar()
        
    }
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func sendOtpAction(_ sender: Any) {
        if self.email.text!.isEmpty {
            Singleton.shared.showToast(text: "Enter email address")
        }else if !(self.isValidEmail(emailStr: self.email.text ?? "")){
            Singleton.shared.showToast(text: "Enter valid email sddress")
        } else if(self.isNewuser){
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_VERIFY_MAIL, method: .post, parameter: ["email": self.email.text ?? ""], objectClass: Response.self, requestCode: U_VERIFY_MAIL) { (response) in
                Singleton.shared.showToast(text: "An OTP is sent to above email")
                self.email.isUserInteractionEnabled = false
                self.codeMainView.isHidden = false
                self.sendOTPView.isHidden = true
                ActivityIndicator.hide()
            }
        } else {
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_FORGOT_PASS, method: .post, parameter:["email":self.email.text ?? ""], objectClass: Response.self, requestCode: U_FORGOT_PASS) { (response) in
                self.email.isUserInteractionEnabled = false
                self.codeMainView.isHidden = false
                self.sendOTPView.isHidden = true
                Singleton.shared.showToast(text: "A verification code is sent to above email")
                ActivityIndicator.hide()
            }
        }
    }
    
    @IBAction func verifyAction(_ sender: Any) {
        if(codeView.code.count != 6){
            Singleton.shared.showToast(text: "Enter code")
        }else {
            if(self.isNewuser){
                ActivityIndicator.show(view: self.view)
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_VERIFY_OTP, method: .post, parameter: ["email": self.email.text ?? "","verification_code": codeView.code,"user_id": Singleton.shared.userInfo.user_id ?? ""], objectClass: Response.self, requestCode: U_VERIFY_OTP) { (response) in
                    Singleton.shared.showToast(text: "Your email verified successfully")
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionViewController") as! ChooseOptionViewController
                    self.navigationController?.pushViewController(myVC, animated: true)
                    ActivityIndicator.hide()
                }
                
            }else{
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
                myVC.emailAddress = self.email.text ?? ""
                myVC.otp = codeView.code
                self.navigationController?.pushViewController(myVC, animated: true)
                self.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
                    if vc.isKind(of: ForgotPasswordViewController.self)  {
                        return true
                    }else {
                        return false
                    }
                })
            }
        }
    }
    
    
    @IBAction func changePasswordAction(_ sender: Any) {
        if(self.email.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter email address")
        } else if !(self.isValidEmail(emailStr: self.email.text ?? "")){
            Singleton.shared.showToast(text: "Enter valid email sddress")
        } else if(self.isNewuser){
            self.sendOtpAction(self)
        } else {
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_FORGOT_PASS, method: .post, parameter:["email":self.email.text ?? ""], objectClass: Response.self, requestCode: U_FORGOT_PASS) { (response) in
                self.codeMainView.isHidden = false
                Singleton.shared.showToast(text: "A verification code is send again to above email")
                ActivityIndicator.hide()
                
            }
        }
    }
    
}
