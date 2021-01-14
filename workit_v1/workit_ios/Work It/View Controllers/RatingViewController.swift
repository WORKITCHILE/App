//
//  RatingViewController.swift
//  
//
//  Created by qw on 29/02/20.
//

import UIKit
import Cosmos

protocol RatingFromhistory{
    func userRatedHistory()
}

class RatingViewController: UIViewController, UITextViewDelegate {
    //MARK: IBOutlets
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var yesButton: CustomButton!
    
    @IBOutlet weak var noButton: CustomButton!
    
    var isContactOutside = ""
    var jobData : GetJobResponse?
    var jobId  = String()
    var isNavigationFromHistory = false
    var historyDelegate:RatingFromhistory? = nil
    
    private let placeHolder = "Deja un comentario"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comment.text = placeHolder
        self.comment.delegate = self
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        if(jobId != ""){
            self.getSingleJob()
        }
    }
    
    
    func getSingleJob(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_SINGLE_JOB_OWNER + "\(Singleton.shared.userInfo.user_id ?? "")" + "&job_id=\(self.jobId)", method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { (response) in
            self.jobData = response?.data
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBActions
    
    
    @IBAction func yesAction(_ sender: Any) {
        if(self.yesButton.backgroundColor == .white){
            self.isContactOutside = "Si"
            self.yesButton.backgroundColor = UIColor(named: "GreenChatBox")
            self.noButton.backgroundColor = .white
        }else {
            self.isContactOutside = ""
            self.yesButton.backgroundColor = .white
            self.noButton.backgroundColor = .white
        }
    }
    
    @IBAction func noAction(_ sender: Any) {
        if(self.noButton.backgroundColor == .white){
            self.isContactOutside = "No"
            self.noButton.backgroundColor = UIColor(named: "GreenChatBox")
            self.yesButton.backgroundColor = .white
        }else {
            self.isContactOutside = ""
            self.yesButton.backgroundColor = .white
            self.noButton.backgroundColor = .white
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
         if(self.isContactOutside == ""){
            Singleton.shared.showToast(text: "Selecciona una opción")
        }else{
            ActivityIndicator.show(view: self.view)
            var param = [String:Any]()

            
            if(Singleton.shared.userInfo.user_id == self.jobData?.job_vendor_id){
                param = [
                    "job_id":self.jobData?.job_id,
                    "rate_from":self.jobData?.job_vendor_id,
                    "rate_from_name":Singleton.shared.userInfo.name,
                    "rate_to_name":self.jobData?.user_name,
                    "rate_to":self.jobData?.user_id,
                    "rating":"\(self.ratingView.rating)",
                    "rate_from_type":K_WANT_JOB,
                    "rate_to_type":K_POST_JOB,
                    "contact_outside":self.isContactOutside,
                    "comment":self.comment.text ?? ""
                ]
            }else {
         
                param = [
                    "job_id": self.jobData?.job_id,
                    "rate_from":Singleton.shared.userInfo.user_id,
                    "rate_from_name":Singleton.shared.userInfo.name,
                    "rate_to_name":self.jobData?.user_name,
                    "rate_to":self.jobData?.job_vendor_id,
                    "rating":"\(self.ratingView.rating)",
                    "rate_from_type":K_POST_JOB,
                    "rate_to_type":K_WANT_JOB,
                    "contact_outside":self.isContactOutside,
                    "comment":self.comment.text
                ]
            }
            
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_RATE_USER, method: .post, parameter: param, objectClass: Response.self, requestCode: U_RATE_USER) { (response) in
                Singleton.shared.showToast(text: response?.message ?? "")
                Singleton.shared.postedHistoryData = []
                Singleton.shared.receivedHistoryData = []
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
                ActivityIndicator.hide()
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == placeHolder){
            self.comment.text = ""
            self.comment.textColor = .black
        }else{
            self.comment.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            self.comment.text = placeHolder
            self.comment.textColor = .lightGray
        }else{
            self.comment.textColor = .black
        }
    }
    
    //MARK: IBActions
    @IBAction func skipAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
