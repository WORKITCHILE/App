//
//  ResetPasswordViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var email: DesignableUILabel!
    @IBOutlet weak var newPassword: DesignableUITextField!
    @IBOutlet weak var confirmPassword: DesignableUITextField!
    
    var emailAddress = String()
    var otp = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.text = self.emailAddress
    }
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if(self.newPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter new password")
        }else if(self.confirmPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter confirm password")
        }else if(self.confirmPassword.text != self.newPassword.text){
          Singleton.shared.showToast(text: "Password not matched")
        }else {
            let param:[String:Any] = [
                "email":self.email.text ?? "",
                "otp":self.otp,
                "new_password":self.newPassword.text ?? ""
            ]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_CHANGE_PASS, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CHANGE_PASS) { (response) in
                Singleton.shared.showToast(text: "Password updated successfully.")
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(myVC, animated: true)
                self.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
                    if vc.isKind(of: ResetPasswordViewController.self)  {
                        return true
                    }else {
                        return false
                    }
                })

            }
            
        }
        
    }
    
}
