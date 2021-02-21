//
//  DashboardViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//


import UIKit
import SDWebImage
import Lottie
import CHIPageControl
import Cosmos

class DashboardViewController: UIViewController {
    
    
    //MARK: IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var noDataFound: DesignableUILabel!
    @IBOutlet weak var footerView : UIView!
    @IBOutlet weak var heightCollection : NSLayoutConstraint!
    @IBOutlet weak var pageControl: CHIPageControlAji!
    @IBOutlet weak var becomeWorkerButton : UIView!
    @IBOutlet weak var heightTitle: NSLayoutConstraint!

    private var categoriesData = [GetCategoryResponse]()
    private var jobData = [GetJobResponse]()
    private var userInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo = Singleton.shared.userInfo
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.isHidden = true
        
        self.becomeWorkerButton.defaultShadow()
        

        if(Singleton.shared.getCategories.count == 0){
           
            CallAPIViewController.shared.getCategory(completionHandler: { response in
                Singleton.shared.getCategories = response
                 self.categoriesData = Singleton.shared.getCategories
                
                if(self.categoriesData.count == 0){
                    self.noDataFound.isHidden = false
                }else {
                    self.noDataFound.isHidden = true
                }
                
                self.tableView.reloadData()
               
            })
            
        } else {
            self.categoriesData = Singleton.shared.getCategories
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
      
        
        resizeHeader()
        getMeJobs()
        getProfileData()
    }
    
    func getProfileData(){
       
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
            
            Singleton.shared.userInfo = response!.data!
            Singleton.saveUserInfo(data:Singleton.shared.userInfo)
          
            self.resizeHeader()
        }
    }
    
    func getMeJobs(){
        
        let url = "\(U_BASE)\(U_GET_WORKER_POSTED_JOB_ME)"
        
        let param : [String:Any] = [
            "user_id": Singleton.shared.userInfo.user_id ?? "",
        ]
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: GetJob.self, requestCode: U_GET_WORKER_POSTED_JOB_ME) { [self] (response) in
       
            
            if(response != nil){
                self.jobData = response!.data.sorted(by: {$0.job_time! < $1.job_time!})
                self.pageControl.numberOfPages = self.jobData.count + 1
                
                self.pageControl.set(progress: 0, animated: true)
                self.pageControl.radius = 4
                self.pageControl.tintColor = UIColor(named: "border_blue")
                self.pageControl.currentPageTintColor = UIColor(named: "calendar_blue")
                
                self.tableView.reloadData()
            }
          
            
            if(self.jobData.count > 0){
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.resizeHeader()
            }
           
        }
    }
    
    func getSubCategoryData(_ category : GetCategoryResponse){
        
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_GET_SUBCATEGORIES)\(category.category_id ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetSubcategory.self, requestCode: U_GET_SUBCATEGORIES) { response in
            
            ActivityIndicator.hide()
            
         
            if(response == nil){
                return
            }
            
            let storyboard  = UIStoryboard(name: "HomeWorker", bundle: nil)
            
            if(response!.data.count == 0){
               
                let myVC = storyboard.instantiateViewController(withIdentifier: "CategoryListViewController") as! CategoryListViewController
                
                myVC.subcategories = [GetSubcategoryResponse(subcategory_image: category.category_image, category_id: category.category_id, subcategory_name: category.category_name, subcategory_id: category.category_id, types: category.types)]
               

                self.navigationController?.pushViewController(myVC, animated: true)
                     
            } else {
                let myVC = storyboard.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
                myVC.subcategoryData = response!.data
               
                self.navigationController?.pushViewController(myVC, animated: true)
            }
            
        }
    }
    
    @IBAction func becommeWorkerAction(_ sender : AnyObject){
        
        let userInfo = Singleton.shared.userInfo
        
        if( userInfo.address == "" || userInfo.contact_number == ""){
            
            /* OPEN COMPLETE DATA CONTAINER*/
            
            let alert = UIAlertController(title: "Workit", message: "Debes completar algunos datos antes de convertirte en Worker", preferredStyle: .alert)
                      
            alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
                let storyboard  = UIStoryboard(name: "Home", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "CompleteDataContainer") as! UINavigationController
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                  
            })
             
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
           
            
            return
        }
        
        let storyboard  = UIStoryboard(name: "signup", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier:"BecomeWorkerViewController")
        self.navigationController?.pushViewController(myVC, animated: true)
    }
   
    func resizeHeader(){
      
        
        self.becomeWorkerButton.isHidden = userInfo?.type == "WORK"
        self.pageControl.isHidden = userInfo?.type != "WORK" || self.jobData.count == 0
        self.collectionView.isHidden = userInfo?.type != "WORK" || self.jobData.count == 0
        
        let heightHeaderWithJob = 450.0
        var heightHeaderWithoutJob = ( (userInfo?.type == "HIRE") ? 300.0 : 200.0)
        
        if(self.view.frame.size.height == 667.0){
            heightHeaderWithoutJob = ( (userInfo?.type == "HIRE") ? 300.0 : 200.0)
        } else if(self.view.frame.size.height == 736.0){
            heightHeaderWithoutJob = ( (userInfo?.type == "HIRE") ? 300.0 : 200.0)
        }
        
        if(self.jobData.count > 0){
            
            let size = CGSize(width: self.view.frame.size.width, height: 152.0)
            collectionView.setPrototypeCell(size: size)
            
            self.heightCollection.constant = 180.0
            self.heightTitle.constant = 70.0
            self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: CGFloat(heightHeaderWithJob))
            
        } else {
            self.heightCollection.constant = 180.0
            self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: CGFloat(heightHeaderWithoutJob))
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! SubCategoryViewController
        
        myVC.category = self.categoriesData[self.tableView.indexPathForSelectedRow!.row]
        myVC.titleHeading = self.categoriesData[self.tableView.indexPathForSelectedRow!.row].category_name ?? ""
    
    }
    
}




extension DashboardViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoriesData.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell") as! DashboardCell
        
        let val = self.categoriesData[indexPath.row]
        cell.selectionStyle = .none
        cell.jobName.text = val.category_name?.uppercased()
        cell.jobImage.sd_setImage(with: URL(string: val.category_image ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let val = self.categoriesData[indexPath.row]
        getSubCategoryData(val)
    }

}


extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource{
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(jobData.count == 0){
            return 0
        }
        
        return 1 + self.jobData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = (indexPath.row == 0) ? "alertCard" : "WorkCard"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! WorkCollectionCell
        
        if(indexPath.row == 0){
            let starAnimation = Animation.named("handshake")
            cell.animation?.animation = starAnimation
            cell.animation?.loopMode = .loop
            cell.animation?.play()
        } else {
            let val = self.jobData[indexPath.row - 1]
           
            cell.jobName.text = val.job_name?.uppercased()
            
            cell.userImage.sd_setImage(with: URL(string: val.user_image!),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.user_name
        
            cell.jobDate.text = val.job_date
            cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.card.defaultShadow()
            cell.verify.isHidden = !(val.have_document ?? false)

            let formater = NumberFormatter()
            formater.groupingSeparator = "."
            formater.numberStyle = .decimal
            let formattedNumber = formater.string(from: NSNumber(value: val.initial_amount!) )
            
            
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        }
            
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        if(indexPath.row > 0){
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
            myVC.jobId = self.jobData[indexPath.row - 1].job_id ?? ""
            myVC.modeView = 1
            self.navigationController?.pushViewController(myVC, animated: true)
        }
       
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 152.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == self.collectionView){
           
            
            let pageWidth = scrollView.frame.size.width
            let page = Int(floor( scrollView.contentOffset.x  / pageWidth) )

            self.pageControl.set(progress: page, animated: true)
          
        }
    }
}

extension UICollectionView {
    func setPrototypeCell(size: CGSize, scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = size
        flow.minimumLineSpacing = 0.0
        flow.minimumInteritemSpacing = 0.0
        flow.scrollDirection = scrollDirection
        self.collectionViewLayout = flow
    }
}



class DashboardCell: UITableViewCell{
    //MARK: IBOutlets
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobName: UILabel!
}

class WorkCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var verify: UIImageView!
    @IBOutlet weak var card: UIView!

    
}
