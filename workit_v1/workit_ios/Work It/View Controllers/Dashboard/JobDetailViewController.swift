//
//  JobDetailViewController.swift
//  Work It
//
//  Created by qw on 08/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController{

    
    //MARK: IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var fakeHeader: UIImageView!
    @IBOutlet weak var userImageView : View!
    
    @IBOutlet weak var viewForPhoto: UIView!
    @IBOutlet weak var viewForbid: UIView!
    @IBOutlet weak var viewCancelJob: UIView!
    @IBOutlet weak var bidTable: ContentSizedTableView!
    
    @IBOutlet weak var viewPhotos: UIView!
    @IBOutlet weak var viewAwardedTo: UIView!
    @IBOutlet weak var awardedToName: DesignableUILabel!
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    
    var jobId: String?
    var jobData:GetJobResponse?
    var jobImage = [String]()
    
    var jobDataProperties : [[String:String]] = []
    
    var hiddenHeader = true
    var hiddenAvatar = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.photoCollection.delegate = self
        self.photoCollection.dataSource = self
        self.getJobDetail()
        self.setNavigationBar()
        
        self.fakeHeader.alpha = 0.0
    }
    
    func getJobDetail(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(self.jobId ?? "")"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { (response) in
            self.jobData = response.data
            
            if(((self.jobData?.bids?.count ?? 0) > 0) && (self.jobData?.vendor_name == nil)){
                self.viewForbid.isHidden = false
                //self.bidTable.reloadData()
            }
            
             self.jobImage = self.jobData!.images ?? []
            
            self.jobDataProperties.append(["title": "Nombre del trabajo", "value" : self.jobData?.job_name ?? "" ])
            self.jobDataProperties.append(["title": "Precio", "value" : "$" + "\(self.jobData?.initial_amount ?? 0)" ])
            self.jobDataProperties.append(["title": "Categoria", "value" : self.jobData?.category_name! ?? ""])
            self.jobDataProperties.append(["title": "Subcategoria", "value" : self.jobData?.subcategory_name! ?? ""])
            self.jobDataProperties.append(["title": "Dirección", "value" : self.jobData?.job_address ?? ""])
            
            self.jobDataProperties.append(["title": "Enfoque de trabajo", "value" : self.jobData?.job_approach ?? ""])
            self.jobDataProperties.append(["title": "Descripción", "value" : self.jobData?.job_description ?? ""])
            
            self.tableView.reloadData()
            self.photoCollection.reloadData()
            self.manageView()
            
            ActivityIndicator.hide()
        }
    }
    
    func manageView(){
       
      
        if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
            self.userName.text = self.jobData?.user_name!.formatName()
            self.userImage.sd_setImage(with: URL(string: Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }else {
            self.userName.text = self.jobData?.user_name!.formatName()
            self.userImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        }
       /*
        if(self.jobData?.vendor_name != nil){
            self.viewAwardedTo.isHidden = false
            self.awardedToName.text = self.jobData?.vendor_name ?? ""
        }else {
            self.viewAwardedTo.isHidden = true
        }
        */
        
        self.jobTime.text = self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobDate.text = self.jobData?.job_date
        
     
       
        /*
        if(self.jobImage.count > 0){
            self.viewForPhoto.isHidden = false
           
        }
        if(self.jobData?.bids?.count == 0){
            self.viewCancelJob.isHidden = false
        }else {
             self.viewCancelJob.isHidden = true
        }
        if(self.jobImage.count == 0){
            self.viewPhotos.isHidden = true
        }else {
            self.viewPhotos.isHidden = false
        }
        */
    
        
    }
    
    //MARK: IBActions
    
    @IBAction func cancelAction(_ sender: Any) {
       let alert = UIAlertController(title: "Cancelar trabajo", message: "¿Estás seguro que quiere cancelar?", preferredStyle: .alert)
               
        alert.addAction(UIAlertAction(title: "Si", style: .default){ action in
           ActivityIndicator.show(view: self.view)
           let param = [
               "job_id":self.jobData?.job_id,
               "user_id":Singleton.shared.userInfo.user_id
               ] as? [String:Any]
           SessionManager.shared.methodForApiCalling(url: U_BASE + U_CANCEL_JOB, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
               ActivityIndicator.hide()
               self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Job Cancelled Successfully", yesTitle: nil, noTitle: nil, isNoHidden: true)
               Singleton.shared.jobData = []
                ActivityIndicator.hide()
               self.navigationController?.popViewController(animated: true)
               
           }
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
}

extension JobDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jobImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        cell.jobImage.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                 let imageView = UIImageView()
                let newImageView = UIImageView()
               newImageView.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .black
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                self.view.addSubview(newImageView)
                //self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
         }
         
         @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
             //self.navigationController?.isNavigationBarHidden = true
             self.tabBarController?.tabBar.isHidden = true
             sender.view?.removeFromSuperview()
         }
    

}



extension JobDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobDataProperties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataJobViewCell") as! DataJobViewCell
        let val = jobDataProperties[indexPath.row]
        
        cell.title.text = val["title"]
        cell.subtitle.text = val["value"]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
        myVC.jobId = self.jobData?.job_id
        myVC.bidDetail = self.jobData?.bids?[indexPath.row]
        self.navigationController?.pushViewController(myVC, animated: true)
        */
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         
        if self.hiddenHeader {
            if scrollView.contentOffset.y >= 50.0 {
                self.hiddenHeader = false
                UIView.animate(withDuration: 0.5) {
                    self.fakeHeader.alpha = 1.0
                }
            }
        } else {
            if scrollView.contentOffset.y < 50.0 {
                self.hiddenHeader = true
                UIView.animate(withDuration: 0.5) {
                    self.fakeHeader.alpha = 0.0
                }
            }
        }
        
        if self.hiddenAvatar {
            if scrollView.contentOffset.y < -30.0 {
                self.hiddenAvatar = false
                UIView.animate(withDuration: 0.5) {
                    self.userImageView.alpha = 1.0
                }
            }
        } else {
            if scrollView.contentOffset.y >= -30.0 {
                self.hiddenAvatar = true
                UIView.animate(withDuration: 0.5) {
                    self.userImageView.alpha = 0.0
                }
            }
        }
    }

}


/*
extension JobDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.jobData?.bids?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidTableView") as! BidTableView
        let val = self.jobData?.bids?[indexPath.row]
        cell.workerImage.sd_setImage(with: URL(string: val?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.workerName.text = val?.vendor_name
        cell.workerBid.text = "Countered Bid: $" +  (val?.counteroffer_amount ?? "0")
        cell.status.text = "User Occupation: " + (val?.vendor_occupation ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
        myVC.jobId = self.jobData?.job_id
        myVC.bidDetail = self.jobData?.bids?[indexPath.row]
        self.navigationController?.pushViewController(myVC, animated: true)
    }

}
*/


class BidTableView: UITableViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var workerName: DesignableUILabel!
    @IBOutlet weak var workerBid: DesignableUILabel!
    @IBOutlet weak var status: DesignableUILabel!
}

class DataJobViewCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

class DashboardCollection: UICollectionViewCell{
    //MARK: IBOutlets
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobName: DesignableUILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var deleteBtn: CustomButton!
    @IBOutlet weak var addBtn: CustomButton!
    
    var deleteButton: (()-> Void)? = nil
    var addButton: (()-> Void)? = nil
    
    @IBAction func deleteAction(_ sender: Any) {
        if let deleteButton = self.deleteButton {
            deleteButton()
        }
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        if let addButton = self.addButton {
            addButton()
        }
    }
    
}
