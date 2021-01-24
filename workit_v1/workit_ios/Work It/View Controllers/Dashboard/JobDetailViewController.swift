//
//  JobDetailViewController.swift
//  Work It
//
//  Created by qw on 08/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import MapKit
import SwiftPhotoGallery

class JobDetailViewController: UIViewController{

    
    //MARK: IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var fakeHeader: UIImageView!
    @IBOutlet weak var userImageView : View!

    @IBOutlet weak var blankLoadingView : UIView!
    @IBOutlet weak var footer : UIView!

    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    
    @IBOutlet weak var verifyIcon : UIImageView!
    
    var jobId: String?
    var jobData: GetJobResponse?
    var jobImage = [String]()
    
    var jobDataProperties : [[String: Any]] = []
    
    var hiddenHeader = true
    var hiddenAvatar = true
    
    var modeView = 0
    var comment = ""
    var location : CLLocation?
    var counterBid = ""
    var fromNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        self.verifyIcon.isHidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        self.blankLoadingView.isHidden = false
        
        if(fromNotification){
            self.setNavigationBarForClose()
            self.setTransparentHeader()
        } else {
            self.setNavigationBar()
        }
        
        self.fakeHeader.alpha = 0.0
        self.userImageView.defaultShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getJobDetail()
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {

        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
 
    func getProfileData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
           
            Singleton.shared.userInfo = response!.data!
            Singleton.saveUserInfo(data:Singleton.shared.userInfo)
      
            ActivityIndicator.hide()
        }
    }
    
    
    func getJobDetail(){
        
        ActivityIndicator.show(view: self.view)
        let mode = (modeView == 1) ? U_GET_SINGLE_JOB_VENDOR : U_GET_SINGLE_JOB_OWNER
        let url = "\(U_BASE)\(mode)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(self.jobId ?? "")"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) { [self] response in
            
         
            if(response == nil || response?.data == nil){
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            
            self.jobData = response?.data
            
     
            
            self.jobImage = self.jobData!.images ?? []
            
            let location = CLLocation(latitude: Double( (self.jobData?.job_address_latitude)!), longitude:  Double(self.jobData?.job_address_longitude ?? 0.0))
         
            self.centerMapOnLocation(location: location)
            
          
            
            let category = self.jobData?.category_name! ?? ""
            let subcategory = self.jobData?.subcategory_name! ?? ""
            let address_number = self.jobData?.job_address_number
            let address_reference = self.jobData?.job_address_reference
            
          
            if(self.jobData?.my_bid != nil && ((self.jobData?.my_bid?.counteroffer_amount) != nil)){
                self.counterBid = "$\(self.jobData?.my_bid?.counteroffer_amount.formattedWithSeparator ?? "")"
            } else {
                self.counterBid = "$\(self.jobData?.initial_amount?.formattedWithSeparator ?? "")"
            }
           
           
            self.jobDataProperties = []
            self.jobDataProperties.append(["title": "Nombre del cliente", "type":"property", "value" : self.jobData?.user_name ?? "" ])
            self.jobDataProperties.append(["title": "Precio", "type":"property", "value" : "$\((self.jobData?.initial_amount ?? 0).formattedWithSeparator)" ])
         
            self.jobDataProperties.append(["title": "Publicado", "type":"property", "value" : (self.jobData?.created_at ?? 0).toFormatDate() ])
            self.jobDataProperties.append(["title": "Categoria", "type":"property", "value" : category])
            
            if(category != subcategory){
                self.jobDataProperties.append(["title": "Subcategoria", "type":"property", "value" : subcategory])
            }
            
            self.jobDataProperties.append(["title": "Dirección", "type":"property", "value" : self.jobData?.job_address ?? ""])
            
            
            if(address_number != nil && address_number != ""){
                self.jobDataProperties.append(["title": "Casa / Departamento", "type":"property", "value" : "\(address_number ?? "")"])
            }
            
            if(address_reference != nil && address_reference != ""){
                self.jobDataProperties.append(["title": "Referencia", "type":"property", "value" : "\(address_reference ?? "")"])
            }
            
            self.jobDataProperties.append(["title": "Tipo de trabajo", "type":"property", "value" : self.jobData?.job_approach ?? ""])
            self.jobDataProperties.append(["title": "Descripción", "type":"property", "value" : self.jobData?.job_description ?? ""])
            
            if(self.jobImage.count > 0){
                self.jobDataProperties.append(["title": "FOTOS", "type":"fieldCollection"])
            }
            
            if(self.modeView == 0){
                if(self.jobData?.bids != nil && (self.jobData?.bids!.count ?? 0) > 0){
                    self.jobDataProperties.append(["title": "Ofertas", "type":"title"])
                    self.jobData?.bids?.forEach{
                        self.jobDataProperties.append(["type":"Bid", "value": $0])
                    }
                } else {
                    self.jobDataProperties.append(["title": "Ofertas", "type":"titleEmpty"])
                }
            }
            
           
            
            if(self.modeView == 1){
                self.jobDataProperties.append(["title": "Localización del trabajo", "type":"mapField"])
                self.jobDataProperties.append(["title": "ContraOferta", "type":"counterOfferField"])
            }
            
            if(self.jobData?.user_id == Singleton.shared.userInfo.user_id){
                self.jobDataProperties.append(["title": "Cancelar", "type":"ButtonField"])
            } else {
                
                if((self.jobData?.user_id == Singleton.shared.userInfo.user_id || self.jobData?.is_bid_placed == 1) == false){
                    self.jobDataProperties.append(["title": "Ofertar", "type":"ButtonField"])
                }
                
               
            }
            
          
            self.tableView.reloadData()
           
            self.manageView()
            
            self.blankLoadingView.isHidden = true
  
            
            ActivityIndicator.hide()
            self.getProfileData()
        }
    }
  
    
    func centerMapOnLocation(location: CLLocation) {
       
        self.location = location
        self.tableView.reloadData()
    }
    
    func manageView(){
       
      
        if(Singleton.shared.userInfo.user_id == self.jobData?.user_id){
            self.userName.text = self.jobData?.job_name!
            self.userImage.sd_setImage(with: URL(string: Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            
            self.verifyIcon.isHidden = !(self.jobData?.have_document ?? false)
        }else {
            self.userName.text = "\(self.jobData?.user_name! ?? "")"
            self.userImage.sd_setImage(with: URL(string: self.jobData?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            if(modeView == 1){
                self.verifyIcon.isHidden = !(self.jobData?.have_document ?? false)
            } else {
                self.verifyIcon.isHidden = !(self.jobData?.have_vendor_document ?? false)
            }
           
        }
   
        self.jobTime.text = self.convertTimestampToDate(self.jobData?.job_time ?? 0, to: "h:mm a")
        self.jobDate.text = self.jobData?.job_date
        
        
    }
    
    func showCommisionAlert(){
        let alert = UIAlertController(title: "Workit", message: "¿Recuerda que el valor de cada servicio incluye comisión del 9,3%", preferredStyle: .alert)
                  
           alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in

           })
      
           self.present(alert, animated: true)
    }
    
    //MARK: IBActions
    
    func cancelAction() {
    
       let alert = UIAlertController(title: "Cancelar trabajo", message: "¿Estás seguro que quiere cancelar?", preferredStyle: .alert)
               
        alert.addAction(UIAlertAction(title: "Si", style: .default){ [self] _ in
            self.cancelJob()
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func cancelJob(){
       
        ActivityIndicator.show(view: self.view)
        let param : [String : Any] = [
           "job_id": self.jobData?.job_id,
           "user_id": Singleton.shared.userInfo.user_id
        ]
        
        let url = "\(U_BASE)\(U_CANCEL_JOB)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
           ActivityIndicator.hide()
        
            self.navigationController?.popViewController(animated: true)
           
        }
    }
    
    func plusAction(){
    
        let currentBid = self.counterBid.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        var plustCurrentBid  = Int(currentBid) ?? 0
        plustCurrentBid = max(plustCurrentBid + 1000, 0)
        self.counterBid = "$\(plustCurrentBid.formattedWithSeparator)"
        self.tableView.reloadData()
    }
    
    func minusAction(){
    
        let currentBid = self.counterBid.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        var plustCurrentBid  = Int(currentBid) ?? 0
        plustCurrentBid = max(plustCurrentBid - 1000, 0)
        self.counterBid = "$\(plustCurrentBid.formattedWithSeparator)"
        self.tableView.reloadData()
     
    }
    
     func postBidAction(){
        let userInfo = Singleton.shared.userInfo
        if(userInfo.type == "HIRE"){
            isWorkerValidation()
            return
        }
        
        if(userInfo.is_bank_details_added != 1){
            validateBankAccount()
            return
        }
        postBid()
    }
    
    func validateBankAccount(){
 
        let alert = UIAlertController(title: "Workit", message: "Agregue su cuenta bancaria antes de continuar", preferredStyle: .alert)
                  
           alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
            
            let storyboard  = UIStoryboard(name: "AccountAndCredits", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "AccountDetailViewController") as! AccountDetailViewController
            
            self.navigationController?.pushViewController(myVC, animated: true)
            
           })
         
           alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

           self.present(alert, animated: true)
        
     
    }
    
    func isWorkerValidation(){
        let alert = UIAlertController(title: "Workit", message: "Aún no has completado tu perfil worker, ¿quieres hacerlo ahora?", preferredStyle: .alert)
                  
           alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
            
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "BecomeWorkerViewController") as! BecomeWorkerViewController
            
            self.navigationController?.pushViewController(myVC, animated: true)
            
           })
         
           alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

           self.present(alert, animated: true)
         
    }
    
    func postBid(){
      
        ActivityIndicator.show(view: self.view)
        
        let currentBid = self.counterBid.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "$", with: "")
        
        
        let vendor_name = "\(Singleton.shared.userInfo.name ?? "") \(Singleton.shared.userInfo.father_last_name ?? "")"
        
        var param : [String:Any] = [
            "job_id": self.jobData?.job_id ?? "",
            "job_name": self.jobData?.job_name ?? "" as Any,
            "category_name": self.jobData?.category_name ?? "" as Any,
            "subcategory_name":self.jobData?.subcategory_name ?? "" as Any,
            "user_id": self.jobData?.user_id ?? "" as Any,
            "user_name": self.jobData?.user_name ?? "" as Any,
            "user_image":self.jobData?.user_image ?? "" as Any,
            "counteroffer_amount": Int(currentBid) as Any,
            "comment": self.comment
        ]

        param["have_document"] = self.jobData?.have_document ?? false
        param["vendor_name"] = vendor_name
        param["vendor_image"] = Singleton.shared.userInfo.profile_picture
        param["average_rating"] = Singleton.shared.userInfo.average_rating
        param["vendor_id"] = Singleton.shared.userInfo.user_id
        param["vendor_occupation"] =  Singleton.shared.userInfo.occupation
        param["vendor_images"] = Singleton.shared.userInfo.work_images
        param["vendor_description"] = Singleton.shared.userInfo.profile_description
        param["marketplace"] =  Singleton.shared.userInfo.marketplace
        param["have_vendor_document"] = ((Singleton.shared.userInfo.background_document != nil) && Singleton.shared.userInfo.background_document != "")
      
        let url = "\(U_BASE)\(U_PLACE_BID)"
    
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_PLACE_BID) { (response) in
            
     
            ActivityIndicator.hide()
            self.showSuccessAlert()
          
            
           
        }
    }
    
    func showSuccessAlert(){
        let alert = UIAlertController(title: "Workit", message: "Tú oferta se realizo correctamente", preferredStyle: .alert)
                  
        alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
         
          
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bidDetail = segue.destination as! BidDetailViewController
      
        let rowIndex = (self.tableView.indexPathForSelectedRow?.row ?? 0)
        let bid = self.jobDataProperties[rowIndex]["value"] as! BidResponse
        
        bidDetail.bidData = bid
        bidDetail.jobData = self.jobData
    }
    
}

extension JobDetailViewController: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate{
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return self.jobImage.count
    }

    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: self.jobImage[forIndex]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        return  newImageView.image
    }

    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
}

extension JobDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    

        let value = self.jobDataProperties[indexPath.row]
        
        let title = value["type"] as! String
        
        if(title == "title"){
            return 44.0
        } else if(title == "titleEmpty"){
            return 100.0
        } else if(title == "Bid"){
            return 152.0
        } else if(title == "fieldCollection"){
            return 160.0
        } else if(title == "ButtonField"){
            return 76.0
        }else if(title == "mapField"){
            return 195.0
        } else if(title == "counterOfferField"){
            return 250.0
        }
        
        return 90.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.jobDataProperties.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let val = jobDataProperties[indexPath.row]
        let type = val["type"] as! String
        
        if(type == "fieldCollection"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCollection") as! FieldTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            cell.images = self.jobImage
            cell.card.defaultShadow()
            cell.reloadData()
            return cell
        } else if(type == "ButtonField"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonField") as! FieldTableViewCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.button1.setTitle("\(val["title"] as! String)", for: .normal)
 
            return cell
        }else if(type == "counterOfferField"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "counterOfferField") as! FieldTableViewCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.placeHolder = "Escribe algo"
            let isEnabled = !(self.jobData?.user_id == Singleton.shared.userInfo.user_id || self.jobData?.is_bid_placed == 1)
            cell.button1.isEnabled = isEnabled
            cell.button2.isEnabled = isEnabled
            cell.fieldTextField.isEnabled = isEnabled
            cell.fieldTextView.isEditable = isEnabled
            
            cell.fieldTextField.text = counterBid
            cell.fieldTextField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
            cell.card.defaultShadow()
            return cell
        } else if(type == "mapField"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapField") as! FieldTableViewCell
            cell.indexPath = indexPath
            cell.setLocation(self.location!)
            cell.card.defaultShadow()
            return cell
        }  else if(type == "Bid"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
            let bid = val["value"] as! BidResponse
            
            cell.jobName.text = bid.vendor_name.uppercased()
            cell.category.text = bid.vendor_occupation
            
            cell.userImage.sd_setImage(with: URL(string: (bid.vendor_image)! ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            
            cell.card.defaultShadow()
            cell.verify.isHidden = !(bid.have_vendor_document ?? false)
      
            if(bid.owner_status == "REJECTED"){
                cell.statusLabel.text = "Oferta rechazada"
                cell.statusLabel.textColor = UIColor(named: "calendar_red")
            } else {
                cell.statusLabel.text =  "Contraoferta"
                cell.statusLabel.textColor = UIColor(named: "calendar_blue")
            }
           
            
            let formater = NumberFormatter()
            formater.groupingSeparator = "."
            formater.numberStyle = .decimal
            let formattedNumber = formater.string(from: NSNumber(value: bid.counteroffer_amount) )
            
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
            
        
            return cell
        }
        
        var identifier = "DataJobViewCell"
        
        let title : String = "\(val["title"] ?? "")"
        
        if(type == "title"){
            identifier = "bidTitle"
        } else if(type == "titleEmpty"){
            identifier = "bidTitleEmpty"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DataJobViewCell
       
        if(type != "title" && type != "titleEmpty"){
            
            cell.title.text = title.uppercased()
            if(cell.subtitle != nil && val["value"] != nil){
                cell.subtitle.text = (val["value"] as! String)
            }
            cell.card.defaultShadow()
            cell.card.layer.cornerRadius = 10
        }
       
        return cell
        
    

     
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



extension JobDetailViewController : FieldTableViewCellDelegate{
   
    
    func tapCollectionItem(indexCell: IndexPath) {
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)

        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
        gallery.currentPage = indexCell.row

        present(gallery, animated: true, completion: nil)
    }
    
    func tapCollectionDeleteItem(indexCell: IndexPath){
      
    }
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
        
        if(tagButton == 0){
            if(modeView == 0){
                cancelAction()
            } else {
                postBidAction()
            }
        } else if(tagButton == 1000){
            showCommisionAlert()
        } else if(tagButton == 1001){
            minusAction()
        }else if(tagButton == 1002){
            plusAction()
        }
      
    }
    
    func textFieldDidEnd(indexCell: IndexPath, text: String, _ tag: Int){
        if(tag == 2001){
            self.counterBid = text
        }
      
    }
    
    func textChange(indexCell: IndexPath, textField: UITextField, range: NSRange, string: String) {
        
        
       
    }
    
    func changeTextView(indexCell: IndexPath,text: String){
        self.comment = text
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
