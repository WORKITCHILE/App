//
//  StartJobViewController.swift
//  Work It
//
//  Created by qw on 28/02/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class StartJobViewController: UIViewController, UITextViewDelegate, SlideButtonDelegate, RatingFromhistory,SuccessPopup {
    func yesAction() {
        ActivityIndicator.show(view: self.view)
        let param = [
            "job_id":self.jobData?.job_id ?? "",
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_VENDOR_CANCEL_JOB, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
            ActivityIndicator.hide()
            self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Job Cancelled Successfully", yesTitle: nil, noTitle: nil, isNoHidden: true)
            Singleton.shared.jobData = []
            Singleton.shared.vendorAcceptedBids = []
            Singleton.shared.runningJobData = []
            ActivityIndicator.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func userRatedHistory(){
        self.getJobDetail()
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var workerName: DesignableUILabel!
    
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
    
    @IBOutlet weak var viewPhotos: UIView!
    @IBOutlet weak var jobCategory: DesignableUILabel!
    @IBOutlet weak var jobApproach: DesignableUILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var slidingButton: MMSlidingButton!
    @IBOutlet weak var viewforMessage: UIView!
    @IBOutlet weak var messageButton: CustomButton!
    @IBOutlet weak var jobSubcategory: DesignableUILabel!
    @IBOutlet weak var rateUserButton: UIButton!
    @IBOutlet weak var viewForCancel: UIView!
    
    
    var jobData:GetJobResponse?
    var jobId: String?
    var jobImage = [String]()
    var isNavigateFromtab: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.slidingButton.alpha = 0
        slidingButton.delegate = self
        self.getJobDetail()
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
    
    func manageView() {
        self.viewForCancel.isHidden = self.jobData?.status != K_ACCEPT
        
        if(self.jobData?.status == K_START){
            if(self.jobData?.started_by == K_POST_JOB){
                self.slidingButton.alpha = 1
                self.viewforMessage.isHidden = false
                self.slidingButton.buttonText = "Finish Job"
                self.jobStatus.text = "Job Started"
            }else if(self.jobData?.started_by == K_WANT_JOB){
                self.slidingButton.alpha = 0
                self.viewforMessage.isHidden = true
                self.slidingButton.buttonText = "Finish Job"
                self.jobStatus.text = "Waiting for client to Confirm Job"
            }
            self.slidingButton.imageName = UIImage(named: "arrow")!
            self.workerName.text = self.jobData?.user_name!.formatName()
            self.occupation.text = self.jobData?.user_occupation
            self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else if(self.jobData?.status == K_FINISH){
            self.slidingButton.isHidden = true
            self.viewforMessage.isHidden = true
            self.workerName.text = self.jobData?.user_name!.formatName()
            self.occupation.text = self.jobData?.user_occupation
            self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
            self.jobStatus.text = "Waiting for client to release amount"
        }else  if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
            self.slidingButton.alpha = 1
            
            self.slidingButton.imageName = UIImage(named: "arrow")!
            self.workerName.text = (self.jobData?.vendor_name ?? self.jobData?.user_name ?? "").formatName()
            
            self.occupation.text = self.jobData?.vendor_occupation
            self.userRating.rating = Double(self.jobData?.vendor_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else if(self.jobData?.status == K_PAID) {
            self.slidingButton.isHidden = true
            self.viewforMessage.isHidden = true
            self.jobStatus.text = "Job FINISHED"
            self.slidingButton.imageName = UIImage(named: "arrow")!
            self.workerName.text = self.jobData?.user_name!.formatName()
            self.occupation.text = self.jobData?.user_occupation
            self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else if(self.jobData?.status == K_CANCEL) {
            self.slidingButton.isHidden = true
            self.viewforMessage.isHidden = true
            self.jobStatus.text = "Job Cancelled"
            self.slidingButton.imageName = UIImage(named: "arrow")!
            self.workerName.text = self.jobData?.user_name!.formatName()
            self.occupation.text = self.jobData?.user_occupation
            self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else {
            self.slidingButton.alpha = 1
            self.slidingButton.isHidden = false
            self.slidingButton.imageName = UIImage(named: "arrow")!
            self.workerName.text = self.jobData?.user_name!.formatName()
            self.occupation.text = self.jobData?.user_occupation
            self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }
        self.jobDescription.text =   self.jobData?.job_description ?? ""
        self.postedByName.text = self.jobData?.user_name ?? "-"
        self.acceptedByName.text = self.jobData?.vendor_name ?? "-"
        self.postedOnDate.text = self.convertTimestampToDate(self.jobData?.created_at ?? 0, to: "dd.MM.yyyy")
        self.workerDescription.text = self.jobData?.comment ?? ""
        self.jobCategory.text = self.jobData?.category_name
        self.jobApproach.text = self.jobData?.job_approach
        self.startDate.text = self.jobData?.job_date
        self.startTime.text =  self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobAddress.text = self.jobData?.job_address
        self.jobImage = (self.jobData?.images!)!
        self.jobTitle.text = self.jobData?.job_name
        self.offerValue.text = "$" + (self.jobData?.counteroffer_amount ?? self.jobData?.my_bid?.counteroffer_amount ?? "0")
        if(self.jobImage.count == 0){
            self.viewPhotos.isHidden = true
        }else {
            self.viewPhotos.isHidden = false
        }
        self.jobSubcategory.text = self.jobData?.subcategory_name
        
        self.photoCollection.reloadData()
    }
    
    func buttonStatus(status: String, sender: MMSlidingButton) {
        print("status")
        if(status == "Unlocked"){
            ActivityIndicator.show(view: self.view)
            self.slidingButton.reset()
            var param = [String:Any]()
            if(slidingButton.buttonText == "Start Job"){
                param = [
                    "job_id":self.jobData?.job_id,
                    "status":"STARTED",
                    "vendor_id":self.jobData?.job_vendor_id
                ]
                
            }else if(slidingButton.buttonText == "Finish Job"){
                param = [
                    "job_id":self.jobData?.job_id,
                    "status":"FINISHED",
                    "vendor_id":self.jobData?.job_vendor_id
                ]
            }
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_JOB_ACTION, method: .post, parameter: param, objectClass: Response.self, requestCode: U_JOB_ACTION) { (response) in
                if(self.slidingButton.buttonText == "Finish Job"){
                    self.jobStatus.text = "Waiting to client to release amount"
                    self.openSuccessPopup(img: #imageLiteral(resourceName: "information-button copy"), msg: "Your job has been finished", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                    self.viewforMessage.isHidden = true
                    self.jobStatus.text = "Waiting for client to release amount"
                    self.getJobDetail()
                    self.removeChatId()
                    self.navigationController?.popViewController(animated: true)
                }else {
                    self.openSuccessPopup(img: #imageLiteral(resourceName: "information-button copy"), msg: "Your job has been Started", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                    self.viewforMessage.isHidden = false
                    self.getJobDetail()
                }
                ActivityIndicator.hide()
            }
        }else{
            self.slidingButton.reset()
        }
    }
    
    func removeChatId() {
        var chatId = self.jobData?.job_id ?? ""
        let reff = ref.child("messages").child(chatId)
        let storageReff = storageRef.child("chat_photos").child(chatId)
        storageReff.delete { (error) in
            print(error)
        }
        
        reff.removeValue { (error, dataRef) in
            print(error)
        }
    }
    
    
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
        myVC.image = #imageLiteral(resourceName: "tick")
        myVC.okBtnTtl = "Yes"
        myVC.cancelBtnTtl = "No"
        myVC.cancelBtnHidden = false
        myVC.successDelegate = self
        myVC.modalPresentationStyle = .overFullScreen
        myVC.titleLabel = "Do you want to cancel the job?"
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func rateUserAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        myVC.isNavigationFromHistory = true
        myVC.historyDelegate = self
        myVC.jobData = self.jobData
        self.navigationController?.pushViewController(myVC, animated: true)
        
    }
    
    
    @IBAction func messageAction(_ sender: Any) {
        if(messageButton.titleLabel!.text == "Cancel Job"){
            
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.jobDetail = self.jobData
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
    }
}

extension StartJobViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        //self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
}
