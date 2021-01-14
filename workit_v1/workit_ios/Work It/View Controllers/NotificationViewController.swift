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
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        self.getNotificationData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
    
    func getNotificationData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_NOTIFICATION +  (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetNotification.self, requestCode: U_GET_NOTIFICATION) { (response) in
            self.notificationData = response?.data
            self.noDataView.isHidden = self.notificationData?.count != 0
            self.notificationTable.reloadData()
            ActivityIndicator.hide()
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
        
        if(notificationType == 15){
            
        } else if(notificationType == 2){
        
        } else if(notificationType == 4){
            
        } else if(notificationType == 15){
            
        } else {
            if(jobId != nil) {

                ActivityIndicator.show(view: self.view)
                
                let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(jobId ?? "")"
                
                SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) {
                    
                    ActivityIndicator.hide()
                    
                   
                    let storyboard  = UIStoryboard(name: "Home", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "bidDetail") as! BidDetailViewController
                    myVC.jobData = $0?.data
                    myVC.mode = (userId == senderId) ? "HIRE" : "WORK"
                    self.navigationController?.pushViewController(myVC, animated: true)
                    
                   
                    
                }
                
               
              
         
               

            }
        }
        
        /*
         
         Notification notification = notificationList.get(position);
         int notificationType = notification.getNotificationType();
         String jobId = notification.getJobId();
         String bidId = notification.getBidId();

         if(notificationType == 15){
             Intent intent = new Intent(this, EvaluationActivity.class);
             startActivity(intent);
         } else if(notificationType == 2){

             if(jobId != null && bidId != null){
                 currentSender = notification.getSenderId();
                 getBidInfo(jobId, bidId);
             }

         } else if(notificationType == 4) {

             startActivityForResult(SingleJobActivity.createIntent(this,jobId, 1), RC_JOB_INFO);

         }  else if(notificationType == 14) {
             if(jobId != null) {
                 Intent intent = BidInfoActivity.createIntent(this, jobId);
                 startActivity(intent);

             }
         } else {

             if(jobId != null) {

                 if(userInfo.getUserId().equalsIgnoreCase(notification.getSenderId())){
                     Intent intent = BidInfoActivity.createIntent(this, jobId);
                     startActivity(intent);
                 } else {
                     Intent intent = BidInfoWorkerActivity.createIntent(this, jobId);
                     startActivity(intent);
                 }

             }

         }
         */
       
    }
    
}
