//
//  SupportViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class SupportViewController: UIViewController,UITextViewDelegate {
    //MARK: IBOUtlets
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var animation : AnimationView!
    
    private let placeholderString = "Escribe un mensaje"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
       
        self.setNavigationBar()
        
        self.comment.text = placeholderString
        self.comment.delegate = self
        
        let starAnimation = Animation.named("support")
        animation!.animation = starAnimation
        
        animation?.loopMode = .loop
        animation?.play()
    }
  
    
    //MARK: IBActions

    
    @IBAction func sendAction(_ sender: Any) {
        if(self.comment.text == placeholderString || self.comment.text == ""){
            Singleton.shared.showToast(text: "Debes escribir un mensaje")
        }else {
            
            let param = [
                "user_id":Singleton.shared.userInfo.user_id ?? "",
                "message":self.comment.text ?? ""
            ] as? [String:Any]
            
            
            ActivityIndicator.show(view: self.view)
            let url = "\(U_BASE)\(U_SUPPORT)"
            SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SUPPORT) { (response) in
              
                ActivityIndicator.hide()
                let alert = UIAlertController(title: "Workit", message: "Gracias por conectarse con WORKIT, uno de los encargados del soporte al cliente se contactara con usted en las próximas 48 horas", preferredStyle: .alert)
                          
                   alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                     
                    self.navigationController?.popViewController(animated: true)
                     
                      
                   })
                 
                
                   self.present(alert, animated: true)
                
                self.comment.text = self.placeholderString
                self.comment.textColor = .lightGray
                
                
            }
            
        }
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
           if(textView.text == placeholderString){
               self.comment.text = ""
               self.comment.textColor = .black
           }else{
             self.comment.textColor = .black
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
          if(textView.text == ""){
               self.comment.text = placeholderString
               self.comment.textColor = .lightGray
           }else{
             self.comment.textColor = .black
           }
       }
}
