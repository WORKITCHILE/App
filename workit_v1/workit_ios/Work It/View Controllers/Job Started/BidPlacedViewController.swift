
//
//  BidPlacedViewController.swift
//  Work It
//
//  Created by qw on 28/02/20.
//  Copyright © 2020 qw. All rights reserved.
//



import UIKit

class BidPlacedViewController: UIViewController {
    
    //IBOUtlets
    @IBOutlet weak var jobTable: UITableView!
    @IBOutlet weak var noJobsFound: UILabel!

    var jobData = [GetJobResponse]()
    var isTopBarHidden = true
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
  
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)
        self.jobTable.delegate = self
        self.jobTable.dataSource = self
    }


    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if(K_CURRENT_TAB == K_HISTORY_TAB || K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            self.noJobsFound.text = "No hay trabajos"
        }else if(K_CURRENT_TAB == K_CURRENT_JOB_TAB){
            self.noJobsFound.text = "No hay ofertas"
        }
        
        switch K_CURRENT_TAB {
            case K_HISTORY_TAB:
                self.jobData = Singleton.shared.postedHistoryData
                self.getPostedJob()
            case K_RUNNING_JOB_TAB:
                self.getRunningJob()
            case K_MYBID_TAB:
                self.jobData = Singleton.shared.vendorAcceptedBids
                self.getAllBids()
            default:
                return
        }
        
        self.jobTable.reloadData()
    }

    @objc func refresh() {
        refreshControl.endRefreshing()
        switch K_CURRENT_TAB {
            case K_HISTORY_TAB:
                self.getPostedJob()
            case K_RUNNING_JOB_TAB:
                self.getRunningJob()
            case K_MYBID_TAB:
                self.getAllBids()
            default:
                return
        }
    }

    func getAllBids(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_ALL_BID)\(Singleton.shared.userInfo.user_id ?? "")&type=POSTED"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_ALL_BID) { 
            self.jobData = $0!.data
            Singleton.shared.vendorAcceptedBids = $0!.data
            self.noJobsFound.isHidden = self.jobData.count != 0
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getPostedJob(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_OWNER_COMPLETED_JOBS)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_COMPLETED_JOBS) { (response) in
            self.jobData = response!.data
            Singleton.shared.postedHistoryData = response!.data
            self.noJobsFound.isHidden = self.jobData.count != 0
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getRunningJob(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_OWNER_RUNNING_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
            self.jobData = response!.data
            self.noJobsFound.isHidden = self.jobData.count != 0
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    //MARK: IBAction
    @IBAction func postJobAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
        self.navigationController?.pushViewController(myVC, animated: true)
    }


}

extension BidPlacedViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView

        let val = self.jobData[indexPath.row]
        cell.jobPrice.text = "$" + "\(val.initial_amount ?? 0)"
        if(Singleton.shared.userInfo.user_id == val.user_id){
            cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.vendor_name ?? Singleton.shared.userInfo.name ?? ""
            cell.userRating.rating = Double(val.vendor_average_rating ?? "0")!

        }else {
            cell.userImage.sd_setImage(with: URL(string: val.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = val.user_name ?? ""
            cell.userRating.rating = Double(val.user_average_rating ?? "0")!

        }
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.jobName.text = val.job_name
        /*
        cell.jobPrice.text = "$" + (val.job_amount ?? val.service_amount ?? val.counteroffer_amount ?? "\(val.initial_amount ?? 0)" ?? "0")
        */
        //cell.totalBids.text = ""
        cell.jobDescription.text = val.job_description
        cell.editJob = {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
            myVC.jobDetail = self.jobData[indexPath.row]
            myVC.isEditJob = true
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((self.jobData[indexPath.row].status == K_ACCEPT || self.jobData[indexPath.row].owner_status == K_ACCEPT) && K_CURRENT_USER == K_WANT_JOB){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
            myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
            myVC.isNavigateFromtab = K_CURRENT_TAB
            self.navigationController?.pushViewController(myVC, animated: true)
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
            myVC.isNavigateFromtab = K_CURRENT_TAB
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
}



