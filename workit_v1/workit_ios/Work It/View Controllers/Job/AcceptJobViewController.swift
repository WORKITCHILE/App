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
            let param : [String:Any] = [
                "user_id":self.jobData?.user_id,
                "job_id":self.jobData?.job_id,
                "job_amount": self.bidDetail?.counteroffer_amount,
                "payment_option": paymentOptionDetail["id"]! == nil ? "WALLET":"BANK",
                "bank_detail_id": paymentOptionDetail["id"] as? String,
                "transaction_id":paymentOptionDetail["id"]! == nil ? "W\(myTime)":"B\(myTime)",
                "vendor_name": self.bidDetail?.vendor_name ?? self.jobData?.vendor_name ?? ""
            ]
            
            DispatchQueue.global(qos: .background).async {
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_OWNER_JOB_PAYMENT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_OWNER_JOB_PAYMENT) { (response) in
                    ActivityIndicator.hide()
                    Singleton.shared.runningJobData = []
                    self.callJobAPI(action: K_ACCEPT)
                }
            }
        } else if(isPopupForPaymentSelection == 3){
            
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
            
        } else {
            ActivityIndicator.show(view: self.view)
            let param: [String:Any] = [
                "job_id":self.jobData?.job_id,
                "user_id":Singleton.shared.userInfo.user_id
            ]
            
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
    @IBOutlet weak var viewReviewButton: UIButton!
    @IBOutlet weak var workerDescription: DesignableUILabel!
    @IBOutlet weak var offerValue: DesignableUILabel!
    @IBOutlet weak var occupation: DesignableUILabel!
    @IBOutlet weak var rateUserButton: UIButton!
   
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var workerName: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel  : UILabel!
    @IBOutlet weak var jobStatus  : UILabel!
    @IBOutlet weak var userRating : CosmosView!
    @IBOutlet weak var viewForAccept: UIView!
    @IBOutlet weak var viewForReject: UIView!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
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
    var jobDataProperties : [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomSectionHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        
        getJobDetail()
    }
    
    func getJobDetail(){
        ActivityIndicator.show(view: self.view)
        let path = K_CURRENT_USER == K_POST_JOB ? U_GET_SINGLE_JOB_OWNER : U_GET_SINGLE_JOB_VENDOR
        let url = "\(U_BASE)\(path)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(self.jobId ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) {
            self.jobData = $0?.data
            self.populateView()
            self.manageView()
            self.tableView.reloadData()
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
    
    func populateView(){
        
      
        
        let workDetails : [String : Any] = [
            "title":"Detalles de trabajo",
            "data": [
                [
                    "title": "Nombre del trabajo",
                    "type": "description",
                    "value" : self.jobData?.job_name!
                ],
                [
                    "title": "Publicado por",
                    "type": "description",
                    "value" : self.jobData?.user_name!
                ],
                [
                    "title": "Trabajo acaptado por",
                    "type": "description",
                    "value" : self.jobData?.vendor_name!
                ],
                [
                    "title": "Enfoque",
                    "type": "description",
                    "value" : self.jobData?.job_approach!
                ],
                [
                    "title": "Categoria",
                    "type": "description",
                    "value" : self.jobData?.category_name!
                ],
                [
                    "title": "Subcategoria",
                    "type": "description",
                    "value" : self.jobData?.subcategory_name!
                ]
            ]
        ]
        

        
        let calendarDetails : [String : Any] = [
            "title":"Calendario",
            "data": [
                [
                    "title": "Publicado",
                    "type": "description",
                    "value" : self.convertTimestampToDate(self.jobData?.created_at ?? 0, to: "dd.MM.yyyy")
                ],
                [
                    "title": "Fecha de inicio",
                    "type": "description",
                    "value" : self.jobData?.job_date ?? ""
                ],
                [
                    "title": "Tiempo",
                    "type": "description",
                    "value" : self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
                ]
            ]
        ]
        
        let descriptionDetails : [String : Any] = [
            "title":"Descripción del trabajo",
            "data": [
                [
                    "title": self.jobData?.job_description ?? "" ,
                    "type": "text",
                    "value" : ""
                ]
            ]
        ]
        
        let addressDetails : [String : Any] = [
            "title":"Ubicación",
            "data": [
                [
                    "title": self.jobData?.job_address ?? "",
                    "type": "text",
                    "value" : "" ]
            ]
        ]
        
        self.jobDataProperties.append(workDetails)
        self.jobDataProperties.append(calendarDetails)
        self.jobDataProperties.append(descriptionDetails)
        self.jobDataProperties.append(addressDetails)
        
        /*
        
        self.jobDataProperties.append(["title": "Nombre del trabajo", "value" : self.jobData?.job_name ?? "" ])
        */
        
        if(self.isEvaluationScreen){

            let addressDetails : [String : Any] = [
                "title":"Comentario",
                "data": [
                    [
                        "title": evaluationText,
                        "type":"text",
                        "value" :  ""
                    ]
                ]
            ]
            
            self.userRating.rating = Double(self.evaluationRating)!
        }

        
        let isUserId = Singleton.shared.userInfo.user_id == self.jobData?.user_id
        let userImage = (jobData?.status == K_POSTED ||  isUserId) ? self.jobData?.vendor_image : self.jobData?.user_image
        self.workerImage.sd_setImage(with: URL(string: userImage!),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
    }
    
    func manageView(){
        if(self.isVendorCancelJob){
            self.handleRepostJob()
        }
        
        switch jobData?.status {
            case K_POSTED:
                if(K_CURRENT_USER == K_POST_JOB){
                    self.viewForAccept.isHidden = bidDetail?.owner_status == "REJECTED"
                    
                    if(bidDetail?.owner_status == "REJECTED"){
                        self.jobStatus.text = "Oferta rechazada por ti"
                        self.viewForReject.isHidden = true
                    }else{
                        self.viewForAccept.isHidden = false
                        self.viewForReject.isHidden = false
                        //self.viewReviewButton.isHidden = false
                    }
                }else if(K_CURRENT_USER == K_WANT_JOB){
                    //self.viewReviewButton.isHidden = true
                    if(bidDetail?.owner_status == "REJECTED"){
                        self.viewForAccept.isHidden = true
                        self.jobStatus.text = "Oferta Rechazada"
                        self.viewForReject.isHidden = true
                    }else if(bidDetail?.owner_status == "ACCEPTED"){
                        self.viewForAccept.isHidden = true
                        self.jobStatus.text = "Oferta Aceptada"
                        self.viewForReject.isHidden = true
                    }
                }
            case K_ACCEPT:
                self.jobStatus.text = "Trabajo aceptado"
                self.viewForAccept.isHidden = true
                
                if(K_CURRENT_USER == K_POST_JOB){
                    self.viewForReject.isHidden = false
                    self.viewReviewButton.isHidden = false
                    self.rejectButton.isUserInteractionEnabled = true
                    self.rejectButton.setTitle("Cancel Job", for: .normal)
                }else {
                    self.viewForReject.isHidden = true
                }
            
            case K_START:
                
                self.viewReviewButton.isHidden = false
                self.viewForAccept.isHidden = false
                
                self.jobStatus.text = self.jobData?.started_by == K_WANT_JOB ? "Confirma para comenzar" : "Trabajo iniciado"
                
                if(self.jobData?.started_by == K_WANT_JOB){
                    self.acceptButton.setTitle("Confirm", for: .normal)
                    self.viewForReject.isHidden = false
                    self.rejectButton.setTitle("Cancel Job", for: .normal)
                }else if(self.jobData?.started_by == K_POST_JOB){
                    self.acceptButton.setTitle("Message", for: .normal)
                    self.viewForReject.isHidden = true
                }else {
                    self.acceptButton.setTitle("Message", for: .normal)
                    self.viewForReject.isHidden = true
                }
            case K_FINISH:
                self.viewReviewButton.isHidden = false
                self.viewForAccept.isHidden = true
                self.viewForReject.isHidden = false
                self.rejectButton.setTitle("Release Payment", for: .normal)
                self.jobStatus.text = "Job finished, release payment"
            case K_PAID:
                //self.rateUserButton.isHidden = !((self.jobData?.owner_rated == 0) && (K_CURRENT_USER == K_POST_JOB))
                //(self.viewReviewButton.isHidden = true
                self.viewForAccept.isHidden = true
                self.viewForReject.isHidden = true
                self.jobStatus.text = "Trabajo finalizado"
            case K_CANCEL:
                //self.viewReviewButton.isHidden = true
                self.viewForAccept.isHidden = true
                self.viewForReject.isHidden = true
                if((self.jobData?.canceled_by == K_WANT_JOB) && ((self.jobData?.is_reposted ?? 0) == 0) && (Singleton.shared.userInfo.user_id == self.jobData?.user_id)){
                    //self.rateUserButton.setTitle("Repost Job", for: .normal)
                    //self.rateUserButton.isHidden = false
                }
                self.jobStatus.text = "Trabajo Cancelado"
            case .none:
                break
            case .some(_):
                break
            
        }
        

        
        if(jobData?.status == K_POSTED){
            //self.viewReviewButton.isHidden = false
            self.workerImage.sd_setImage(with: URL(string: self.jobData?.vendor_image ?? self.bidDetail?.vendor_image ??
                self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            let userName = self.jobData?.vendor_name ?? self.bidDetail?.vendor_name ?? self.jobData?.user_name ?? ""
            self.workerName.text = userName.formatName()
            
            //self.offerValue.text = "$" + (self.jobData?.my_bid?.counteroffer_amount ?? self.jobData?.counteroffer_amount ?? self.bidDetail?.counteroffer_amount ?? "0")
            //self.occupation.text =  self.jobData?.vendor_occupation ?? self.bidDetail?.vendor_occupation ?? self.jobData?.user_occupation ?? ""
            //self.workerDescription.text =  self.jobData?.comment ?? self.bidDetail?.comment ?? self.jobData?.job_description ?? ""
            //self.userRating.rating = Double(self.jobData?.vendor_average_rating ?? self.bidDetail?.vendor_average_rating ?? self.jobData?.user_average_rating ?? "0")!
            
        }else {
           // self.viewReviewButton.isHidden = true
            if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
                self.workerImage.sd_setImage(with: URL(string: self.jobData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                self.userRating.rating = Double(self.jobData?.vendor_average_rating ?? "0")!
                self.workerName.text = (self.jobData?.vendor_name ?? self.jobData?.user_name ?? "").formatName()
                
                //self.offerValue.text = "$" + (self.jobData?.service_amount  ?? self.bidDetail?.counteroffer_amount ?? "0")
                
                //self.occupation.text = self.jobData?.vendor_occupation   ?? self.jobData?.user_occupation
                //self.workerDescription.text = self.jobData?.comment ?? ""
            }else {
                self.workerImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                self.userRating.rating = Double(self.jobData?.user_average_rating ?? "0")!
                self.workerName.text =  self.jobData?.user_name!.formatName()
                //self.offerValue.text = "$" + (self.jobData?.service_amount  ?? self.bidDetail?.counteroffer_amount ?? "0")
                
                //self.occupation.text = self.jobData?.user_occupation ?? ""
                //self.workerDescription.text = self.jobData?.comment ?? self.bidDetail?.comment ?? ""
            }
        }
        
      
       
        //self.photoCollection.reloadData()
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
      
        if((notif.userInfo?["isWallet"] as? Int) == 1){
            self.paymentOptionDetail = ["id": nil, "isWallet": 1]
            myVC.titleLabel = "Are you sure you want to pay from wallet for this job?"
        }else{
            myVC.titleLabel = "Are you sure you want to pay from \(notif.userInfo?["bank"] as! String) for this job?"
            let accountId = notif.userInfo?["id"] as! String
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
        let param : [String:Any] = [
            "job_id": jobData?.job_id,
            "bid_id": bidDetail?.bid_id,
            "status": action
            ]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_BID_ACTION, method: .post, parameter: param, objectClass: Response.self, requestCode: U_BID_ACTION) { (response) in
            Singleton.shared.jobData = []
            
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
        
        let param:  [String:Any] = ["job_id": jobData?.job_id!]
        
        let url = "\(U_BASE)\(U_RELEASE_JOB_PAYMENT)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_RELEASE_JOB_PAYMENT) { (response) in
            
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

extension AcceptJobViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         let val : [String: String] = (jobDataProperties[indexPath.section]["data"] as! Array<Any>)[indexPath.row] as! [String : String]
        return val["type"] == "text" ? 115.0 : 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.jobDataProperties.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.jobDataProperties[section]["data"] as! Array<Any> ).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          
        let sectionData = self.jobDataProperties[section]
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! CustomSectionHeader
        header.titleLabel.text = (sectionData["title"] as! String).uppercased()
           
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let val : [String: String] = (jobDataProperties[indexPath.section]["data"] as! Array<Any>)[indexPath.row] as! [String : String]
        let cellIdentifier = val["type"] == "text" ? "DataJobViewCellText" : "DataJobViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DataJobViewCell
       

        cell.title.text = val["title"]?.uppercased()
        if  val["type"] == "description"{
            cell.subtitle.text = val["value"]
        }

        return cell
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
      
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
}
