//
//  NotificationViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var notificationTable: UITableView!
    @IBOutlet weak var noDataLabel: DesignableUILabel!
    
    var notificationData : [GetNotificationResponse]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNotificationData()
    }
    
    func getNotificationData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_NOTIFICATION +  (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetNotification.self, requestCode: U_GET_NOTIFICATION) { (response) in
            self.notificationData = response.data
            self.noDataLabel.isHidden = self.notificationData?.count != 0
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
        cell.userName.text = data?.sender_name!.formatName() 
        cell.userImage.sd_setImage(with: URL(string: data?.sender_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.timeLabel.text = self.convertTimestampToDate(data?.created_at ?? 0, to: "MMM dd, h:mm a")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch self.notificationData?[indexPath.row].notification_type{
        // New Job Request
        case 1:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        // Bid Received for your posted job
        case 2:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        //Bid accepted by owner for worker bid
        case 3:
            let  initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        //Bid rejected by owner for worker bid
        case 4:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        // Job Started by worker
        case 5:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        // Job finished by worker
        case 6:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        case 8:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                       initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
                       self.navigationController?.pushViewController(initialViewController, animated: true)
                       break
        case 10:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                       initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
                       self.navigationController?.pushViewController(initialViewController, animated: true)
                       break
        case 11:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        case 12:
            let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
            case 15:
              let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "EvaluationViewController") as! EvaluationViewController
            self.navigationController?.pushViewController(initialViewController, animated: true)
             break
        default:
            if(K_CURRENT_USER == K_POST_JOB){
                let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }else {
                let  initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                           initialViewController.jobId = self.notificationData?[indexPath.row].job_id ?? ""
                           self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            break
        }
    }
    
}
