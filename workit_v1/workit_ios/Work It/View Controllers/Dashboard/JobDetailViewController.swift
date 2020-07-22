//
//  JobDetailViewController.swift
//  Work It
//
//  Created by qw on 08/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController, SuccessPopup{
    func yesAction() {
        ActivityIndicator.show(view: self.view)
           let param = [
               "job_id":self.jobData?.job_id,
               "user_id":Singleton.shared.userInfo.user_id
               ] as? [String:Any]
           SessionManager.shared.methodForApiCalling(url: U_BASE + U_CANCEL_JOB, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
               ActivityIndicator.hide()
               self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Job Cancelled Successfully", yesTitle: nil, noTitle: nil, isNoHidden: true)
               Singleton.shared.jobData = []
            ActivityIndicator.hide()
               self.navigationController?.popViewController(animated: true)
               
           }
       }
    
    //MARK: IBOutlets
    @IBOutlet weak var workName: DesignableUILabel!
    @IBOutlet weak var userName: DesignableUILabel!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var jobTime: DesignableUILabel!
    @IBOutlet weak var price: DesignableUILabel!
    @IBOutlet weak var jobDate: DesignableUILabel!
    @IBOutlet weak var addresss: DesignableUILabel!
    @IBOutlet weak var jobDescription: DesignableUILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var viewForPhoto: UIView!
    //@IBOutlet weak var estimatedDays: DesignableUILabel!
    @IBOutlet weak var scheduleDate: DesignableUILabel!
    @IBOutlet weak var viewForbid: UIView!
    @IBOutlet weak var viewCancelJob: UIView!
    @IBOutlet weak var bidTable: ContentSizedTableView!
    @IBOutlet weak var jobApproach: DesignableUILabel!
    
    @IBOutlet weak var viewPhotos: UIView!
    
    @IBOutlet weak var jobCategory: DesignableUILabel!
    @IBOutlet weak var jobSubcategory: DesignableUILabel!
    
    @IBOutlet weak var viewAwardedTo: UIView!
    @IBOutlet weak var awardedToName: DesignableUILabel!
    
    
    var jobId: String?
    var jobData:GetJobResponse?
    var jobImage = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getJobDetail()
    }
    
    func getJobDetail(){
        ActivityIndicator.show(view: self.view)
        let url = U_BASE + U_GET_SINGLE_JOB_OWNER + (Singleton.shared.userInfo.user_id ?? "") + "&job_id=\(self.jobId ?? "")"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { (response) in
            self.jobData = response.data
            if(((self.jobData?.bids?.count ?? 0) > 0) && (self.jobData?.vendor_name == nil)){
                self.viewForbid.isHidden = false
                self.bidTable.reloadData()
            }
            self.manageView()
            ActivityIndicator.hide()
        }
    }
    
    func manageView(){
       
        self.workName.text = "Job Name: " + (self.jobData?.job_name ?? "")
        self.jobCategory.text = self.jobData?.category_name
        self.jobSubcategory.text = self.jobData?.subcategory_name
        
        if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
           self.userName.text = (self.jobData?.user_name ?? "").formatName(name:self.jobData?.user_name ?? "")
            
           self.userImage.sd_setImage(with: URL(string: Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else {
            self.userName.text = (self.jobData?.user_name ?? "").formatName(name:self.jobData?.user_name ?? "")
                       self.userImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }
        
        if(self.jobData?.vendor_name != nil){
            self.viewAwardedTo.isHidden = false
            self.awardedToName.text = self.jobData?.vendor_name ?? ""
        }else {
            self.viewAwardedTo.isHidden = true
        }
        
        self.jobTime.text = self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobDate.text = self.jobData?.job_date
        self.jobImage = self.jobData!.images ?? []
        if(self.jobImage.count > 0){
            self.viewForPhoto.isHidden = false
           
        }
        if(self.jobData?.bids?.count == 0){
            self.viewCancelJob.isHidden = false
        }else {
             self.viewCancelJob.isHidden = true
        }
        if(self.jobImage.count == 0){
            self.viewPhotos.isHidden = true
        }else {
            self.viewPhotos.isHidden = false
        }
        self.photoCollection.reloadData()
        self.jobApproach.text = self.jobData?.job_approach
        self.scheduleDate.text = self.jobData?.job_date
        self.addresss.text = self.jobData?.job_address
        self.jobDescription.text = self.jobData?.job_description ?? "N/A"
        self.price.text = "$" + "\(self.jobData?.initial_amount ?? 0)"
    }
    
    func cancelJob(){
          let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
          
          myVC.image = #imageLiteral(resourceName: "information-button copy")
          myVC.titleLabel = "Are you sure you want to cancel the job?"
          myVC.okBtnTtl = "Yes"
          myVC.cancelBtnTtl = "No"
          myVC.cancelBtnHidden = false
          myVC.successDelegate = self
          myVC.modalPresentationStyle = .overFullScreen
          self.navigationController?.present(myVC, animated: true, completion: nil)
      }
    
    //MARK: IBActions
    @IBAction func backActions(_ sender: Any) {
        self.back()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.cancelJob()
    }
    
}

extension JobDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width * 0.8, height:95)
//    }
}

extension JobDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.jobData?.bids?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidTableView") as! BidTableView
        let val = self.jobData?.bids?[indexPath.row]
        cell.workerImage.sd_setImage(with: URL(string: val?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.workerName.text = val?.vendor_name
        cell.workerBid.text = "Countered Bid: $" +  (val?.counteroffer_amount ?? "0")
        cell.status.text = "User Occupation: " + (val?.vendor_occupation ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
        myVC.jobId = self.jobData?.job_id
        myVC.bidDetail = self.jobData?.bids?[indexPath.row]
        self.navigationController?.pushViewController(myVC, animated: true)
    }

}


class BidTableView: UITableViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var workerName: DesignableUILabel!
    @IBOutlet weak var workerBid: DesignableUILabel!
    @IBOutlet weak var status: DesignableUILabel!
}
