


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
    @IBOutlet weak var occupation: DesignableUILabel!
    
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
        picker.delegate = self
        //self.navigationController?.isNavigationBarHidden = true
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.view.backgroundColor = darkBlue
        if(jobDetail?.job_id != nil){
            if(Singleton.shared.userInfo.user_id == self.jobDetail?.job_vendor_id){
                userImage.sd_setImage(with:
                    URL(string:self.jobDetail?.user_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = (jobDetail?.user_name ?? "").formatName(name:jobDetail?.user_name ?? "")
                self.occupation.text = jobDetail?.job_name ?? ""
                self.senderID =  jobDetail?.user_id ?? ""
                self.receiverID = jobDetail?.job_vendor_id ?? ""
                self.senderName = jobDetail?.user_name ?? ""
                self.receiverName = self.jobDetail?.vendor_name ?? ""
                
            }else {
                userImage.sd_setImage(with:URL(string:self.jobDetail?.vendor_image ?? ""), placeholderImage: UIImage(named: ""))
                self.lblUserName.text = (jobDetail?.vendor_name ?? "").formatName(name:jobDetail?.vendor_name ?? "")
                self.occupation.text = jobDetail?.job_name ?? ""
                self.senderID =  jobDetail?.job_vendor_id ?? ""
                self.receiverID = jobDetail?.user_id ?? ""
                self.senderName = jobDetail?.vendor_name ?? ""
                self.receiverName = self.jobDetail?.user_name ?? ""
                
            }
            self.chatId = self.jobDetail?.job_id ?? ""
            self.addChatObserver()
            
        }
        //            postedByMe = true
        //        if(chatDetail.accepted_by == nil){
        ////            if(chatDetail.receiver_id != nil){
        ////              if(postedByMe)
        ////            }
        //        }else {
        //            if let id = chatDetail.accepted_by {
        //                self.chatId = id + "_" + "\(chatDetail.request_id ?? 0)" + "_" + "\(chatDetail.requested_by ?? 0)"
        
        //            }
        //        }
        //
        //        if let name = chatDetail.sender_id {
        //            self.userId.
        //        }
        //
        //        if  (Singleton.shared.userInfo.id != nil && Singleton.shared.driverDetails.driver_id != nil){
        //            self.lblUserName.text = "\(Singleton.shared.driverDetails.driver_name ?? "")"
        //
        //            self.userId = Singleton.shared.userInfo.id!
        //            self.driverId = Singleton.shared.driverDetails.driver_id!
        //            chatId = "\(self.userId)" + "_" + "\(self.driverId)"
        //
        //        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //  self.navigationController?.isNavigationBarHidden = false
        //     self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //    func getCurrentMsg() {
    ////        ref.child("messages/" + self.chatId).observeSingleEvent(of: .value, with: { (snapshot) in
    //            // Get user value
    //        ref.child("messages/" + self.chatId).queryOrdered(byChild: "createdAt").observeSingleEvent(of: .value) { (snapshot) in
    //            for child in snapshot.children.allObjects as! [DataSnapshot] {
    //                print(child)
    //
    //                let myVal = child.value as! [String:Any]
    //                self.chatData.append(ChatResponse(id: myVal["id"] as! String, message: myVal["message"] as! String, read_satus: myVal["read_status"] as! Int, receiver_id: myVal["receiver_id"] as! String, sender_id: myVal["sender_id"] as! String, time: myVal["time"] as! Int, type: myVal["type"] as! Int))
    //
    //                DispatchQueue.main.async {
    //                    self.chatTable.reloadData()
    //                }
    //
    //                        }
    //                }
    //    }
    
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
    
    func uplaodUserImage() {
        ActivityIndicator.show(view: self.view)
        let fileData = self.imageData
        let storeImg = storageRef.child("chat_photos/" + "\(self.chatId)").child(self.imageName)
        storeImg.putData(fileData, metadata:StorageMetadata(dictionary: ["contentType": "image/png"])) { (snapshot, error) in
            // When the image has successfully uploaded, we get it's download URL
            self.imageData = Data()
            storeImg.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                let time =  Int(Date().timeIntervalSince1970)
                //let reqId =  self.chatDetail.j ?? 0
                // Write the download URL to the Realtime Database
                let dbRef = ref.child("messages/" + self.chatId).childByAutoId().setValue([
                    "id": self.chatId,
                    "time": time,
                    //"request_id": reqId,
                    "sender_id": self.senderID,
                    "receiver_id": self.receiverID,
                    "message": downloadURL.absoluteString,
                    "type": 2,
                    "read_status": 1,
                ])
                var curUser = String()
                if(K_CURRENT_USER == K_POST_JOB){
                    curUser = K_WANT_JOB
                }else{
                    curUser = K_POST_JOB
                }
                self.sendSingleMessage(type: 2, recieverId: self.senderID, message: downloadURL.absoluteString, senderId: self.receiverID, senderType: K_CURRENT_USER ?? "" , receiverType: curUser, messageType: 2)
                ActivityIndicator.hide()
            })
        }
    }
    
    func scheduleNotifications(title:String,msg: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = msg
        notificationContent.sound = UNNotificationSound.default
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        // Schedule the notification.
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
    
    
    @IBAction func attachmentAction(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as? AnyObject)!.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.back()
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
        
        if(data.type == 2){
            cell.messageTextView.isHidden = true
            cell.messageText.isHidden = true
            cell.uploadedImage.isHidden  = false
            if let profileURL = data.message as? String {
                cell.uploadedImage.sd_setImage(with: URL(string:profileURL), placeholderImage: UIImage(named: ""))
            }
            else {
                print("profileURL is nil")
            }
            
        }else {
            cell.messageTextView.isHidden = false
            cell.messageText.isHidden = false
            cell.uploadedImage.isHidden  = true
            cell.messageText.text = data.message
        }
        
        cell.messageText.text = data.message
        
        cell.messageTime.text = self.convertTimestampToDate(data.time ?? 0, to: "MMM dd, h:mm a")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChatViewCell
        if(self.chatData[indexPath.row].type == 2){
            let imageView = UIImageView()
            let newImageView = UIImageView()
            if let profileURL = self.chatData[indexPath.row].message as? String {
                newImageView.sd_setImage(with: URL(string:profileURL), placeholderImage: UIImage(named: ""))
            }
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
            
        }
        
        if let selectedImageName = ((info[UIImagePickerController.InfoKey.referenceURL] as? NSURL)?.lastPathComponent) {
            self.imageName = selectedImageName
            //            self.addVehicle.setTitle("", for: .normal)
        }else {
            self.imageName = "image.jpg"
        }
        self.imageData = selectedImage.pngData()!
        self.uplaodUserImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
}



class ChatViewCell: UITableViewCell {
    //MARK:IBOutlets
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var messageTextView: UIView!
    
}

