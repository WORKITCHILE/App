


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
    var chatId = String()
    let picker = UIImagePickerController()
    var imageName = ""
    var imageData  = Data()
    var jobDetail : GetJobResponse?
    var senderID = String()
    var receiverID = String()
    var senderName = String()
    var receiverName = String()
    var postedByMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if(jobDetail?.job_id != nil){
            if(Singleton.shared.userInfo.user_id == self.jobDetail?.job_vendor_id){
                userImage.sd_setImage(with:
                    URL(string:self.jobDetail?.user_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = jobDetail?.user_name!.formatName()
                self.occupation.text = jobDetail?.job_name ?? ""
                self.senderID =  jobDetail?.user_id ?? ""
                self.receiverID = jobDetail?.job_vendor_id ?? ""
                self.senderName = jobDetail?.user_name ?? ""
                self.receiverName = self.jobDetail?.vendor_name ?? ""
                
            }else {
                userImage.sd_setImage(with:URL(string:self.jobDetail?.vendor_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = jobDetail?.vendor_name!.formatName()
                self.occupation.text = jobDetail?.job_name ?? ""
                self.senderID =  jobDetail?.job_vendor_id ?? ""
                self.receiverID = jobDetail?.user_id ?? ""
                self.senderName = jobDetail?.vendor_name ?? ""
                self.receiverName = self.jobDetail?.user_name ?? ""
                
            }
            self.chatId = self.jobDetail?.job_id ?? ""
            self.addChatObserver()
            
        }
     
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addChatObserver() {
        ref.child("messages/" + "\(self.chatId)").observe(.childAdded, with: { (snapshot) in
            if let myVal = snapshot.value as? [String:Any]{
                //                let myVal = snap.values as! [String:Any]
                //                if(self.userId == myVal["receiver_id"] as? Int){
                //                    self.scheduleNotifications(title:myVal["sender"] as! String, msg: myVal["message"] as! String)
                //                }
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
        let param = [
            "sender":senderId,
            "receiver":recieverId,
            "sender_type":senderType,
            "receiver_type":receiverType,
            "message_type": messageType,
            "last_message":message,
            "last_message_by":senderId,
            "job_id":self.jobDetail?.job_id
            ] as? [String:Any]
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_SEND_CHAT_MESSAGE, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SEND_CHAT_MESSAGE) { (response) in
            
        }
    }
    
    
    //MARK: IBAction
    @IBAction func sendAction(_ sender: Any) {
        
        let number = (self.textView.text ?? "").filter { "0"..."9" ~= $0 }
        let text = self.textView.text?.replacingOccurrences(of: " ", with: "")
        
        if (((text?.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression)) == nil) && (number.count < 5)) {
            if !(self.textView.text!.isEmpty && self.jobDetail?.job_id != nil){
                self.textView.resignFirstResponder()
                let id = self.chatId
                let time =  Int(Date().timeIntervalSince1970)
                
                let dbRef = ref.child("messages/" + self.chatId).childByAutoId().setValue([
                    "id": self.chatId,
                    "time": time,
                    "sender_id": self.senderID,
                    "receiver_id": self.receiverID,
                    "message": self.textView.text,
                    "type": 1,
                    "read_status": 1,
                ])
                var curUser = String()
                if(K_CURRENT_USER == K_POST_JOB){
                    curUser = K_WANT_JOB
                }else{
                    curUser = K_POST_JOB
                }
                
                self.sendSingleMessage(type: 1, recieverId: self.senderID, message: self.textView.text, senderId: self.receiverID, senderType: K_CURRENT_USER ?? "" , receiverType: curUser, messageType: 1)
                self.textView.text = ""
                self.chatTable.beginUpdates()
                //            self.chatTable.insertRows(at: [IndexPath(row: self.chatData.count, section: 0)], with: .bottom)
                self.chatTable.endUpdates()
            }
        }else {
            self.textView.text = ""
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
            myVC.image = #imageLiteral(resourceName: "information-button copy")
            myVC.titleLabel = "You are not allowed to share these details, sharing such details is breaching our terms of services."
            myVC.okBtnTtl = "Yes"
            myVC.cancelBtnHidden = true
            myVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.chatData[indexPath.row]
        var cell = ChatViewCell()
        
        if(Singleton.shared.userInfo.user_id == data.receiver_id){
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell2") as! ChatViewCell
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell1") as! ChatViewCell
            
        }

        cell.messageText.text = data.message
        
        cell.messageTime.text = self.convertTimestampToDate(data.time ?? 0, to: "MMM dd, h:mm a")
        return cell
    }
    
   
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
}

class ChatViewCell: UITableViewCell {
    //MARK:IBOutlets
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageTextView: UIView!
    
}

