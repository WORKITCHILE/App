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
import SCPageControl
import Cosmos

class DashboardViewController: UIViewController {
    
    
    //MARK: IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var noDataFound: DesignableUILabel!
    @IBOutlet weak var footerView : UIView!
    @IBOutlet weak var heightCollection : NSLayoutConstraint!
    @IBOutlet weak var pageControl: SCPageControlView!
    @IBOutlet weak var becomeWorkerButton : UIView!

    private var categoriesData = [GetCategoryResponse]()
    private var jobData = [GetJobResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.isHidden = true
        
        self.becomeWorkerButton.defaultShadow()
        
        self.collectionView.collectionViewLayout = {
                   let flowLayout = UICollectionViewFlowLayout()
                   flowLayout.scrollDirection = .horizontal
                   return flowLayout
        }()
    
    
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
        
        let userInfo = Singleton.shared.userInfo
        
        self.becomeWorkerButton.isHidden = userInfo.type == "WORK"
        
        getMeJobs()
    }
    
    func getMeJobs(){
        
        let url = "\(U_BASE)\(U_GET_WORKER_POSTED_JOB_ME)"
        
        let param : [String:Any] = [
            "user_id": Singleton.shared.userInfo.user_id ?? "",
        ]
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: GetJob.self, requestCode: U_GET_WORKER_POSTED_JOB_ME) { [self] (response) in
       
   
            self.jobData = response!.data.sorted(by: {$0.job_time! < $1.job_time!})
            self.pageControl.scp_style = .SCJAFillCircle
            self.pageControl.set_view(self.jobData.count + 1, current: 0, current_color: UIColor(named: "selected_blue")!, disable_color: .gray)
            
            self.resizeHeader()
            self.tableView.reloadData()
            self.collectionView.reloadData()
            
            if(self.jobData.count > 0){
                self.collectionView.isHidden = false
            }
           
        }
    }
    
    @IBAction func becommeWorkerAction(_ sender : AnyObject){
        let storyboard  = UIStoryboard(name: "signup", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier:"BecomeWorkerViewController")
        self.navigationController?.pushViewController(myVC, animated: true)
    }
   
    func resizeHeader(){
        let size = CGSize(width: self.view.frame.size.width, height: 152.0)
        collectionView.setPrototypeCell(size: size)
        
        if(self.jobData.count > 0){
            self.heightCollection.constant = 180.0
            self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 400.0)
            
        } else {
           
            self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 300.0)
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

}


extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource{
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            
            cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.user_name
        
            cell.jobDate.text = val.job_date
            cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.card.defaultShadow()
            cell.verify.isHidden = !val.have_document
      
            
            let formater = NumberFormatter()
            formater.groupingSeparator = "."
            formater.numberStyle = .decimal
            let formattedNumber = formater.string(from: NSNumber(value: val.initial_amount!) )
            
            
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        }
            
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
        myVC.jobId = self.jobData[indexPath.row - 1].job_id ?? ""
        myVC.modeView = 1
        self.navigationController?.pushViewController(myVC, animated: true)
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 152.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == self.collectionView){
            self.pageControl.scroll_did(scrollView)
        }
    }
}

extension UICollectionView {
    func setPrototypeCell(size: CGSize, scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = size
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
