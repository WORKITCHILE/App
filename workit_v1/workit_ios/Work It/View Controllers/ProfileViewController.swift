//
//  ProfileViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SDWebImage
import GooglePlaces

class ProfileViewController: ImagePickerViewController, PickImage, SelectFromPicker, CaptureImage  {
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var userImageView : UIView!
    @IBOutlet weak var editButton : UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var footerView : UIView!
    @IBOutlet weak var pencilIcon : UIButton!
    
    private var profileData = UserInfo()
    private var userProfilePicture = ""
    private var userData : [[String:Any]] = []
    private var displayData : [[String:Any]] = []
    private var editMode = false
    private var docuymentUrl = ""
    private var images = ["camera"]

    
    private var categories: [String] = []
    private var typeImage = 0
    
    private var imagePath1 = ""
    private var imagePath2 = ""
    private var currentImage = 0
    private var isWorker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDelegate = self
        self.saveButton.isHidden = true
        
        let userInfo = Singleton.shared.userInfo
        isWorker = userInfo.type != "HIRE"
        
        self.pencilIcon.isHidden = true
        
        self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 26.0)
        
        if let filepath = Bundle.main.path(forResource: "user_profile_config", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)!
                if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                {
                    userData = (json["data"] as?  [[String:Any]])!
                   
                }
         
            } catch {
              
            }
        }
        self.setNavigationBar()
        self.tableList.delegate = self
        self.tableList.dataSource = self
        self.tableList.separatorColor = UIColor.clear
        

        self.userName.text = "\(userInfo.name!) \(userInfo.father_last_name!)"
        self.userProfilePicture = userInfo.profile_picture ?? ""
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        
        userInfo.work_images.forEach { 
            self.images.append($0)
        }
        
        if(userInfo.id_image1 != nil){
            self.imagePath1 = userInfo.id_image1 ?? ""
        }
        
        if(userInfo.id_image2 != nil){
            self.imagePath2 = userInfo.id_image2 ?? ""
        }
        
        self.userImageView.defaultShadow()
        
        self.getProfileData()
        self.getCategoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }

    func getCategoryData(){
          let url = "\(U_BASE)\(U_GET_CATEGORIES)"
          SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetCategory.self, requestCode: U_GET_CATEGORIES) { (response) in
            self.categories = (response?.data.map({
                $0.category_name!
            }))!
               
          }
      }
      
    
    func geImagePath(image: UIImage, imagePath: String, imageData: Data) {
        
        if(typeImage == 2){
            self.userImage.image = image
        }
        
        self.uplaodUserImage(imageName: imagePath, image: imageData, type: typeImage) { [self] (val) in
            if(self.typeImage == 2){
                self.userProfilePicture = val
            } else if(self.typeImage == 4){
                self.images.append(val)
                self.tableList.reloadData()
            }
        }
     
    }
    
    func selectedItem(name: String, id: Int) {
        self.displayData[11]["value"] = name
        self.tableList.reloadData()
    }
    
    func getProfileData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
            self.profileData = response!.data!
            Singleton.shared.userInfo = response!.data!
            Singleton.saveUserInfo(data:Singleton.shared.userInfo)
            self.manageView()
            ActivityIndicator.hide()
        }
    }
    
    func manageView(){
    
        
        userData[1]["value"] = self.profileData.email
        userData[2]["value"] = self.profileData.id_number
        userData[3]["value"] = self.profileData.name
        userData[4]["value"] = self.profileData.father_last_name
        userData[5]["value"] = self.profileData.mother_last_name
        userData[6]["value"] = self.profileData.contact_number
        userData[7]["value"] = self.profileData.nationality
        userData[8]["value"] = self.profileData.address
        userData[9]["value"] = self.profileData.address_number
        userData[10]["value"] = self.profileData.address_reference
        userData[11]["value"] =  self.profileData.occupation
        userData[12]["value"] =  self.profileData.profile_description
        userData[13]["value"] =  self.profileData.background_document
        self.docuymentUrl = self.profileData.background_document ?? ""
      
        displayData = userData.filter({
            let isWorkerField = ($0["workerField"] as? Bool)!
            return (isWorkerField && isWorker) || !isWorkerField
        })
        
  
        self.tableList.reloadData()

    }
    
    func uploadImage(){
        let alert = UIAlertController(title: "Eliger una imagen desde", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: IBActions
    @IBAction func editAction(_ sender: Any) {
        ActivityIndicator.show(view: self.view)
        
      
        let contactNumber = self.displayData[isWorker ? 6 : 5]["value"] as! String
        let address = self.displayData[isWorker ? 8 : 7]["value"] as! String
        let addressNumber = self.displayData[isWorker ? 9 : 8]["value"] as! String
        let addressReference = self.displayData[isWorker ? 10 : 9]["value"] as! String
      
        
        var param : [String: Any] = [
            "user_id": Singleton.shared.userInfo.user_id ?? "",
            "email":  Singleton.shared.userInfo.email ?? "",
            "contact_number": contactNumber,
            "address": address,
            "address_number": addressNumber,
            "address_reference": addressReference,
            "profile_picture": self.userProfilePicture,
            "work_images": self.images.filter{ $0 != "camera" },
            "background_document": self.docuymentUrl,
            "profile_description": ""
        ]
        
        if(isWorker){
            let occupation = self.displayData[ 11]["value"] as! String
            let profileDescription = self.displayData[12]["value"] as! String
            param["occupation"] = occupation
            param["profile_description"] = profileDescription
        }
        
        debugPrint("PARAMS", param)
    
        
        let url = "\(U_BASE)\(U_EDIT_PROFILE)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_EDIT_PROFILE) { response in
            
            self.getProfileData()
            ActivityIndicator.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func addImage(_ sender: Any) {
        if(editMode == false) { return }
        self.typeImage = 2
        self.uploadImage()

    }
    
    @IBAction func saveMode(_ sender : Any) {
        
        self.editMode = true
        self.saveButton.isHidden = false
        self.saveButton.alpha = 0.0
        self.pencilIcon.isHidden = false
        
        self.footerView.frame = CGRect(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 90.0)
        
        UIView.animate(withDuration: 0.5, delay: 0.0) {
            self.editButton.alpha = 0.0
            self.saveButton.alpha = 1.0
        } completion: { isCompleted in
            self.editButton.isEnabled = false
        }

        self.tableList.reloadData()
    }
    
    func showCaptureImage(img: UIImage) {
        let image_path = "\(NSDate().timeIntervalSince1970)_\(UUID().uuidString).png"
       
     
       
        self.uplaodUserImage(imageName: image_path , image: img.pngData()!, type: 1) { [self] val in
           
            if(self.currentImage == 0){
                self.imagePath1 = val
            } else if(self.currentImage == 1){
                self.imagePath2 = val
            }
            self.tableList.reloadData()
            
            
            
        }
     
    }
}

extension ProfileViewController:   UIDocumentPickerDelegate {
    
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    
        if(urls.count > 0){
        
          do {
            let components = urls[0].absoluteString.split(separator: "/").map { String($0) }
                self.displayData[13]["value"] = components.last
                self.tableList.reloadData()

                let documentData = try Data(contentsOf: urls[0])
                self.uplaodDocument(imageName: "document", image: documentData){ val in
                    self.docuymentUrl = val
                }

          } catch {
             
          }
          
        }
  }
}

extension ProfileViewController: FieldTableViewCellDelegate{
    
    func tapCollectionItem(indexCell: IndexPath) {
        
        if(indexCell.row == 0){
            if(self.editMode){
                self.typeImage = 4
                self.uploadImage()
            }
        }
    }
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
       
        let userInfo = Singleton.shared.userInfo
        let isWorker = userInfo.type != "HIRE"
        
        if(isWorker){
            
            if(indexCell.row == 13){
                if(!editMode){
                  return
                }
               let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
               importMenu.delegate = self
               importMenu.modalPresentationStyle = .formSheet
               self.present(importMenu, animated: true, completion: nil)
               
             } else if(indexCell.row == 11){
                if(!editMode){
                  return
                }
                let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
                myVC.modalPresentationStyle = .overFullScreen
                myVC.pickerDelegate = self
                myVC.pickerData = self.categories
                self.navigationController?.present(myVC, animated: false, completion: nil)
            }
            
        }
        
        if(indexCell.row == 0){
          
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
            self.navigationController?.pushViewController(myVC, animated: true)
            
        }else if(indexCell.row == ((isWorker) ? 8 : 7)){
            if(!editMode){
              return
            }
            
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self

            let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue) |
                GMSPlaceField.addressComponents.rawValue |
                GMSPlaceField.formattedAddress.rawValue)!
            autocompleteController.placeFields = fields
 
            let filter = GMSAutocompleteFilter()
            filter.type = .noFilter
            autocompleteController.autocompleteFilter = filter
        
            autocompleteController.modalPresentationStyle = .overFullScreen
            present(autocompleteController, animated: true, completion: nil)
            
        }
    }
    
    func textFieldDidEnd(indexCell: IndexPath, text: String, _ tag : Int){
      
        displayData[indexCell.row]["value"] = text
        self.tableList.reloadData()
    }
}

extension ProfileViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        

        
        self.displayData[((isWorker) ? 8 : 7)]["value"] = "\(place.formattedAddress ?? "")"
        self.tableList.reloadData()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = self.displayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ((field["cell"] as? String)!)) as! FieldTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        let editable = (field["editable"] as! Bool)
        
        if(cell.iconImage != nil){
            cell.iconImage.image = UIImage(named: (field["icon"] as! String))
        }
        
        let value : String = field["value"] as! String
        let cellType : String = field["cell"] as! String
        
        if(cellType == "fieldData" || cellType == "fieldDataButton" || cellType == "fieldDataWithoutIcon" || cellType == "fieldDataWithPrefix"){
         
            cell.fieldTextField.placeholder = (field["placeholder"] as! String)
            cell.fieldTextField.text = value
            cell.fieldTextField.isEnabled = editMode && editable
            
            cell.fieldTextField.textColor = (editMode && editable) ? UIColor.black : UIColor(named: "border")
            
        } else if(cellType == "fieldDataBigText") {
            
            if(value == ""){
                cell.fieldTextView.text = (field["placeholder"] as! String)
            } else {
                cell.fieldTextView.text = value
            }
          
           
        } else if(cellType == "FieldDataButtons") {
            
            if(cell.button1 != nil && self.imagePath1 != ""){
                cell.button1.sd_setBackgroundImage(with: URL(string: self.imagePath1), for: .normal)
                
            }
            
            if(cell.button2 != nil && self.imagePath2 != ""){
                cell.button2.sd_setBackgroundImage(with: URL(string: self.imagePath1), for: .normal)
            }
        } else if(cellType == "fieldCollection"){
            cell.images = images
            cell.reloadData()
        }
        
        if(editMode && editable){
            cell.borderEditable()
        } else {
            cell.borderNotEditable()
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let field = self.displayData[indexPath.row]
        let cellType : String = field["cell"] as! String
        if(cellType == "fieldData" || cellType == "fieldDataButton" || cellType == "fieldDataWithPrefix" || cellType == "fieldDataWithoutIcon"){
            return 61.0
        } else if(cellType == "fieldDataBigText") {
            return 188.0
        } else if(cellType == "fieldCollection") {
            return 160.0
        } else {
            return 155.0
        }
    }
    
}
