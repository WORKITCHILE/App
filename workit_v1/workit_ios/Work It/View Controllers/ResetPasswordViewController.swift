//
//  ResetPasswordViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    //MARK: IBOutlets

    @IBOutlet weak var oldPassword: DesignableUITextField!
    @IBOutlet weak var newPassword: DesignableUITextField!
    @IBOutlet weak var confirmPassword: DesignableUITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        setNavigationBar()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if(self.oldPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu antigua contraseña")
        } else if(self.newPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu nueva contraseña")
        }else if(self.confirmPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Confirma tu nueva contraseña")
        }else if(self.confirmPassword.text != self.newPassword.text){
          Singleton.shared.showToast(text: "Contraseñas no concuerdan")
        }else {
            
            ActivityIndicator.show(view: self.view)
            
            if Auth.auth().currentUser != nil {
                let user = Auth.auth().currentUser
                let auth = EmailAuthProvider.credential(withEmail: Singleton.shared.userInfo.email ?? "" , password: self.oldPassword.text ?? "")
                
                user?.reauthenticate(with: auth, completion: { (result, error) in
                    debugPrint(result)
                    ActivityIndicator.hide()
                    if(error != nil){
                        Auth.auth().currentUser?.updatePassword(to: self.newPassword.text ?? "", completion: { error1 in
                            /***/
                            debugPrint("ERROR", error1)
                            let alertMessage = (error1 == nil) ? "Tu contraseña ha sido cambiada con exito" : "Ha ocurrido un error"
                            let alert = UIAlertController(title: "Workit", message: alertMessage, preferredStyle: .alert)
                                      
                               alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                                self.navigationController?.popViewController(animated: true)
                               })
                             
                               
                               self.present(alert, animated: true)
                        })
                    }
                })
                
            }
          
        }
        
    }
    
}
