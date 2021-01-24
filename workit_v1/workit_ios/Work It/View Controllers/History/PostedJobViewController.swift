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
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var animationW: NSLayoutConstraint!
    @IBOutlet weak var animationH: NSLayoutConstraint!
    @IBOutlet weak var header : UIView!
    
    
    var jobData = [GetJobResponse]()
    let refreshControl = UIRefreshControl()
    var selectedEditIntdex = 0
    
    @IBOutlet weak var animation: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        let starAnimation = Animation.named("main_home")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        animation?.clipsToBounds = true
        animation?.contentMode = .scaleAspectFill
        

        self.jobTable.delegate = self
        self.jobTable.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)

        if(self.view.frame.size.height == 667.0){
            self.topHeight.constant = 200
            self.animationW.constant = 210
            self.animationH.constant = 210
            self.header.frame = CGRect(x: self.header.frame.origin.y, y: self.header.frame.origin.y, width: self.header.frame.size.width, height: 157.0)
        
        } else if(self.view.frame.size.height == 736.0){
            self.topHeight.constant = 200
            self.animationW.constant = 230
            self.animationH.constant = 230
        }
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
        
    }
    
    override func viewDidAppear(_ aniated: Bool){
        super.viewDidAppear(true)
        
       
        self.getJobData()
    }

        
    @objc func refresh() {
        refreshControl.endRefreshing()
        getJobData()
    }
        
    func getJobData(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_OWNER_POSTED_JOBS)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_OWNER_POSTED_JOBS) { (response) in
            
            if(response != nil){
                self.jobData = response!.data
                Singleton.shared.jobData = response!.data
            }
            self.noJobsFound.isHidden = self.jobData.count != 0
            self.addJobStack.isHidden = self.jobData.count == 0
           
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
        cell.jobPrice.text = "$" + "\((val.initial_amount ?? 0).formattedWithSeparator)"
        cell.jobName.text = val.job_name?.uppercased()
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.totalBids.text = "\(val.bid_count ?? 0)"
        cell.category.text = val.category_name
        cell.editJob = {
           
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            let nav = storyboard.instantiateViewController(withIdentifier: "PostJobContainer") as! UINavigationController
            let myVC = nav.viewControllers[0] as! PostJobViewController
          
            myVC.jobDetail = self.jobData[self.selectedEditIntdex]
            myVC.isEditJob = true
            nav.modalPresentationStyle = .fullScreen
            self.selectedEditIntdex = 0
            
            self.present(nav, animated: true, completion: nil)
            
       
            
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
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var totalBids: UILabel!
    @IBOutlet weak var verify: UIImageView!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var viewForEdit: View!
    
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var statusContainer : UIView!
    
    
    var editJob:(()-> Void)? = nil
    
    //MARK: IBActions
    @IBAction func editAction(_ sender: Any) {
        if let editButton = self.editJob {
            editButton()
        }
    }
    
}
