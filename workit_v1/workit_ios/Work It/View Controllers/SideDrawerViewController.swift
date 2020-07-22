
//
//  SideDrawerViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SideMenu
import SDWebImage
import FirebaseAuth
import Cosmos

class SideDrawerViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var tableViewMenu: UITableView!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userName: DesignableUILabel!
    //  @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var switchImage: ImageView!
    @IBOutlet weak var switchView: View!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var switchCenterView: View!
    @IBOutlet weak var userRating: CosmosView!
    
    var arrayMenu: [MenuObject]?
    var isFirstTIme = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.switchView.layer.shadowRadius = 2
        
        //switchButton.onTintColor = lightBlue
        // switchButton.tintColor = lightBlue
        // switchButton.layer.cornerRadius = switchButton.frame.height / 2
        // switchButton.backgroundColor = lightBlue
        // switchButton.thumbTintColor = UIColor(patternImage: UIImage(named: "AppIcon")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableViewMenu.setContentOffset(CGPoint.zero, animated:false)
        self.tableViewMenu.scrollsToTop = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(K_CURRENT_USER == K_WANT_JOB){
            DispatchQueue.main.async {
                if(self.switchImage.center.x < 50){
                    self.switchImage.center = CGPoint(x: self.switchImage.center.x + 65, y: self.switchImage.center.y)
                    self.switchCenterView.layer.opacity = 0.5
                }
            }
        }else if(K_CURRENT_USER == K_POST_JOB) {
            DispatchQueue.main.async {
                if(self.switchImage.center.x > 50){
                    self.switchImage.center = CGPoint(x: self.switchImage.center.x - 65, y: self.switchImage.center.y)
                    self.switchCenterView.layer.opacity = 0.5
                }
            }
        }
        
        tableViewMenu.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        self.userName.text = Singleton.shared.userInfo.name
        self.userImage.sd_setImage(with: URL(string: Singleton.shared.userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        self.userRating.rating = Double(Singleton.shared.userInfo.average_rating ?? "0")!
        tableViewMenu.scrollsToTop = true
        if(K_CURRENT_USER == K_WANT_JOB){
            arrayMenu = [MenuObject(image: #imageLiteral(resourceName: "noun_notification_1304313"), name: "Notifications")
                ,MenuObject(image: #imageLiteral(resourceName: " mycalendar"), name: "Work Schedule"),MenuObject(image: #imageLiteral(resourceName: "noun_evaluation_808166-1"), name: "Evaluations"),MenuObject(image: #imageLiteral(resourceName: "Bids (1)"), name: "My Bids"),MenuObject(image: #imageLiteral(resourceName: "icons8-new-job-100"), name: "Running Jobs"),MenuObject(image: #imageLiteral(resourceName: "noun_History_2375219-1"), name: "History"),MenuObject(image: #imageLiteral(resourceName: "noun_Inbox_1844754-1"), name: "Inbox"),MenuObject(image: #imageLiteral(resourceName: "share"), name: "Share App"),MenuObject(image: #imageLiteral(resourceName: "support(1)"), name: "Support"),MenuObject(image: #imageLiteral(resourceName: "Account settings"), name: "Account Settings"),MenuObject(image: #imageLiteral(resourceName: "noun_task_2700413-1"), name: "Terms of Service"),MenuObject(image: #imageLiteral(resourceName: "noun_logout_1272077"), name: "Logout")]
        }else if(K_CURRENT_USER == K_POST_JOB){
            // self.switchButton.isOn = false
            arrayMenu = [MenuObject(image: #imageLiteral(resourceName: "noun_notification_1304313"), name: "Notifications"),MenuObject(image: #imageLiteral(resourceName: " mycalendar"), name: "Work Schedule"),MenuObject(image: #imageLiteral(resourceName: "icons8-new-job-100"), name: "Running Jobs"),MenuObject(image: #imageLiteral(resourceName: "noun_History_2375219-1"), name: "History"),MenuObject(image: #imageLiteral(resourceName: "noun_Inbox_1844754-1"), name: "Inbox"),MenuObject(image: #imageLiteral(resourceName: "share"), name: "Share App"),MenuObject(image: #imageLiteral(resourceName: "support(1)"), name: "Support"),MenuObject(image: #imageLiteral(resourceName: "Account settings"), name: "Account Settings"),MenuObject(image: #imageLiteral(resourceName: "noun_task_2700413-1"), name: "Terms of Service"),MenuObject(image: #imageLiteral(resourceName: "noun_logout_1272077"), name: "Logout")]
        }
        
        tableViewMenu.reloadData()
    }
    
    func selectUserRole(type: String){
        UIApplication.shared.beginIgnoringInteractionEvents()
        ActivityIndicator.show(view: self.view)
        let param = [
            "type":type,
            "uid":Singleton.shared.userInfo.user_id
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_CHANGE_USER_ROLE, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CHANGE_USER_ROLE) { (response) in
            
            K_CURRENT_USER = type
            UserDefaults.standard.set(type, forKey: UD_CURRENT_USER)
            UIApplication.shared.endIgnoringInteractionEvents()
            if(type == K_POST_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }else if(type == K_WANT_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            ActivityIndicator.hide()
        }
    }
    
    
    //MARK: IBActions
    @IBAction func profileAction(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.view.isUserInteractionEnabled = false
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func switchAction(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        if(K_CURRENT_USER == K_WANT_JOB){
            K_CURRENT_USER = K_POST_JOB
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.switchButton.isHighlighted = false
                self.switchCenterView.alpha = 0
                self.switchCenterView.layer.shadowColor = UIColor.clear.cgColor
                self.switchView.layer.shadowColor = UIColor.white.cgColor
                self.switchView.layer.shadowRadius = 2
                self.switchCenterView.layer.shadowRadius = 2
                self.switchImage.transform = CGAffineTransform(rotationAngle: 360)
                self.switchImage.center = CGPoint(x: self.switchImage.center.x - 65, y: self.switchImage.center.y)
            }, completion: { (val) in
                self.selectUserRole(type: K_POST_JOB)
            })
        }else {
            K_CURRENT_USER = K_WANT_JOB
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.switchCenterView.alpha = 0.5
                self.switchButton.isHighlighted = true
                self.switchCenterView.layer.shadowColor = UIColor.white.cgColor
                self.switchView.layer.shadowColor = lightBlue.cgColor
                self.switchView.layer.shadowRadius = 2
                self.switchCenterView.layer.shadowRadius = 2
                
                self.switchImage.transform = CGAffineTransform(rotationAngle: -360)
                self.switchImage.center = CGPoint(x: self.switchImage.center.x + 65, y: self.switchImage.center.y)
                self.switchView.backgroundColor = .darkGray
            }, completion: { (val) in
                self.selectUserRole(type: K_WANT_JOB)
            })
        }
    }
}
extension SideDrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        var menuObject = arrayMenu?[indexPath.row] as? MenuObject
        if(menuObject?.name! == "Send Feedback"){
            
            let text = menuObject?.name
            let textRange = NSMakeRange(0, text!.count)
            let attributedText = NSMutableAttributedString(string: text!)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
            // Add other attributes if needed
            cell.menuName.attributedText = attributedText
            cell.menuName.textColor = .white
            cell.menuName.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        cell.menuName.text = menuObject?.name
        
        if let menuImage = menuObject?.image {
            cell.menuImage.image = menuImage
            
        }
        return cell
    }
}
extension SideDrawerViewController: UITableViewDelegate, SuccessPopup {
    func yesAction() {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
        ActivityIndicator.show(view: self.view)
        let param = [
            "user_id":Singleton.shared.userInfo.user_id ?? "",
            "fcm_token":fcmToken
            ] as? [String:Any]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_DELETE_FCM_TOKEN, method: .post, parameter: param, objectClass: Response.self, requestCode: U_DELETE_FCM_TOKEN) { (response) in
            UserDefaults.standard.removeObject(forKey: UD_TOKEN)
            UserDefaults.standard.removeObject(forKey: UD_CURRENT_USER)
            UserDefaults.standard.removeObject(forKey: UD_USERINFO)
            UserDefaults.standard.removeObject(forKey: UD_USER_ID)
            try? Auth.auth().signOut()
            Singleton.shared.initialiseValue()
            self.isFirstTIme = true
            ActivityIndicator.hide()
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (arrayMenu?[indexPath.row])?.name {
        case "Home":
            tableViewMenu.isUserInteractionEnabled = false
            self.dismiss(animated: true, completion: nil)
            return
        case "Notifications":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Evaluations":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "EvaluationViewController") as! EvaluationViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Work Schedule":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleCalenderViewController") as! ScheduleCalenderViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "My Bids":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            tableViewMenu.isUserInteractionEnabled = false
            K_CURRENT_TAB = K_MYBID_TAB
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Running Jobs":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            tableViewMenu.isUserInteractionEnabled = false
            K_CURRENT_TAB = K_RUNNING_JOB_TAB
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "History":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            tableViewMenu.isUserInteractionEnabled = false
            K_CURRENT_TAB = K_HISTORY_TAB
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "My Publications":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PublicationViewController") as! PublicationViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Inbox":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "InboxViewController") as! InboxViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Share App":
            if let urlStr = NSURL(string: "https://itunes.apple.com/us/app/myapp/id1502685083?ls=1&mt=8") {
                let objectsToShare = [urlStr]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    if let popup = activityVC.popoverPresentationController {
                        popup.sourceView = self.view
                        popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                    }
                }
                activityVC.modalPresentationStyle = .overFullScreen
                self.present(activityVC, animated: true, completion: nil)
            }
            return
        case "Support":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Account Settings":
            if(K_CURRENT_USER  == K_POST_JOB){
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditViewController") as! CreditViewController
                myVC.isBackButtonHidden = false
                tableViewMenu.isUserInteractionEnabled = false
                self.navigationController?.pushViewController(myVC, animated: true)
            }else {
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountsViewController") as! AccountsViewController
                tableViewMenu.isUserInteractionEnabled = false
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            return
        case "Terms of Service":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            myVC.heading = "Terms of Service"
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Privacy Policy":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            myVC.heading = "Privacy Policy"
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
            return
        case "Logout":
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
            myVC.image = #imageLiteral(resourceName: "information-button copy")
            myVC.titleLabel = "Are you sure you want to Logout?"
            myVC.okBtnTtl = "Yes"
            myVC.cancelBtnTtl = "No"
            myVC.cancelBtnHidden = false
            myVC.successDelegate = self
            myVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myVC, animated: true, completion: nil)
            
            return
        default:
            tableViewMenu.isUserInteractionEnabled = true
            print("default")
        }
    }
}


class SideMenuTableViewCell: UITableViewCell{
    //MARK: IBOutles
    @IBOutlet weak var menuName: DesignableUILabel!
    @IBOutlet weak var menuImage: UIImageView!
}
