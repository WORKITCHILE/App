//
//  InboxViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class InboxViewController: UIViewController {
    //MARK: IBOutlets
    
    @IBOutlet weak var inboxTable: UITableView!
    @IBOutlet weak var notContent: UIView!
    @IBOutlet weak var animation: AnimationView?
    
    var inboxData = [InboxResponse]()
    var fromNotification = false
    private var isRedirect = false
    var jobIdFromNotification = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let starAnimation = Animation.named("chat")
        animation!.animation = starAnimation
        
        animation?.loopMode = .loop
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        if(fromNotification){
            self.setNavigationBarForClose()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        animation?.play()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getMessageList()
    }
    
 
    func getMessageList(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_INBOX + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetInbox.self, requestCode: U_GET_INBOX) { (response) in
            
            
            ActivityIndicator.hide()
            
            if(response == nil){
                return
            }
            
            self.inboxData = response!.data
            
            if(!self.isRedirect){
                self.inboxData.forEach {
                    if($0.job_id == self.jobIdFromNotification){
                        self.openChat(i: $0)
                    }
                }
                self.isRedirect = true
            }
           
            self.notContent.isHidden = self.inboxData.count != 0
            
            self.inboxTable.reloadData()
           
        }
    }
    
    func openChat(i : InboxResponse){
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let jobdetail  = GetJobResponse( status: nil, job_id: i.job_id, user_name: i.sender_name, user_image: i.sender_image, vendor_image: i.receiver_image, vendor_name: i.receiver_name, job_vendor_id: i.receiver, user_id: i.sender, user_occupation: nil, vendor_occupation: nil, job_description: nil, comment: nil, is_bid_placed: nil, bid_count: nil, initial_amount: nil, service_amount: nil, images: nil, job_time: nil, job_city: nil, job_state: nil, job_address: nil, job_name: nil, subcategory_id: nil, subcategory_name: nil, job_address_longitude: nil, job_address_latitude: nil, category_name: nil, counteroffer_amount: nil, job_date: nil, job_approach: nil, my_bid: nil, bids: [])
        myVC.jobDetail = jobdetail
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    //MARK: IBActions
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let myVC = segue.destination as! ChatViewController
        let i = self.inboxData[self.inboxTable.indexPathForSelectedRow!.row]
        
        let jobdetail  = GetJobResponse( status: nil, job_id: i.job_id, user_name: i.sender_name, user_image: i.sender_image, vendor_image: i.receiver_image, vendor_name: i.receiver_name, job_vendor_id: i.receiver, user_id: i.sender, user_occupation: nil, vendor_occupation: nil, job_description: nil, comment: nil, is_bid_placed: nil, bid_count: nil, initial_amount: nil, service_amount: nil, images: nil, job_time: nil, job_city: nil, job_state: nil, job_address: nil, job_name: nil, subcategory_id: nil, subcategory_name: nil, job_address_longitude: nil, job_address_latitude: nil, category_name: nil, counteroffer_amount: nil, job_date: nil, job_approach: nil, my_bid: nil, bids: [])
           myVC.jobDetail = jobdetail
        
       
    }
    
}

extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.inboxData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        let val = self.inboxData[indexPath.row]
        
        if(val.sender == Singleton.shared.userInfo.user_id){
            cell.avatarImage.sd_setImage(with: URL(string: val.receiver_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.nameLabel.text = val.receiver_name!
            
        }else {
            cell.avatarImage.sd_setImage(with: URL(string: val.sender_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.nameLabel.text = val.sender_name!
        }
        
        if(val.job_name != nil){
            cell.jobNameLabel.text = val.job_name
        } 
        
        cell.messageLabel.text = val.last_message
        cell.timeAgoLabel.text = self.convertTimestampToDate(val.created_at ?? 0, to: "MMM dd, h:mm a")
        
        cell.card.defaultShadow()
        
        return cell
    }
    
}

class MessageCell : UITableViewCell {
    @IBOutlet weak var avatarImage : ImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var timeAgoLabel : UILabel!
    @IBOutlet weak var jobNameLabel : UILabel!
    
    @IBOutlet weak var messageTextView : UITextView!
   
    @IBOutlet weak var card : UIView!
}
