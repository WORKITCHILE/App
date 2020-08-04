    //
    //  PostedJobViewController.swift
    //  Work It
    //
    //  Created by qw on 04/01/20.
    //  Copyright © 2020 qw. All rights reserved.
    //
    
    import UIKit
    import Cosmos
    
    var isTopbarHidden = false
    var isHistory = false
    
    
    class PostedJobViewController: UIViewController {
        //IBOUtlets
        @IBOutlet weak var addJobStack: UIStackView!
        @IBOutlet weak var viewTopBar: View!
        @IBOutlet weak var jobTable: UITableView!
        
        @IBOutlet weak var noJobsFound: UIView!
        
        var jobData = [GetJobResponse]()
        var refreshControl = UIRefreshControl()
        var selectedEditIntdex = Int()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
            jobTable.tableFooterView = UIView()
            jobTable.addSubview(refreshControl)
            
            //        if(K_CURRENT_USER == K_WANT_JOB){
            //            self.addJobStack.isHidden = true
            //        }else{
            //            self.addJobStack.isHidden = false
            //        }
            //self.viewTopBar.isHidden = isTopbarHidden
            //        if(isHistory){
            //            self.addJobStack.isHidden = true
            //        }else{
            //            self.addJobStack.isHidden = false
            //        }
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            if(Singleton.shared.jobData.count == 0){
                self.getJobData()
            }else {
                self.jobData = Singleton.shared.jobData
                if(K_CURRENT_USER == K_POST_JOB){
                    self.addJobStack.isHidden = false
                }
                self.noJobsFound.isHidden = true
                self.jobTable.reloadData()
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            isTopbarHidden = false
            isHistory = false
        }
        
        @objc func refresh() {
            refreshControl.endRefreshing()
            getJobData()
        }
        
        func getJobData(){
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_OWNER_POSTED_JOBS + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
                self.jobData = response.data
                Singleton.shared.jobData = response.data
                if(self.jobData.count == 0){
                    if(K_CURRENT_USER == K_POST_JOB){
                        self.addJobStack.isHidden = true
                    }
                    self.noJobsFound.isHidden = false
                }else {
                    if(K_CURRENT_USER == K_POST_JOB){
                        self.addJobStack.isHidden = false
                    }
                    self.noJobsFound.isHidden = true
                }
                self.jobTable.reloadData()
                ActivityIndicator.hide()
            }
        }
        
        @IBAction func sideMenuAction(_ sender: Any) {
            self.menu()
        }
        
    }
    
    extension PostedJobViewController: UITableViewDelegate,UITableViewDataSource, SuccessPopup {
        func yesAction() {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
            myVC.jobDetail = self.jobData[self.selectedEditIntdex]
            myVC.isEditJob = true
            self.selectedEditIntdex = 0
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.jobData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
            cell.editView.isHidden = self.addJobStack.isHidden
            let val = self.jobData[indexPath.row]
            cell.jobPrice.text = "$" + "\(val.initial_amount ?? 0)"
            cell.jobName.text = val.job_name
           // if(Singleton.shared.userInfo.user_id == val.job_vendor_id){
                
                cell.userImage.sd_setImage(with: URL(string: val.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            
            cell.userName.text = (val.user_name ?? "").formatName(name:val.user_name ?? "")
//            }else {
//                cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
//                cell.userName.text =  val.vendor_name ?? Singleton.shared.userInfo.name ?? ""
//
//            }
            if(val.vendor_name == nil){
                cell.editView.isHidden = false
            }else {
                cell.editView.isHidden = true
            }
            cell.jobDate.text = val.job_date
            cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.totalBids.text = "Bid(s): \(val.bid_count ?? 0)"
            cell.jobDescription.text = val.job_description
            cell.editJob = {
                self.selectedEditIntdex =  indexPath.row
                
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
                myVC.image = #imageLiteral(resourceName: "information-button copy")
                myVC.titleLabel = "Are you sure you want to Edit job?"
                myVC.okBtnTtl = "Yes"
                myVC.cancelBtnTtl = "No"
                myVC.cancelBtnHidden = false
                myVC.successDelegate = self
                myVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(myVC, animated: true, completion: nil)
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if (isHistory == false){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
                myVC.jobId = self.jobData[indexPath.row].job_id
                self.navigationController?.pushViewController(myVC, animated: true)
            }
        }
    }
    
    
    class JobTableView: UITableViewCell {
        //MARK: IBOutlets
        @IBOutlet weak var editView: View!
        @IBOutlet weak var userImage: ImageView!
        @IBOutlet weak var jobPrice: DesignableUILabel!
        @IBOutlet weak var jobDescription: DesignableUILabel!
        @IBOutlet weak var jobName: DesignableUILabel!
        @IBOutlet weak var userName: DesignableUILabel!
        @IBOutlet weak var jobTime: DesignableUILabel!
        @IBOutlet weak var jobDate: DesignableUILabel!
        @IBOutlet weak var totalBids: DesignableUILabel!
        @IBOutlet weak var userRating: CosmosView!
        
        @IBOutlet weak var viewForEdit: View!
        
        var editJob:(()-> Void)? = nil
        
        //MARK: IBActions
        @IBAction func editAction(_ sender: Any) {
            if let editButton = self.editJob {
                editButton()
            }
        }
        
    }
