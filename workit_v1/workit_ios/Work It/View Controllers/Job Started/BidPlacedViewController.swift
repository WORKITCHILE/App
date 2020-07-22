
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
    @IBOutlet weak var viewTopBar: View!
    @IBOutlet weak var jobTable: UITableView!
    @IBOutlet weak var noJobsFound: UILabel!

    var jobData = [GetJobResponse]()
    var isTopBarHidden = true
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewTopBar.isHidden = isTopBarHidden
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)

    }


    override func viewWillAppear(_ animated: Bool) {

    }

    override func viewDidAppear(_ animated: Bool) {
        if(K_CURRENT_TAB == K_HISTORY_TAB || K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            self.noJobsFound.text = "No Jobs Founds"
        }else if(K_CURRENT_TAB == K_CURRENT_JOB_TAB){
            self.noJobsFound.text = "No Bids Placed"
        }
        if(K_CURRENT_TAB == K_HISTORY_TAB){
            if(Singleton.shared.postedHistoryData.count == 0){
                self.getPostedJob()
            }else {
                self.jobTable.delegate = self
                self.jobTable.dataSource = self
                self.jobData = Singleton.shared.postedHistoryData
                self.jobTable.reloadData()
            }
        }else if(K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            self.getRunningJob()
        }else if(K_CURRENT_TAB == K_MYBID_TAB) {
            if(Singleton.shared.vendorAcceptedBids.count == 0){
                self.getAllBids()
            }else {
                self.jobTable.delegate = self
                self.jobTable.dataSource = self
                self.jobData = Singleton.shared.vendorAcceptedBids
                self.jobTable.reloadData()
            }
        }
    }

    @objc func refresh() {
        refreshControl.endRefreshing()
        if(K_CURRENT_TAB == K_HISTORY_TAB){
            self.getPostedJob()
        }else if(K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            getRunningJob()
        }else if(K_CURRENT_TAB == K_MYBID_TAB) {
            self.getAllBids()
        }
    }

    func getAllBids(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_ALL_BID + (Singleton.shared.userInfo.user_id ?? "") + "&type=POSTED", method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_ALL_BID) { (response) in
            self.jobData = response.data
            Singleton.shared.vendorAcceptedBids = response.data
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getPostedJob(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_OWNER_COMPLETED_JOBS + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_COMPLETED_JOBS) { (response) in
            self.jobData = response.data
            Singleton.shared.postedHistoryData = response.data
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    func getRunningJob(){
        ActivityIndicator.show(view: self.view)
        var url = U_BASE + U_GET_OWNER_RUNNING_JOB + (Singleton.shared.userInfo.user_id ?? "")
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
            self.jobData = response.data
            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            self.jobTable.reloadData()
            ActivityIndicator.hide()
        }
    }

    //MARK: IBAction
    @IBAction func postJobAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
        //self.storyboard?.instantiateViewController(identifier: "PostJobViewController") as! PostJobViewController
        self.navigationController?.pushViewController(myVC, animated: true)
    }

    @IBAction func sideMenuAction(_ sender: Any) {
        self.back()
    }

}

extension BidPlacedViewController: UITableViewDelegate,UITableViewDataSource {
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
        cell.jobPrice.text = "$" + (val.job_amount ?? val.service_amount ?? val.counteroffer_amount ?? "\(val.initial_amount ?? 0)" ?? "0")
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
        if (isHistory == false){
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
}



