//
//  ViewJobViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class ViewJobViewController: UIViewController, SuccessPopup {
   
    func yesAction() {
        ActivityIndicator.show(view: self.view)
        let param = [
            "bid_id":self.jobDetail?.my_bid?.bid_id,
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_VENDOR_CANCEL_BID, method: .post, parameter: param, objectClass: Response.self, requestCode: U_VENDOR_CANCEL_BID) { (response) in
            ActivityIndicator.hide()
            self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Job offer cancelled successfully", yesTitle: nil, noTitle: nil, isNoHidden: true)
            Singleton.shared.jobData = []
            Singleton.shared.vendorAcceptedBids = []
            Singleton.shared.vendorRejectedBids = []
            Singleton.shared.runningJobData = []
            ActivityIndicator.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var postedByOccupation: DesignableUILabel!
    @IBOutlet weak var address: DesignableUILabel!
    @IBOutlet weak var postedPrice: DesignableUILabel!
    @IBOutlet weak var postedTime: DesignableUILabel!
    @IBOutlet weak var postedDate: DesignableUILabel!
    @IBOutlet weak var postedByName: DesignableUILabel!
    @IBOutlet weak var addWorkerComment: UITextView!
    @IBOutlet weak var counterOfferPrice: UITextField!
    @IBOutlet weak var joDesc: DesignableUILabel!
    @IBOutlet weak var workSchedule: DesignableUILabel!
    @IBOutlet weak var bidStack: UIStackView!
    @IBOutlet weak var counterOfferLabel: DesignableUILabel!
    @IBOutlet weak var mapView: MapVC!
    @IBOutlet weak var jobApproach: DesignableUILabel!
    @IBOutlet weak var placeBidView: View!
    @IBOutlet weak var bidRejectLabel: DesignableUILabel!
    
    @IBOutlet weak var jobCategory: DesignableUILabel!
    @IBOutlet weak var jobSubcategory: DesignableUILabel!
    
    @IBOutlet weak var viewPhotos: UIView!
    @IBOutlet weak var placeBidButton: CustomButton!
    
    var jobDetail:GetJobResponse?
    var jobId = String()
    var jobImage = [String]()
    var counterPrice = Int()
    var isBankdetailAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addWorkerComment.delegate = self
        self.addWorkerComment.text = "Type here"
        self.getSingleJob()
    }
    
    func getSingleJob(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_SINGLE_JOB_WORKER + self.jobId + "&user_id=\(Singleton.shared.userInfo.user_id ?? "")", method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_WORKER) { (response) in
            self.jobDetail = response?.data
            self.jobImage = self.jobDetail!.images ?? []
            self.jobCategory.text = self.jobDetail?.category_name
            self.jobSubcategory.text = self.jobDetail?.subcategory_name
            
            if(Singleton.shared.userInfo.user_id == self.jobDetail?.user_id){
                
                self.postedByName.text = (self.jobDetail?.vendor_name ?? self.jobDetail?.user_name ?? "").formatName()
                
                
                self.userImage.sd_setImage(with: URL(string: self.jobDetail?.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
            }else {
                self.postedByOccupation.text =  "Job Name: " +  (self.jobDetail?.job_name ?? "")
                
                self.postedByName.text = self.jobDetail?.user_name!.formatName()
                
                self.userImage.sd_setImage(with: URL(string: self.jobDetail?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
                
            }
            
            self.address.text = self.jobDetail?.job_address
            self.postedPrice.text = "\(self.jobDetail?.initial_amount ?? 0)"
            self.counterPrice = Int(self.jobDetail?.initial_amount ?? 0)
            self.addWorkerComment.text = self.jobDetail?.comment ?? "Type here"
            self.counterOfferPrice.text = "\(self.jobDetail?.initial_amount ?? 0)"
            self.postedDate.text = self.jobDetail?.job_date
            self.postedTime.text = self.convertTimestampToDate(self.jobDetail?.job_time ?? 0, to: "h:mm a")
            self.jobApproach.text = self.jobDetail?.job_approach
            self.joDesc.text = self.jobDetail?.job_description
            self.workSchedule.text = self.jobDetail?.job_date
            self.mapView.latitude = self.jobDetail?.job_address_latitude ?? 0
            self.mapView.longitude = self.jobDetail?.job_address_longitude ?? 0
            self.mapView.address = self.jobDetail?.job_address ?? ""
            if(self.jobDetail?.is_bid_placed == 1){
                self.addWorkerComment.isUserInteractionEnabled = false
                self.counterOfferLabel.text = "Countered Price"
                self.bidRejectLabel.isHidden = false
                if(self.jobDetail!.my_bid?.owner_status == K_REJECT){
                    self.bidRejectLabel.text = "Bid Rejected"
                }else {
                    self.bidRejectLabel.text = "Bid Placed"
                }
                //self.counterOfferPrice.text = self.jobDetail?.my_bid?.counteroffer_amount
                self.addWorkerComment.text = self.jobDetail?.my_bid?.comment
                self.addWorkerComment.textColor = .black
                self.bidStack.isHidden = true
                self.counterOfferPrice.isUserInteractionEnabled = false
                if(self.jobDetail?.my_bid?.vendor_status == K_CANCEL){
                    self.bidRejectLabel.text = "Rejected by you"
                    self.placeBidView.isHidden = true
                }else if(self.jobDetail?.my_bid?.owner_status == K_REJECT){
                    self.bidRejectLabel.text = "Rejected by owner"
                    self.placeBidView.isHidden = true
                }else {
                    self.placeBidButton.setTitle("Cancel Job", for: .normal)
                    self.placeBidView.isHidden = false
                }
               
            }
            if(self.jobImage.count == 0){
                self.viewPhotos.isHidden = true
            }else {
                self.viewPhotos.isHidden = false
            }
            self.photoCollection.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBAction
    @IBAction func mapFullScreenAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        myVC.latitude = self.jobDetail?.job_address_latitude ?? 0
        myVC.longitude = self.jobDetail?.job_address_longitude ?? 0
        
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func increaseCounterAction(_ sender: Any) {
        self.counterPrice = self.counterPrice + 1000
        self.counterOfferPrice.text = "\(self.counterPrice)"
    }
    
    @IBAction func decreaseCounterAction(_ sender: Any) {
        if(self.counterPrice > 1000){
            self.counterPrice = self.counterPrice - 1000
            self.counterOfferPrice.text = "\(self.counterPrice)"
        }
    }
    
    @IBAction func placeBidAction(_ sender: Any) {
        if(placeBidButton.titleLabel!.text == "Cancel Job"){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
            myVC.image = #imageLiteral(resourceName: "tick")
            
            myVC.okBtnTtl = "Yes"
            myVC.cancelBtnTtl = "No"
            myVC.cancelBtnHidden = false
            myVC.successDelegate = self
            myVC.modalPresentationStyle = .overFullScreen
            myVC.titleLabel = "You want to cancel the offer."
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }else {
            if(self.addWorkerComment.text!.isEmpty || self.addWorkerComment.text == "Type here"){
                Singleton.shared.showToast(text: "Enter your comment")
            }else if(self.counterOfferPrice.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter counter offer")
            }else {
                if((Singleton.shared.userInfo.is_bank_details_added == 0 || Singleton.shared.userInfo.is_bank_details_added == nil) && (isBankdetailAdded == false)){
                    /*
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDetailViewController") as! AccountDetailViewController
                    Singleton.shared.showToast(text: "Please add bank detail before payment.")
         
                    self.navigationController?.pushViewController(myVC, animated: true)
                    */
                }else {
                    ActivityIndicator.show(view: self.view)
                    let param = [
                        "job_id":self.jobDetail?.job_id,
                        "vendor_id":Singleton.shared.userInfo.user_id,
                        "counteroffer_amount":self.counterOfferPrice.text ?? "",
                        "comment":self.addWorkerComment.text ?? ""
                        ] as? [String:Any]
                    SessionManager.shared.methodForApiCalling(url: U_BASE + U_PLACE_BID, method: .post, parameter: param, objectClass: Response.self, requestCode: U_PLACE_BID) { (response) in
                        ActivityIndicator.hide()
                        self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Bid Place Successfully\n Please wait for the owner to accept.", yesTitle: nil, noTitle: nil, isNoHidden: true)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
}

extension ViewJobViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(addWorkerComment.text == "Type here"){
            self.addWorkerComment.text = ""
            self.addWorkerComment.textColor = .black
        }else {
            self.addWorkerComment.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(addWorkerComment.text == ""){
            self.addWorkerComment.text = "Type here"
            self.addWorkerComment.textColor = .lightGray
        }else {
            self.addWorkerComment.textColor = .black
        }
    }
}
