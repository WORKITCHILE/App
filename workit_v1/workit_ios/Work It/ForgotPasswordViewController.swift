//
//  ForgotPasswordViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 15-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    public var email = ""
    @IBOutlet weak var emailInput : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailInput.text = email
        
        setNavigationBar()
    }
    

    @IBAction func sendEmail(_ sender : AnyObject){
        
        ActivityIndicator.show(view: self.view)
        Auth.auth().sendPasswordReset(withEmail: self.emailInput.text ?? "") { error in
            
            debugPrint("error", error)
            
            ActivityIndicator.hide()
            
            let alert = UIAlertController(title: "Workit", message: "Revisa tu correo y sigue las instrucciones", preferredStyle: .alert)
                      
               alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                self.navigationController?.popViewController(animated: true)
               })
             
             
               self.present(alert, animated: true)
        }
    }
    

}
