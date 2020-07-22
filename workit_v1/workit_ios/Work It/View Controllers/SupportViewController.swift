//
//  SupportViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController,UITextViewDelegate {
    //MARK: IBOUtlets
    @IBOutlet weak var comment: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.comment.text = "Write Message"
        self.comment.delegate = self
    }
  
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if(self.comment.text == "Write Message" || self.comment.text == ""){
            Singleton.shared.showToast(text: "Write your comments")
        }else {
            let param = [
                "user_id":Singleton.shared.userInfo.user_id ?? "",
              "message":self.comment.text ?? ""
            ] as? [String:Any]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_SUPPORT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SUPPORT) { (response) in
                self.openSuccessPopup(img: #imageLiteral(resourceName: "tick"), msg: "Thanks for connecting with WORKIT, One of the customer representative will connect with you within the next 48 hours.", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                
                self.comment.text = "Enter Message"
                self.comment.textColor = .lightGray
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
           if(textView.text == "Write Message"){
               self.comment.text = ""
               self.comment.textColor = .black
           }else{
             self.comment.textColor = .black
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
          if(textView.text == ""){
               self.comment.text = "Write Message"
               self.comment.textColor = .lightGray
           }else{
             self.comment.textColor = .black
           }
       }
}
