

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.jobTable.delegate = self
        self.jobTable.dataSource = self
        
        switch K_CURRENT_TAB {
            case K_HISTORY_TAB:
                self.jobData = Singleton.shared.receivedHistoryData
                self.getReceivedJob()
            case K_MYBID_TAB:
                self.jobData = Singleton.shared.vendorRejectedBids
                self.getAllBids()
            case K_RUNNING_JOB_TAB:
                self.getRunningJob()
            case K_CURRENT_JOB_TAB:
                self.jobData = Singleton.shared.runningJobData
                self.getRunningJob()
            default:
                return
        }
        
        self.jobTable.reloadData()
    }

    @objc func refresh() {
        refreshControl.endRefreshing()
        
        switch K_CURRENT_TAB {
            case K_HISTORY_TAB:
                 self.getReceivedJob()
            case K_MYBID_TAB:
                self.getAllBids()
            case K_CURRENT_JOB_TAB:
                self.getRunningJob()
            default:
                self.getRunningJob()
        }
        
    }

    func getAllBids(){
          ActivityIndicator.show(view: self.view)
          let url = "\(U_BASE)\(U_GET_ALL_BID)\(Singleton.shared.userInfo.user_id ?? "")&type=REJECTED"
          SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_ALL_BID) {
              self.jobData = $0.data
              Singleton.shared.vendorRejectedBids = $0.data
              
              self.jobTable.reloadData()
              ActivityIndicator.hide()
          }
      }

    func getRunningJob(){
        ActivityIndicator.show(view: self.view)
        let url =  "\(U_BASE)\(U_GET_VENDOR_RUNNING_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) {
            self.jobData = $0.data
            Singleton.shared.runningJobData = $0.data
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getReceivedJob(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_VENDOR_COMPLETED_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_VENDOR_COMPLETED_JOB) {
            self.jobData = $0.data
            Singleton.shared.receivedHistoryData = $0.data
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

extension RunningJobViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.jobData[indexPath.row]
        let isMyJob = Singleton.shared.userInfo.user_id == val.job_vendor_id
        let rating = isMyJob ? val.user_average_rating : val.vendor_average_rating
        let image = isMyJob ? val.user_image : val.vendor_image
        
        cell.userImage.sd_setImage(with: URL(string: image ?? "" ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.jobName.text = val.job_name
        
        /*
         cell.userRating.rating = Double(rating ?? "0")!
         cell.jobPrice.text = "$" + (val.job_amount ?? val.service_amount ?? "\(val.initial_amount ?? 0)" )
        
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.jobDescription.text = val.job_description
        */
        
        /*
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
        */
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(K_CURRENT_TAB == K_MYBID_TAB){
          let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
         myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
        self.navigationController?.pushViewController(myVC, animated: true)
        }else {
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


