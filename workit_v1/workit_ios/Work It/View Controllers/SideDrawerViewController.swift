
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
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    
    var arrayMenu: [MenuObject]?
    var isFirstTIme = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTableView()
        setTransparentHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }
    
    func populateTableView(){
        
        self.tableViewMenu.delegate = self
        self.tableViewMenu.dataSource = self
        let userInfo = Singleton.shared.userInfo
        
        self.userName.text = userInfo.name
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        self.userRating.rating = Double(userInfo.average_rating ?? "0")!
         
        arrayMenu = [
            //MenuObject(image: #imageLiteral(resourceName: "ic_menu_work"), name: "Trabajos en ejecución", action: .open, data: ["vc":"HistoryViewController"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_menu_historial"), name: "Historial", action: .open, data: ["vc":"HistoryViewController"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_menu_evaluation"), name: "Evaluaciones", action: .open, data:["vc":"EvaluationViewController"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_menu_support"), name: "Soporte", action: .open, data:["vc":"SupportViewController"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_menu_share"), name: "Compartir App", action: .action, data:["action": "shareAction"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_config"), name: "Configuraciones", action: .open, data:["vc":"CreditViewController"]),
            MenuObject(image: #imageLiteral(resourceName: "ic_menu_term"), name: "Términos y condiciones", action: .open, data:[:])
        ]
         
         tableViewMenu.reloadData()
    }
    
    @objc func shareAction(){
        let urlStr = NSURL(string: "https://itunes.apple.com/us/app/myapp/id1502685083?ls=1&mt=8")
        let objectsToShare = [urlStr]
        let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: nil)
        activityVC.modalPresentationStyle = .overFullScreen
        self.present(activityVC, animated: true, completion: nil)
        
    }

    //MARK: IBActions
    @IBAction func profileAction(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.view.isUserInteractionEnabled = false
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
       let alert = UIAlertController(title: "Logout", message: "¿Estás seguro que quiere salir?", preferredStyle: .alert)
                 
          alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
            
              ActivityIndicator.show(view: self.view)
            
              let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
              let url = "\(U_BASE)\(U_DELETE_FCM_TOKEN)"
            
              let param : [String:Any] = [
                  "user_id": Singleton.shared.userInfo.user_id ?? "",
                  "fcm_token": fcmToken as Any
              ]
              
              
              SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_DELETE_FCM_TOKEN) { resonse in
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
                  self.view.window?.rootViewController = myVC
              }
          })
        
          alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

          self.present(alert, animated: true)
        
    }

    
   
}
extension SideDrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        let menuObject = arrayMenu?[indexPath.row]
        
        cell.menuName.text = menuObject?.name?.uppercased()
        cell.menuImage.image = menuObject?.image
        
        return cell
    }
}
extension SideDrawerViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = arrayMenu?[indexPath.row].data
        
        switch arrayMenu?[indexPath.row].action {
            case .open:
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: data!["vc"]!)
                self.navigationController?.pushViewController(myVC!, animated: true)
            case .action:
                self.perform(Selector(data!["action"]!))
            default:
                return
        }
        
        
        /*
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
        */
    }
}


class SideMenuTableViewCell: UITableViewCell{
    //MARK: IBOutles
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
}
