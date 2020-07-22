//
//  AcceptJobViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Cosmos

class AcceptJobViewController: UIViewController, SuccessPopup, RatingFromhistory{
    func userRatedHistory(){
        self.getJobDetail()
    }
    
    func yesAction() {
        if(isPopupForPaymentSelection == 1){
            let myTime = Int(Date().timeIntervalSince1970)
            self.isPopupForPaymentSelection = 2
            let param = [
                "user_id":self.jobData?.user_id,
                "job_id":self.jobData?.job_id,
                "job_amount": self.bidDetail?.counteroffer_amount,
                "payment_option": paymentOptionDetail["id"]! == nil ? "WALLET":"BANK",
                "bank_detail_id": paymentOptionDetail["id"] as? String,
                "transaction_id":paymentOptionDetail["id"]! == nil ? "W\(myTime)":"B\(myTime)",
                "vendor_name": self.bidDetail?.vendor_name ?? self.jobData?.vendor_name ?? ""
                ] as? [String:Any]
            DispatchQueue.global(qos: .background).async {
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_OWNER_JOB_PAYMENT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_OWNER_JOB_PAYMENT) { (response) in
                    ActivityIndicator.hide()
                    Singleton.shared.runningJobData = []
                    self.callJobAPI(action: K_ACCEPT)
                }
            }
        }else if(isPopupForPaymentSelection == 3){
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
            myVC.jobDetail = self.jobData
            myVC.isRepostJob = true
            self.navigationController?.pushViewController(myVC, animated: true)
            navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
                if vc.isKind(of: AcceptJobViewController.self)  {
                    return true
                }else {
                    return false
                }
            })
            
        }else {
            ActivityIndicator.show(view: self.view)
            let param = [
                "job_id":self.jobData?.job_id,
                "user_id":Singleton.shared.userInfo.user_id
                ] as? [String:Any]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_CANCEL_JOB, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
                ActivityIndicator.hide()
                self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Job Cancelled Successfully", yesTitle: nil, noTitle: nil, isNoHidden: true)
                Singleton.shared.jobData = []
                Singleton.shared.postedHistoryData = []
                ActivityIndicator.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: IBOutelets
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var workerName: DesignableUILabel!
    
    @IBOutlet weak var viewReviewButton: UIButton!
    @IBOutlet weak var jobStatus: DesignableUILabel!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var jobTitle: DesignableUILabel!
    @IBOutlet weak var postedByName: DesignableUILabel!
    @IBOutlet weak var acceptedByName: DesignableUILabel!
    @IBOutlet weak var workerDescription: DesignableUILabel!
    @IBOutlet weak var jobDescription: DesignableUILabel!
    @IBOutlet weak var offerValue: DesignableUILabel!
    @IBOutlet weak var postedOnDate: DesignableUILabel!
    @IBOutlet weak var occupation: DesignableUILabel!
    @IBOutlet weak var startTime: DesignableUILabel!
    @IBOutlet weak var startDate: DesignableUILabel!
    @IBOutlet weak var viewForAccept: View!
    @IBOutlet weak var viewForReject: UIView!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: CustomButton!
    @IBOutlet weak var jobAddress: DesignableUILabel!
    @IBOutlet weak var jobCategory: DesignableUILabel!
    @IBOutlet weak var jobApproach: DesignableUILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var evaluationComment: DesignableUILabel!
    @IBOutlet weak var jobSubcategory: DesignableUILabel!
    @IBOutlet weak var viewPhotos: UIView!
    @IBOutlet weak var rateUserButton: UIButton!
    
    //var
    var jobData:GetJobResponse?
    var jobId: String?
    var bidDetail:BidResponse?
    var jobImage = [String]()
    var isNavigateFromtab = String()
    var paymentOptionDetail = [String?:Any?]()
    var isPopupForPaymentSelection = 2
    var isEvaluationScreen = false
    var evaluationText = String()
    var evaluationRating = String()
    var isVendorCancelJob = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getJobDetail()
    }
    
    func getJobDetail(){
        ActivityIndicator.show(view: self.view)
        var url = String()
        if(K_CURRENT_USER == K_POST_JOB){
            url = U_BASE + U_GET_SINGLE_JOB_OWNER + (Singleton.shared.userInfo.user_id ?? "") + "&job_id=\(self.jobId ?? "")"
        }else if(K_CURRENT_USER == K_WANT_JOB){
            url = U_BASE + U_GET_SINGLE_JOB_VENDOR + (Singleton.shared.userInfo.user_id ?? "") + "&job_id=\(self.jobId ?? "")"
        }
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { (response) in
            self.jobData = response.data
            self.manageView()
            ActivityIndicator.hide()
        }
    }
    
    func handleRepostJob(){
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
        isPopupForPaymentSelection = 3
        myVC.image = #imageLiteral(resourceName: "information-button copy")
        myVC.okBtnTtl = "Repost"
        myVC.cancelBtnTtl = "Cancel"
        myVC.cancelBtnHidden = false
        myVC.successDelegate = self
        myVC.modalPresentationStyle = .overFullScreen
        myVC.titleLabel = "\(self.jobData?.vendor_name ?? "") has retracted his offer.\n Do you want to repost with the new time or want to cancel the complete job?"
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    func manageView(){
        if(self.isVendorCancelJob){
            self.handleRepostJob()
        }
        
        if(jobData?.status == K_POSTED){
            if(K_CURRENT_USER == K_POST_JOB){
                if(bidDetail?.owner_status == "REJECTED"){
                    self.viewForAccept.isHidden = true
                    self.jobStatus.text = "Bid Rejected by you"
                    self.viewForReject.isHidden = true
                }else{
                    self.viewForAccept.isHidden = false
                    self.viewForReject.isHidden = false
                    self.viewReviewButton.isHidden = false
                }
            }else if(K_CURRENT_USER == K_WANT_JOB){
                self.viewReviewButton.isHidden = true
                if(bidDetail?.owner_status == "REJECTED"){
                    self.viewForAccept.isHidden = true
                    self.jobStatus.text = "Bid Rejected"
                    self.viewForReject.isHidden = true
                }else if(bidDetail?.owner_status == "ACCEPTED"){
                    self.viewForAccept.isHidden = true
                    self.jobStatus.text = "Bid Accepted"
                    self.viewForReject.isHidden = true
                }
            }
        }else  if(jobData?.status == K_ACCEPT){
            if(K_CURRENT_USER == K_POST_JOB){
                self.viewForAccept.isHidden = true
                self.viewForReject.isHidden = false
                self.jobStatus.text = "Job Accepted"
                self.viewReviewButton.isHidden = false
                self.rejectButton.isUserInteractionEnabled = true
                self.rejectButton.setTitle("Cancel Job", for: .normal)
            }else {
                self.viewForAccept.isHidden = true
                self.viewForReject.isHidden = true
                self.jobStatus.text = "Job Accepted"
            }
        }else  if(jobData?.status == K_START){
            self.viewReviewButton.isHidden = false
            self.viewForAccept.isHidden = false
            if(self.jobData?.started_by == K_WANT_JOB){
                self.jobStatus.text = "Please confirm to Start Job"
                self.acceptButton.setTitle("Confirm", for: .normal)
                self.viewForReject.isHidden = false
                self.rejectButton.setTitle("Cancel Job", for: .normal)
            }else if(self.jobData?.started_by == K_POST_JOB){
                self.jobStatus.text = "Job Started"
                self.acceptButton.setTitle("Message", for: .normal)
                self.viewForReject.isHidden = true
            }else {
                self.jobStatus.text = "Job Started"
                self.acceptButton.setTitle("Message", for: .normal)
                self.viewForReject.isHidden = true
            }
        }else if(jobData?.status == K_FINISH){
            self.viewReviewButton.isHidden = false
            self.viewForAccept.isHidden = true
            self.viewForReject.isHidden = false
            self.rejectButton.setTitle("Release Payment", for: .normal)
            self.jobStatus.text = "Job finished, release payment"
        }else if(jobData?.status == K_PAID){
            if((self.jobData?.owner_rated == 0) && (K_CURRENT_USER == K_POST_JOB)){
                self.rateUserButton.isHidden = false
            }else if((self.jobData?.vendor_rated == 0) && (K_CURRENT_USER == K_WANT_JOB)){
                self.rateUserButton.isHidden = true
            }else {
                self.rateUserButton.isHidden = true
            }
            self.viewReviewButton.isHidden = true
            self.viewForAccept.isHidden = true
            self.viewForReject.isHidden = true
            self.jobStatus.text = "Job Finished"
        }else if(jobData?.status == K_CANCEL){
            self.viewReviewButton.isHidden = true
            self.viewForAccept.isHidden = true
            self.viewForReject.isHidden = true
            if((self.jobData?.canceled_by == K_WANT_JOB) && ((self.jobData?.is_reposted ?? 0) == 0) && (Singleton.shared.userInfo.user_id == self.jobData?.user_id)){
                self.rateUserButton.setTitle("Repost Job", for: .normal)
                self.rateUserButton.isHidden = false
            }
            self.jobStatus.text = "Job Cancelled"
        }
        if(jobData?.status == K_POSTED){
            self.viewReviewButton.isHidden = false
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.vendor_image ?? self.bidDetail?.vendor_image ??
                self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            let userName = self.jobData?.vendor_name ?? self.bidDetail?.vendor_name ?? self.jobData?.user_name ?? ""
            self.workerName.text = (userName).formatName(name:userName)
            
            self.offerValue.text = "$" + (self.jobData?.my_bid?.counteroffer_amount ?? self.jobData?.counteroffer_amount ?? self.bidDetail?.counteroffer_amount ?? "0")
            self.occupation.text =  self.jobData?.vendor_occupation ?? self.bidDetail?.vendor_occupation ?? self.jobData?.user_occupation ?? ""
            self.workerDescription.text =  self.jobData?.comment ?? self.bidDetail?.comment ?? self.jobData?.job_description ?? ""
            self.userRating.rating = Double(self.jobData?.vendor_average_rating ?? self.bidDetail?.vendor_average_rating ?? self.jobData?.user_average_rating ?? "0")!
        }else {
            self.viewReviewButton.isHidden = true
            if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
                self.workerImage.sd_setImage(with: URL(string: self.jobData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                self.userRating.rating = Double(self.jobData?.vendor_average_rating ?? "0")!
                self.workerName.text = (self.jobData?.vendor_name ?? self.jobData?.user_name ?? "").formatName(name:self.jobData?.vendor_name ?? self.jobData?.user_name ?? "")
                
                self.offerValue.text = "$" + (self.jobData?.service_amount  ?? self.bidDetail?.counteroffer_amount ?? "0")
                
                self.occupation.text = self.jobData?.vendor_occupation   ?? self.jobData?.user_occupation
                self.workerDescription.text = self.jobData?.comment ?? ""
            }else {
                self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
                self.workerName.text =  (self.jobData?.user_name ?? "").formatName(name: self.jobData?.user_name ?? "")
                self.offerValue.text = "$" + (self.jobData?.service_amount  ?? self.bidDetail?.counteroffer_amount ?? "0")
                
                self.occupation.text = self.jobData?.user_occupation ?? ""
                self.workerDescription.text = self.jobData?.comment ?? self.bidDetail?.comment ?? ""
            }
        }
        if(self.isEvaluationScreen){
            self.evaluationComment.text = "Comment: " + evaluationText
            self.evaluationComment.isHidden = false
            self.userRating.rating = Double(self.evaluationRating)!
        }
        
        self.jobDescription.text =   self.jobData?.job_description
        self.postedByName.text = self.jobData?.user_name ?? "-"
        self.acceptedByName.text = self.jobData?.vendor_name ?? "-"
        self.postedOnDate.text = self.convertTimestampToDate(self.jobData?.created_at ?? 0, to: "dd.MM.yyyy")
        self.jobCategory.text = self.jobData?.category_name
        self.jobSubcategory.text = self.jobData?.subcategory_name
        
        self.jobApproach.text = self.jobData?.job_approach
        self.startDate.text = self.jobData?.job_date
        self.startTime.text = self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobAddress.text = self.jobData?.job_address
        self.jobImage = self.jobData!.images!
        self.jobTitle.text = self.jobData?.job_name
        if(self.jobImage.count == 0){
            self.viewPhotos.isHidden = true
        }else {
            self.viewPhotos.isHidden = false
        }
        self.photoCollection.reloadData()
    }
    
    @objc func payForJob(_ notif: Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(N_SELECT_BANK_ACCOUNT), object: nil)
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
        myVC.image = #imageLiteral(resourceName: "tick")
        
        myVC.okBtnTtl = "Yes"
        myVC.cancelBtnTtl = "No"
        myVC.cancelBtnHidden = false
        myVC.successDelegate = self
        myVC.modalPresentationStyle = .overFullScreen
        var accountId : String?
        if((notif.userInfo?["isWallet"] as? Int) == 1){
            self.paymentOptionDetail = ["id": nil, "isWallet": 1]
            myVC.titleLabel = "Are you sure you want to pay from wallet for this job?"
            accountId = nil
        }else{
            myVC.titleLabel = "Are you sure you want to pay from \(notif.userInfo?["bank"] as! String) for this job?"
            accountId = notif.userInfo?["id"] as! String
            self.paymentOptionDetail = ["id": accountId, "isWallet": 0]
        }
        self.isPopupForPaymentSelection = 1
        
        self.navigationController?.present(myVC, animated: true, completion: nil)
        
    }
    
    func jobAction(action: String){
        if(action == K_ACCEPT){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountSettingViewController") as! AccountSettingViewController
            NotificationCenter.default.addObserver(self, selector: #selector(self.payForJob(_:)), name: NSNotification.Name(N_SELECT_BANK_ACCOUNT), object: nil)
            myVC.isSelectCard = true
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }else if(action == K_CONFIRM){
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_OWNER_JOB_APPROVAL, method: .post, parameter: ["job_id": self.jobData?.job_id ?? ""], objectClass: Response.self, requestCode: U_OWNER_JOB_APPROVAL) { (response) in
                ActivityIndicator.hide()
                self.getJobDetail()
                Singleton.shared.showToast(text: "Job Started")
            }
        }else {
            self.callJobAPI(action: action)
        }
    }
    
    func callJobAPI(action: String){
        ActivityIndicator.show(view: self.view)
        let param = [
            "job_id":jobData?.job_id,
            "bid_id":bidDetail?.bid_id,
            "status":action
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_BID_ACTION, method: .post, parameter: param, objectClass: Response.self, requestCode: U_BID_ACTION) { (response) in
            Singleton.shared.jobData = []
            let time = Int(Date().timeIntervalSince1970)
            
            if(action == K_REJECT){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                Singleton.shared.jobData = []
                Singleton.shared.showToast(text: "Bid rejected successfully.")
                self.navigationController?.pushViewController(myVC, animated: true)
            }else {
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            
            ActivityIndicator.hide()
        }
        
    }
    
    func releasePayment(){
        ActivityIndicator.show(view: self.view)
        let param = [
            "job_id":jobData?.job_id,
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_RELEASE_JOB_PAYMENT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_RELEASE_JOB_PAYMENT) { (response) in
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
            Singleton.shared.jobData = []
            Singleton.shared.postedHistoryData = []
            Singleton.shared.receivedHistoryData = []
            Singleton.shared.runningJobData = []
            myVC.jobId = self.jobData?.job_id ?? ""
            self.navigationController?.pushViewController(myVC, animated: true)
            ActivityIndicator.hide()
        }
    }
    
    
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func rateUserAction(_ sender: Any) {
        if(self.rateUserButton.titleLabel?.text == "Repost Job"){
            self.handleRepostJob()
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
            myVC.isNavigationFromHistory = true
            myVC.historyDelegate = self
            myVC.jobData = self.jobData
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    @IBAction func viewReviewAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "VendorReviewsViewController") as! VendorReviewsViewController
        myVC.userId = self.bidDetail?.vendor_id ?? ""
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        if(acceptButton.titleLabel!.text == "Accept"){
            self.jobAction(action: K_ACCEPT)
        }else if(acceptButton.titleLabel!.text == "Confirm"){
            self.jobAction(action: K_CONFIRM)
        }else if(acceptButton.titleLabel!.text == "Message"){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.jobDetail = self.jobData
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func rejectAction(_ sender: Any) {
        if(rejectButton.titleLabel!.text == "Cancel Job"){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
            myVC.image = #imageLiteral(resourceName: "tick")
            
            myVC.okBtnTtl = "Yes"
            myVC.cancelBtnTtl = "No"
            myVC.cancelBtnHidden = false
            myVC.successDelegate = self
            myVC.modalPresentationStyle = .overFullScreen
            myVC.titleLabel = "Job cancellation will be punished with 15% of the posted job amount. Still you want to cancel the job?"
            self.isPopupForPaymentSelection = 2
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }else if(rejectButton.titleLabel!.text == "Reject"){
            self.jobAction(action: K_REJECT)
        }else if(rejectButton.titleLabel!.text == "Release Payment"){
            self.releasePayment()
        }
    }
}

extension AcceptJobViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jobImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        cell.jobImage.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageView = UIImageView()
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
}
