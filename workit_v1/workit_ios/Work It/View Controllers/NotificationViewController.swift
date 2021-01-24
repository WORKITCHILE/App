//
//  NotificationViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class NotificationViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var notificationTable: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var animation: AnimationView?
    
    var notificationData : [GetNotificationResponse]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        
        let starAnimation = Animation.named("notification")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.getNotificationData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        animation?.play()
    }
    
    func getNotificationData(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_NOTIFICATION)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetNotification.self, requestCode: U_GET_NOTIFICATION) { response in
            self.notificationData = response?.data
            self.noDataView.isHidden = self.notificationData?.count != 0
            self.notificationTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    func retrieveJoFromId(_ jobId : String, _ mode : String, _ bid: BidResponse?){
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(jobId)"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) {
            
            ActivityIndicator.hide()
            
           
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "bidDetail") as! BidDetailViewController
            myVC.jobData = $0?.data
            if(bid != nil){
                myVC.bidData = bid
            }
            myVC.mode = mode
            self.navigationController?.pushViewController(myVC, animated: true)
            
           
            
        }
    }
    
    func retrieveBidFromId(_ bidId : String, _ jobId: String){
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_GET_SINGLE_BID_WORKER)\(bidId)"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleBid.self, requestCode: U_GET_SINGLE_BID_WORKER) { [self] repsonse in
            
            ActivityIndicator.hide()
            if(repsonse != nil){
                retrieveJoFromId(jobId, "HIRE", repsonse!.data)
            }
          
            
        }
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let data = self.notificationData?[indexPath.row]
        cell.jobName.text = data?.notification_body
        cell.userName.text = data?.sender_name!
        cell.userImage.sd_setImage(with: URL(string: data?.sender_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.timeLabel.text = self.convertTimestampToDate(data?.created_at ?? 0, to: "MMM dd, h:mm a")
        
        cell.card.defaultShadow()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let notification = self.notificationData?[indexPath.row]
        let jobId = notification?.job_id
        let bidId = notification?.bid_id
        let userId = Singleton.shared.userInfo.user_id
        let senderId = notification?.sender_id
        let notificationType = notification?.notification_type
        
        // 14, 13, 12, 11, 10, 8, 7, 6, 5, 3
    
        if(notificationType == 15){
            let storyboard  = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "EvaluationViewController")
            self.navigationController?.pushViewController(myVC, animated: true)
        } else if(notificationType == 2){
            self.retrieveBidFromId(bidId!, jobId!)
        } else if(notificationType == 4){
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
            myVC.jobId = jobId
            myVC.modeView = 1
            self.navigationController?.pushViewController(myVC, animated: true)
        } else if(notificationType == 14){
            self.retrieveJoFromId(jobId ?? "", "HIRE", nil)
        } else {
            if(jobId != nil) {
                self.retrieveJoFromId(jobId ?? "", (userId == senderId) ? "HIRE" : "WORK", nil)
            }
        }
        
       
    }
    
}
