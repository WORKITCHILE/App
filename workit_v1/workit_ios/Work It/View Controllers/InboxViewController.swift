//
//  InboxViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {
    //MARK: IBOutlets
    
    @IBOutlet weak var inboxTable: UITableView!
    @IBOutlet weak var noDataLabel: DesignableUILabel!
    
    var inboxData = [InboxResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMessageList()
    }
    
    func getMessageList(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_INBOX + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetInbox.self, requestCode: U_GET_INBOX) { (response) in
            self.inboxData = response.data
            if(self.inboxData.count == 0){
                       self.noDataLabel.isHidden = false
                   }else {
                       self.noDataLabel.isHidden = true
                   }
            self.inboxTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
}

extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.inboxData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.inboxData[indexPath.row]
        if(val.sender == Singleton.shared.userInfo.user_id){
            cell.userImage.sd_setImage(with: URL(string: val.receiver_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = (val.receiver_name ?? "").formatName(name:val.receiver_name ?? "")
                
        }else {
            cell.userImage.sd_setImage(with: URL(string: val.sender_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = (val.sender_name ?? "").formatName(name:val.sender_name ?? "")
            
        }
        cell.jobAddress.text = val.last_message
        cell.timeLabel.text = self.convertTimestampToDate(val.created_at ?? 0, to: "MMM dd, h:mm a")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let i = self.inboxData[indexPath.row]
        
        let jobdetail  = GetJobResponse(job_amount: nil, status: nil, job_id: i.job_id, user_name: i.sender_name, user_image: i.sender_image, vendor_image: i.receiver_image, vendor_name: i.receiver_name, job_vendor_id: i.receiver, user_id: i.sender, user_occupation: nil, vendor_occupation: nil, vendor_dob: nil, user_dob: nil, job_description: nil, comment: nil, is_bid_placed: nil, bid_count: nil, initial_amount: nil, images: nil, job_time: nil, job_city: nil, job_state: nil, job_address: nil, job_name: nil, subcategory_id: nil, subcategory_name: nil, job_address_longitude: nil, job_address_latitude: nil, category_name: nil, service_amount: nil, counteroffer_amount: nil, job_date: nil, job_approach: nil, my_bid: nil, bids: nil)
           myVC.jobDetail = jobdetail
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
}
