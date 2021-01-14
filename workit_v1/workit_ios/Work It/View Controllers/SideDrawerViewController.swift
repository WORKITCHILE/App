
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
    @IBOutlet weak var tableViewMenu : UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var userRating : CosmosView!
    @IBOutlet weak var fakeHeader : UIImageView!
    @IBOutlet weak var userImageContainer : UIView!
    @IBOutlet weak var circleHeaderTop: NSLayoutConstraint!
    
    var arrayMenu: [MenuObject]?
    var isFirstTIme = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTableView()
        setTransparentHeader()
        self.fakeHeader.alpha = 0.0
        
        self.userImageContainer.defaultShadow()
        
        if(self.view.frame.size.height == 667.0  || self.view.frame.size.height == 736.0){
            self.circleHeaderTop.constant = -20
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }
    
    func populateTableView(){
        
        self.tableViewMenu.delegate = self
        self.tableViewMenu.dataSource = self
        let userInfo = Singleton.shared.userInfo
        
        self.userName.text = "\(userInfo.name!) \(userInfo.father_last_name!)".uppercased()
        
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        self.userRating.rating = Double(userInfo.average_rating ?? "0")!
        
        arrayMenu = []
        
        if(userInfo.type == "HIRE"){
            arrayMenu?.append( MenuObject(image: #imageLiteral(resourceName: "ic_engine_gradient"), name: "Quiero ser Worker", action: .open, data:["vc":"BecomeWorkerViewController", "storyboard":"signup"], cellType: "BecomeWorker"))
        }
        
        self.userRating.isHidden = userInfo.type == "HIRE"
       
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_person_green"), name: "Tus datos", action: .open, data:["vc":"ProfileViewController", "storyboard":"Main"], cellType: "SideMenuTableViewCell"))
        
        if(userInfo.type == "WORK"){
            arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_menu_evaluation"), name: "Evaluaciones", action: .open, data:["vc":"EvaluationViewController", "storyboard":"Main"], cellType: "SideMenuTableViewCell"))
            
            arrayMenu?.append(MenuObject(image: UIImage(named: "ic_bids"), name: "Mis Ofertas", action: .open, data:["vc":"MyBidsViewController", "storyboard":"Main"], cellType: "SideMenuTableViewCell"))
            
            arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_bank_account"), name: "Cuenta Bancaria", action: .open, data:["vc":"AccountSettingViewController", "storyboard":"AccountAndCredits"], cellType: "SideMenuTableViewCell"))
        }
        
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_signup_wallet"), name: "Historial de pago", action: .open, data:["vc":"CreditViewController", "storyboard":"AccountAndCredits"], cellType: "SideMenuTableViewCell"))
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_menu_historial"), name: "Historial", action: .open, data:["vc":"HistorialViewController", "storyboard":"Main"], cellType: "SideMenuTableViewCell"))
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_menu_support"), name: "Soporte", action: .open, data:["vc":"SupportViewController", "storyboard":"Main"], cellType: "SideMenuTableViewCell"))
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_menu_share"), name: "Compartir App", action: .action, data:["action": "shareAction"]))
        arrayMenu?.append(MenuObject(image: #imageLiteral(resourceName: "ic_menu_term"), name: "Términos y condiciones", action: .open, data:["vc":"terms", "storyboard":"signup"], cellType: "SideMenuTableViewCell"))
        
      
         
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
        let menuObject = arrayMenu?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: menuObject?.cellType ?? "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        
        
        cell.menuName.text = menuObject?.name?.uppercased()
        cell.menuImage.image = menuObject?.image
        
        if(cell.card != nil){
            cell.card.defaultShadow()
        }
        
        return cell
    }
}
extension SideDrawerViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = arrayMenu?[indexPath.row].data
        
        switch arrayMenu?[indexPath.row].action {
            case .open:
                let storyboard  = UIStoryboard(name: data!["storyboard"]!, bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: data!["vc"]!)
                self.navigationController?.pushViewController(myVC, animated: true)
            case .action:
                self.perform(Selector(data!["action"]!))
            default:
                return
        }
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let firstLimit = scrollView.contentOffset.y >= -10.0
        let secondLimit = scrollView.contentOffset.y >= 30.0
        
        UIView.animate(withDuration: 0.5) {
           self.userImageContainer.alpha = firstLimit ? 0.0 : 1.0
           self.fakeHeader.alpha = secondLimit ?  1.0 : 0.0
        }
    }
}




class SideMenuTableViewCell: UITableViewCell{
    //MARK: IBOutles
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var card : UIView!
}
