//
//  PostedJobViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Cosmos
import Lottie
    
class PostedJobViewController: UIViewController {
        //IBOUtlets
        @IBOutlet weak var addJobStack: UIView!
        @IBOutlet weak var jobTable: UITableView!
        @IBOutlet weak var noJobsFound: UIView!
        
        var jobData = [GetJobResponse]()
        let refreshControl = UIRefreshControl()
        var selectedEditIntdex = 0
    
    @IBOutlet weak var animation: AnimationView?
    

        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let number = Int.random(in: 1...6)
            
            let starAnimation = Animation.named("home_\(number)")
            animation!.animation = starAnimation
            animation?.loopMode = .loop
            

            self.jobTable.delegate = self
            self.jobTable.dataSource = self
            
            refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
            jobTable.tableFooterView = UIView()
            jobTable.addSubview(refreshControl)

        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            animation?.play()
            if(Singleton.shared.jobData.count == 0){
                self.getJobData()
            } else {
                self.jobData = Singleton.shared.jobData
                self.addJobStack.isHidden = K_CURRENT_USER != K_POST_JOB
                self.noJobsFound.isHidden = true
                self.jobTable.reloadData()
            }
        }

        
        @objc func refresh() {
            refreshControl.endRefreshing()
            getJobData()
        }
        
        func getJobData(){
            ActivityIndicator.show(view: self.view)
            let url = "\(U_BASE)\(U_GET_OWNER_POSTED_JOBS)\(Singleton.shared.userInfo.user_id ?? "")"
            SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
                self.jobData = response.data
                Singleton.shared.jobData = response.data
                self.noJobsFound.isHidden = self.jobData.count != 0
                self.addJobStack.isHidden = K_CURRENT_USER == K_POST_JOB && self.jobData.count == 0
               
                self.jobTable.reloadData()
                ActivityIndicator.hide()
            }
        }
        
    }
    
    extension PostedJobViewController: UITableViewDelegate,UITableViewDataSource {
     
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.jobData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
            let val = self.jobData[indexPath.row]
            cell.jobPrice.text = "$" + "\(val.initial_amount ?? 0)"
            cell.jobName.text = val.job_name
            cell.jobDate.text = val.job_date
            cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.totalBids.text = "\(val.bid_count ?? 0)"
            cell.editJob = {
               
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
               myVC.jobDetail = self.jobData[self.selectedEditIntdex]
               myVC.isEditJob = true
               self.selectedEditIntdex = 0
                self.present(myVC, animated: true, completion: nil)
                
                
            }
            return cell
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detail" {
                let myVC = segue.destination as! JobDetailViewController
                myVC.jobId = self.jobData[self.jobTable.indexPathForSelectedRow!.row].job_id
            }
        }
        
    }
    
    
class JobTableView: UITableViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobDescription: UILabel!
    @IBOutlet weak var jobName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var totalBids: UILabel!
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
