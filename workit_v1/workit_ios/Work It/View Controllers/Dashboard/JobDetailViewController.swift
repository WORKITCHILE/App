//
//  JobDetailViewController.swift
//  Work It
//
//  Created by qw on 08/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import MapKit

class JobDetailViewController: UIViewController{

    
    //MARK: IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var fakeHeader: UIImageView!
    @IBOutlet weak var userImageView : View!
    @IBOutlet weak var cancelContainer: UIView!
    @IBOutlet weak var bidContainer: UIView!
    @IBOutlet weak var photosContainer: UIView!
    @IBOutlet weak var cardView1: UIView!
    @IBOutlet weak var cardView2: UIView!
    @IBOutlet weak var counterBid : UITextField!
    @IBOutlet weak var comment : UITextView!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var stackHeight : NSLayoutConstraint!
    
    @IBOutlet weak var footer : UIView!

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    
    var jobId: String?
    var jobData: GetJobResponse?
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
        
        self.cardView1.defaultShadow()
        self.cardView2.defaultShadow()
    }
    
 
    
    func getJobDetail(){
        
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(self.jobId ?? "")"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { response in
            
            
            self.jobData = response.data
            
            self.jobImage = self.jobData!.images ?? []
            
            let location = CLLocation(latitude: Double( (self.jobData?.job_address_latitude)!), longitude:  Double(self.jobData?.job_address_longitude ?? 0.0))
         
            self.centerMapOnLocation(location: location)
            
            let category = self.jobData?.category_name! ?? ""
            let subcategory = self.jobData?.subcategory_name! ?? ""
            
            self.cancelContainer.isHidden = self.jobData?.user_id != Singleton.shared.userInfo.user_id
            self.bidContainer.isHidden = self.jobData?.user_id == Singleton.shared.userInfo.user_id
            self.photosContainer.isHidden = self.jobImage.count == 0
            
            self.stackHeight.constant = ((self.jobImage.count == 0) ? 680 : 860)
            
            self.footer.frame = CGRect(x: self.footer.frame.origin.x, y: self.footer.frame.origin.y, width: self.footer.frame.size.width, height: ((self.jobImage.count == 0) ? 680 : 860))
            self.view.layoutIfNeeded()
            
            self.counterBid.text = "$\(self.jobData?.initial_amount?.formattedWithSeparator ?? "")"
            
            self.jobDataProperties.append(["title": "Nombre del cliente", "value" : self.jobData?.user_name ?? "" ])
            self.jobDataProperties.append(["title": "Precio", "value" : "$" + "\(self.jobData?.initial_amount ?? 0)" ])
            
            self.jobDataProperties.append(["title": "Publicado", "value" : (self.jobData?.created_at ?? 0).toFormatDate() ])
            self.jobDataProperties.append(["title": "Categoria", "value" : category])
            
            if(category != subcategory){
                self.jobDataProperties.append(["title": "Subcategoria", "value" : subcategory])
            }
            
            self.jobDataProperties.append(["title": "Dirección", "value" : self.jobData?.job_address ?? ""])
            
            self.jobDataProperties.append(["title": "Enfoque de trabajo", "value" : self.jobData?.job_approach ?? ""])
            self.jobDataProperties.append(["title": "Descripción", "value" : self.jobData?.job_description ?? ""])
            
            self.tableView.reloadData()
            self.photoCollection.reloadData()
            self.manageView()
            
            ActivityIndicator.hide()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func manageView(){
       
      
        if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
            self.userName.text = self.jobData?.job_name!
            self.userImage.sd_setImage(with: URL(string: Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        }else {
            self.userName.text = self.jobData?.user_name!.formatName()
            self.userImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        }
   
        self.jobTime.text = self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobDate.text = self.jobData?.job_date
        
        
    }
    
    //MARK: IBActions
    
    @IBAction func cancelAction(_ sender: Any) {
       let alert = UIAlertController(title: "Cancelar trabajo", message: "¿Estás seguro que quiere cancelar?", preferredStyle: .alert)
               
        alert.addAction(UIAlertAction(title: "Si", style: .default){ [self] _ in
            self.cancelJob()
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func cancelJob(){
        ActivityIndicator.show(view: self.view)
        let param = [
           "job_id":self.jobData?.job_id,
           "user_id":Singleton.shared.userInfo.user_id
        ] as? [String:Any]
        
        let url = "\(U_BASE)\(U_CANCEL_JOB)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
           ActivityIndicator.hide()
        
            self.navigationController?.popViewController(animated: true)
           
        }
    }
    
    @IBAction func plus(_ sender : AnyObject){
        let currentBid = self.counterBid.text?.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        var plustCurrentBid  = Int(currentBid!) ?? 0
        plustCurrentBid = max(plustCurrentBid + 1000, 0)
        self.counterBid.text = "$\(plustCurrentBid.formattedWithSeparator)"
    }
    
    @IBAction func minus(_ sender : AnyObject){
        let currentBid = self.counterBid.text?.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        var plustCurrentBid  = Int(currentBid!) ?? 0
        plustCurrentBid = max(plustCurrentBid - 1000, 0)
        self.counterBid.text = "$\(plustCurrentBid.formattedWithSeparator)"
    }
    
    @IBAction func postBid(_ sender : AnyObject){
        postBid()
    }
    
    
    func postBid(){
      
        
        ActivityIndicator.show(view: self.view)
        
        let currentBid = self.counterBid.text?.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        let vendor_name = "\(Singleton.shared.userInfo.name) \(Singleton.shared.userInfo.father_last_name)"
        
        var param = [
            "job_id": self.jobData?.job_id,
            "job_name": self.jobData?.job_name,
            
            "category_name": self.jobData?.category_name,
            "subcategory_name":self.jobData?.subcategory_name,
            "user_id": self.jobData?.user_id,
            "user_name": self.jobData?.user_name,
            "user_image":self.jobData?.user_image,
            "counteroffer_amount": currentBid,
            "comment": self.comment.text ?? ""
            ] as? [String:Any]
        
        param?["vendor_name"] = vendor_name
        param?["vendor_image"] = Singleton.shared.userInfo.profile_picture
        param?["average_rating"] = Singleton.shared.userInfo.average_rating
        param?["vendor_id"] = Singleton.shared.userInfo.user_id
        param?["vendor_occupation"] =  Singleton.shared.userInfo.occupation
        param?["vendor_images"] = Singleton.shared.userInfo.work_images
        param?["marketplace"] =  Singleton.shared.userInfo.marketplace
        param?["have_vendor_document"] = ((Singleton.shared.userInfo.background_document != nil) && Singleton.shared.userInfo.background_document != "")
      
        let url = "\(U_BASE)\(U_PLACE_BID)"
    
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_PLACE_BID) { (response) in
            ActivityIndicator.hide()
            /*
            self.openSuccessPopup(img:#imageLiteral(resourceName: "tick") , msg: "Bid Place Successfully\n Please wait for the owner to accept.", yesTitle: nil, noTitle: nil, isNoHidden: true)
            self.navigationController?.popViewController(animated: true)
            */
        }
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
                 
                let newImageView = UIImageView()
               newImageView.sd_setImage(with: URL(string: self.jobImage[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "camera"))
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .black
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                self.view.addSubview(newImageView)
                self.tabBarController?.tabBar.isHidden = true
         }
         
         @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
             self.tabBarController?.tabBar.isHidden = true
             sender.view?.removeFromSuperview()
         }
    

}



extension JobDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
     
        if(indexPath.row >= self.jobDataProperties.count){
            return 152.0
        }
        
        return 90.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobDataProperties.count + ((self.jobData != nil) ? (self.jobData?.bids!.count)! : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var isBid = false
        if(indexPath.row >= self.jobDataProperties.count){
            isBid = true
        }
        
        let identifier = isBid ? "JobTableView" : "DataJobViewCell"
        
        if(isBid == false){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DataJobViewCell
            let val = jobDataProperties[indexPath.row]
        
      
            cell.title.text = val["title"]?.uppercased()
            cell.subtitle.text = val["value"]
            cell.card.defaultShadow()
            cell.card.layer.cornerRadius = 10
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! JobTableView
            let val = self.jobData?.bids![indexPath.row - self.jobDataProperties.count]
            
            cell.jobName.text = val?.job_name.uppercased()
            
            cell.userImage.sd_setImage(with: URL(string: (val?.vendor_image)! ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val?.vendor_name
        
            cell.jobDate.text = val?.job_date
            cell.jobTime.text = self.convertTimestampToDate(val?.job_time ?? 0, to: "h:mm a")
            cell.card.defaultShadow()
            //cell.verify.isHidden = !(val?.have_document! ?? false)
      
            
            let formater = NumberFormatter()
            formater.groupingSeparator = "."
            formater.numberStyle = .decimal
            let formattedNumber = formater.string(from: NSNumber(value: val!.initial_amount) )
            
            
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
            
        
            return cell
        }
       
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
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
    @IBOutlet weak var card: UIView!
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
