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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comment.text = "Type here"
        self.comment.delegate = self
        if !(isNavigationFromHistory){
            self.openSuccessPopup(img: #imageLiteral(resourceName: "tick"), msg: "Job Finished Successfully", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
        }
        if(jobId != ""){
            self.getSingleJob()
        }
    }
    
    
    func getSingleJob(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_SINGLE_JOB_OWNER + "\(Singleton.shared.userInfo.user_id ?? "")" + "&job_id=\(self.jobId)", method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { (response) in
            self.jobData = response.data
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBActions
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func yesAction(_ sender: Any) {
        if(self.yesButton.backgroundColor == .white){
            self.isContactOutside = "Yes"
            self.yesButton.backgroundColor = darkBlue
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
            self.noButton.backgroundColor = darkBlue
            self.yesButton.backgroundColor = .white
        }else {
            self.isContactOutside = ""
            self.yesButton.backgroundColor = .white
            self.noButton.backgroundColor = .white
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
         if(self.isContactOutside == ""){
            Singleton.shared.showToast(text: "Plese select option")
        }else{
            ActivityIndicator.show(view: self.view)
            var param = [String:Any]()
            var userType1 = String()
            var userType2 = String()
            if(Singleton.shared.userInfo.user_id == self.jobData?.job_vendor_id){
                // userType1 = K_WANT_JOB
                // userType2 = K_POST_JOB
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
                // userType2 = K_WANT_JOB
                // userType1 = K_POST_JOB
                param = [
                    "job_id":self.jobData?.job_id,
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
                Singleton.shared.showToast(text: response.message ?? "")
                Singleton.shared.postedHistoryData = []
                Singleton.shared.receivedHistoryData = []
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
                if(self.isNavigationFromHistory){
                    self.historyDelegate?.userRatedHistory()
                    self.back()
                }else{
                    if(K_CURRENT_USER == K_POST_JOB){
                        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                        self.navigationController?.pushViewController(myVC, animated: true)
                    }else if(K_CURRENT_USER == K_WANT_JOB){
                        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                        self.navigationController?.pushViewController(myVC, animated: true)
                    }
                }
                ActivityIndicator.hide()
            }
            //            Singleton.shared.showToast(text: "Feedback Send Successfully")
            //            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            //            self.navigationController?.pushViewController(myVC, animated: true)
            //            ActivityIndicator.hide()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "Type here"){
            self.comment.text = ""
            self.comment.textColor = .black
        }else{
            self.comment.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            self.comment.text = "Type here"
            self.comment.textColor = .lightGray
        }else{
            self.comment.textColor = .black
        }
    }
    
    //MARK: IBActions
    @IBAction func skipAction(_ sender: Any) {
        if(isNavigationFromHistory){
            self.back()
        }else{
            if(K_CURRENT_USER == K_POST_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }else if(K_CURRENT_USER == K_WANT_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }
        }
    }
}
