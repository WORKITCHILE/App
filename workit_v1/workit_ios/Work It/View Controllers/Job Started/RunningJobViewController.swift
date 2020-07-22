

//
//  RunningJobViewController.swift
//  Work It
//
//  Created by qw on 28/02/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class RunningJobViewController: UIViewController {

    //IBOUtlets
    @IBOutlet weak var addJobStack: UIStackView!
    @IBOutlet weak var viewTopBar: View!
    @IBOutlet weak var jobTable: UITableView!
    @IBOutlet weak var noJobsFound: UILabel!

    var jobData = [GetJobResponse]()
    var refreshControl = UIRefreshControl()
    var isTopBarHidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)
    }

    override func viewDidAppear(_ animated: Bool) {
        if(K_CURRENT_TAB == K_HISTORY_TAB){
            if(Singleton.shared.receivedHistoryData.count == 0){
                self.getReceivedJob()
            }else {
                self.jobTable.delegate = self
                self.jobTable.dataSource = self
                self.jobData = Singleton.shared.receivedHistoryData
                self.jobTable.reloadData()
            }
            self.viewTopBar.isHidden = true
        }else if(K_CURRENT_TAB == K_MYBID_TAB) {
            self.viewTopBar.isHidden = true
            if(Singleton.shared.vendorRejectedBids.count == 0){
                self.getAllBids()
            }else {
                self.jobTable.delegate = self
                self.jobTable.dataSource = self
                self.jobData = Singleton.shared.vendorRejectedBids
                self.jobTable.reloadData()
            }
        }else if(K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            self.viewTopBar.isHidden = true
            self.getRunningJob()
        }else if(K_CURRENT_TAB == K_CURRENT_JOB_TAB) {
            if(Singleton.shared.runningJobData.count == 0){
                self.getRunningJob()
            }else {
                self.jobTable.delegate = self
                self.jobTable.dataSource = self
                self.jobData = Singleton.shared.runningJobData
                self.jobTable.reloadData()
            }
        }
    }

    @objc func refresh() {
        refreshControl.endRefreshing()
        if(K_CURRENT_TAB == K_HISTORY_TAB){
            self.getReceivedJob()
        }else if(K_CURRENT_TAB == K_MYBID_TAB){
            getAllBids()
        }else if(K_CURRENT_TAB == K_CURRENT_JOB_TAB) {
            self.getRunningJob()
        }else {
            self.getRunningJob()
        }
    }

    func getAllBids(){
          ActivityIndicator.show(view: self.view)
          SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_ALL_BID + (Singleton.shared.userInfo.user_id ?? "") + "&type=REJECTED", method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_ALL_BID) { (response) in
              self.jobData = response.data
              Singleton.shared.vendorRejectedBids = response.data
              self.jobTable.delegate = self
              self.jobTable.dataSource = self
              self.jobTable.reloadData()
              ActivityIndicator.hide()
          }
      }

    func getRunningJob(){
        ActivityIndicator.show(view: self.view)
        var url =  U_BASE + U_GET_VENDOR_RUNNING_JOB + (Singleton.shared.userInfo.user_id ?? "")
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
            self.jobData = response.data
            Singleton.shared.runningJobData = response.data
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getReceivedJob(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_VENDOR_COMPLETED_JOB + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_VENDOR_COMPLETED_JOB) { (response) in
            self.jobData = response.data
            Singleton.shared.receivedHistoryData = response.data
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    //MARK: IBAction
    @IBAction func postJobAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
        self.navigationController?.pushViewController(myVC, animated: true)
    }

    @IBAction func sideMenuAction(_ sender: Any) {
        self.back()
    }

}

extension RunningJobViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.jobData.count == 0){
            self.noJobsFound.isHidden = false
        }else {
            self.noJobsFound.isHidden = true
        }
        return self.jobData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.jobData[indexPath.row]
        cell.jobPrice.text = "$" + (val.job_amount ?? val.service_amount ?? "\(val.initial_amount ?? 0)" ?? "")
        cell.jobName.text = val.job_name
        if(Singleton.shared.userInfo.user_id == val.job_vendor_id){
            cell.userImage.sd_setImage(with: URL(string: val.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                   cell.userName.text = (val.user_name ?? "").formatName(name:val.user_name ?? "")
            cell.userRating.rating = Double(val.user_average_rating ?? "0")!
        }else {
            cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = (val.vendor_name ?? Singleton.shared.userInfo.name ?? "").formatName(name:val.vendor_name ?? Singleton.shared.userInfo.name ?? "")
            cell.userRating.rating = Double(val.vendor_average_rating ?? "0")!
        }
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        //cell.totalBids.text = ""
        cell.jobDescription.text = val.job_description
        cell.editJob = {
            let alert = UIAlertController(title: "Edit job", message: "Are you sure?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (val) in
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
                myVC.jobDetail = self.jobData[indexPath.row]
                myVC.isEditJob = true
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            let noAction = UIAlertAction(title: "No", style: .default) { (val) in
                self.dismiss(animated: true, completion: nil)
            }

            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(K_CURRENT_TAB == K_MYBID_TAB){
          let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
         myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
        self.navigationController?.pushViewController(myVC, animated: true)
        }else {
        if (isHistory == false){
            if(K_CURRENT_USER == K_POST_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
//                if(self.jobData[indexPath.row].canceled_by == K_WANT_JOB){
//                    myVC.isVendorCancelJob = true
//                }
                myVC.isNavigateFromtab = K_CURRENT_TAB
                self.navigationController?.pushViewController(myVC, animated: true)
            }else if(K_CURRENT_USER == K_WANT_JOB){
                if(K_CURRENT_TAB == K_HISTORY_TAB){
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                    myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
                    myVC.isNavigateFromtab = K_CURRENT_TAB
                    self.navigationController?.pushViewController(myVC, animated: true)
                }else {
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                    myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
                    myVC.isNavigateFromtab = K_CURRENT_TAB
                    self.navigationController?.pushViewController(myVC, animated: true)
                }

            }
        }
        }
    }
}


