
//
//  SideDrawerViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import Cosmos

class SideDrawerViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var tableViewMenu: UITableView!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userName: DesignableUILabel!
    @IBOutlet weak var userRating: CosmosView!
    
    var arrayMenu: [MenuObject]?
    var isFirstTIme = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTableView()
    }
    
    func populateTableView(){
        
        self.tableViewMenu.delegate = self
        self.tableViewMenu.dataSource = self
        let userInfo = Singleton.shared.userInfo
        
        self.userName.text = userInfo.name
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        self.userRating.rating = Double(userInfo.average_rating ?? "0")!
         
        if K_CURRENT_USER == K_WANT_JOB {
            arrayMenu = [
                 MenuObject(image: #imageLiteral(resourceName: "noun_evaluation_808166-1"), name: "Evaluations"),
                 MenuObject(image: #imageLiteral(resourceName: "Bids (1)"), name: "My Bids"),
                 MenuObject(image: #imageLiteral(resourceName: "icons8-new-job-100"), name: "Running Jobs"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_History_2375219-1"), name: "History"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_Inbox_1844754-1"), name: "Inbox"),
                 MenuObject(image: #imageLiteral(resourceName: "share"), name: "Share App"),
                 MenuObject(image: #imageLiteral(resourceName: "support(1)"), name: "Support"),
                 MenuObject(image: #imageLiteral(resourceName: "Account settings"), name: "Account Settings"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_task_2700413-1"), name: "Terms of Service"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_logout_1272077"), name: "Logout")
            ]
             
         } else {
            arrayMenu = [
                 MenuObject(image: #imageLiteral(resourceName: "icons8-new-job-100"), name: "Running Jobs"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_History_2375219-1"), name: "History"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_Inbox_1844754-1"), name: "Inbox"),
                 MenuObject(image: #imageLiteral(resourceName: "share"), name: "Share App"),
                 MenuObject(image: #imageLiteral(resourceName: "support(1)"), name: "Support"),
                 MenuObject(image: #imageLiteral(resourceName: "Account settings"), name: "Account Settings"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_task_2700413-1"), name: "Terms of Service"),
                 MenuObject(image: #imageLiteral(resourceName: "noun_logout_1272077"), name: "Logout")
            ]
         }
         
         tableViewMenu.reloadData()
    }
    
    func selectUserRole(type: String){
        UIApplication.shared.beginIgnoringInteractionEvents()
        ActivityIndicator.show(view: self.view)
        let param: [String:Any] = [
            "type":type,
            "uid":Singleton.shared.userInfo.user_id
            ]
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
    
   
}
extension SideDrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        let menuObject = arrayMenu?[indexPath.row]
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
       
        let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
        ActivityIndicator.show(view: self.view)
        let param : [String:Any] = [
            "user_id":Singleton.shared.userInfo.user_id ?? "",
            "fcm_token":fcmToken
            ]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_DELETE_FCM_TOKEN, method: .post, parameter: param, objectClass: Response.self, requestCode: U_DELETE_FCM_TOKEN) { resonse in
            UserDefaults.standard.removeObject(forKey: UD_TOKEN)
            UserDefaults.standard.removeObject(forKey: UD_CURRENT_USER)
            UserDefaults.standard.removeObject(forKey: UD_USERINFO)
            UserDefaults.standard.removeObject(forKey: UD_USER_ID)
            try? Auth.auth().signOut()
            Singleton.shared.initialiseValue()
            self.isFirstTIme = true
            ActivityIndicator.hide()
            
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
            debugPrint(myVC)
            self.view.window?.rootViewController = myVC
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      
        let selectedMenu : String = (arrayMenu?[indexPath.row].name ?? "") as String
    
        
        switch selectedMenu {
        case "Evaluations":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "EvaluationViewController") as! EvaluationViewController
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)
        case "My Bids":
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            tableViewMenu.isUserInteractionEnabled = false
            K_CURRENT_TAB = K_MYBID_TAB
            self.navigationController?.pushViewController(myVC, animated: true)

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
            } else {
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountsViewController") as! AccountsViewController
                tableViewMenu.isUserInteractionEnabled = false
                self.navigationController?.pushViewController(myVC, animated: true)
            }

        case "Terms of Service":
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            myVC.heading = "Terms of Service"
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)

        case "Privacy Policy":
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            myVC.heading = "Privacy Policy"
            tableViewMenu.isUserInteractionEnabled = false
            self.navigationController?.pushViewController(myVC, animated: true)

        case "Logout":
            

            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
            myVC.image = #imageLiteral(resourceName: "information-button copy")
            myVC.titleLabel = "Are you sure you want to Logout?"
            myVC.okBtnTtl = "Yes"
            myVC.cancelBtnTtl = "No"
            myVC.cancelBtnHidden = false
            myVC.successDelegate = self
            myVC.modalPresentationStyle = .overFullScreen
            
            self.present(myVC, animated: true, completion: nil)
          
 
        default:
            tableViewMenu.isUserInteractionEnabled = true
        }
    }
}


class SideMenuTableViewCell: UITableViewCell{
    //MARK: IBOutles
    @IBOutlet weak var menuName: DesignableUILabel!
    @IBOutlet weak var menuImage: UIImageView!
}
