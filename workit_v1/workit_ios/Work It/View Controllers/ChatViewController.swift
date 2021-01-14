


import UIKit
import UserNotifications
import SDWebImage
import FirebaseStorage
import Firebase

class ChatViewController: UIViewController {
    
    //MARK:IBOutlets
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var occupation: UILabel!
    
    var chatData = [ChatResponse]()
    var userId = Int()
    var driverId  = Int()
   
    let picker = UIImagePickerController()
   
    var imageData  = Data()
    var jobDetail : GetJobResponse?
    
    var imageName = ""
    var chatId = ""
    var senderID = ""
    var receiverID = ""
    var senderName = ""
    var receiverName = ""
    
    var postedByMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if(jobDetail?.job_id != nil){
            if(Singleton.shared.userInfo.user_id == self.jobDetail?.job_vendor_id){
                userImage.sd_setImage(with:
                    URL(string:self.jobDetail?.user_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = jobDetail?.user_name!
                self.senderID =  jobDetail?.user_id ?? ""
                self.receiverID = jobDetail?.job_vendor_id ?? ""
                self.senderName = jobDetail?.user_name ?? ""
                self.receiverName = self.jobDetail?.vendor_name ?? ""
                
            }else {
                userImage.sd_setImage(with:URL(string:self.jobDetail?.vendor_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = jobDetail?.vendor_name!
               
                self.senderID =  jobDetail?.job_vendor_id ?? ""
                self.receiverID = jobDetail?.user_id ?? ""
                self.senderName = jobDetail?.vendor_name ?? ""
                self.receiverName = self.jobDetail?.user_name ?? ""
                
            }
            self.chatId = self.jobDetail?.job_id ?? ""
            self.addChatObserver()
            
        }
        
        setNavigationBar()
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        chatTable.estimatedRowHeight = 160;
        chatTable.rowHeight = UITableView.automaticDimension
     
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addChatObserver() {
        ref.child("messages/" + "\(self.chatId)").observe(.childAdded, with: { (snapshot) in
            if let myVal = snapshot.value as? [String:Any]{
                
                self.chatData.append(ChatResponse(id: myVal["id"] as! String, message: myVal["message"] as! String, read_satus: myVal["read_status"] as! Int, receiver_id: myVal["receiver_id"] as! String, sender_id: myVal["sender_id"] as! String, time: myVal["time"] as! Int, type: myVal["type"] as! Int))
                
                self.chatTable.beginUpdates()
                self.chatTable.insertRows(at: [IndexPath(row: self.chatData.count - 1, section: 0)], with: .bottom)
                self.chatTable.endUpdates()
                self.chatTable.scrollToRow(at: IndexPath(row: self.chatData.count - 1, section: 0), at: .bottom, animated: false)
            }
        })
    }
 
    
    func scheduleNotifications(title:String,msg: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = msg
        notificationContent.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        
        let request = UNNotificationRequest(identifier: "FiveSecond", content: notificationContent, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error: Error?) in
            if let theError = error {
                print(theError)
            }
        }
    }
    
    func sendSingleMessage(type: Int, recieverId: String, message: String,senderId: String, senderType: String, receiverType: String, messageType:Int) {
        let param : [String:Any] = [
            "sender":senderId,
            "receiver":recieverId,
            "sender_type":senderType,
            "receiver_type":receiverType,
            "message_type": messageType,
            "last_message":message,
            "last_message_by":senderId,
            "job_id":self.jobDetail?.job_id ?? ""
            ]
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_SEND_CHAT_MESSAGE, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SEND_CHAT_MESSAGE) { (response) in
            
        }
    }
    
    
    //MARK: IBAction
    @IBAction func sendAction(_ sender: Any) {
        
       
        if !(self.textView.text!.isEmpty && self.jobDetail?.job_id != nil){
            self.textView.resignFirstResponder()
   
            let time =  Int(Date().timeIntervalSince1970)
            
            ref.child("messages/" + self.chatId).childByAutoId().setValue([
                "id": self.chatId,
                "time": time,
                "sender_id": self.senderID,
                "receiver_id": self.receiverID,
                "message": self.textView.text ?? "",
                "type": 1,
                "read_status": 1,
            ])
            
            let curUser = (K_CURRENT_USER == K_POST_JOB) ? K_WANT_JOB : K_POST_JOB
          
            self.sendSingleMessage(type: 1, recieverId: self.senderID, message: self.textView.text, senderId: self.receiverID, senderType: K_CURRENT_USER ?? "" , receiverType: curUser, messageType: 1)
            self.textView.text = ""
            self.chatTable.beginUpdates()
            self.chatTable.endUpdates()
        }
        
        
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.chatData[indexPath.row]
        let isMe = Singleton.shared.userInfo.user_id == data.receiver_id
        let identifier = isMe ? "ChatViewCell2" : "ChatViewCell1"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MessageCell
        
        if(isMe){
            cell.card.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 15.0)
        }else {
            cell.card.roundCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 15.0)
        }
        
        cell.messageTextView.text = data.message
        cell.timeAgoLabel.text = self.convertTimestampToDate(data.time ?? 0, to: "MMM dd, h:mm a")
        //cell.card.defaultShadow()
        
        return cell
    }
    
   
    
   
}


