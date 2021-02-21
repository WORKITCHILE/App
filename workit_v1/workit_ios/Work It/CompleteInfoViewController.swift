//
//  CompleteInfoViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 30-01-21.
//  Copyright © 2021 qw. All rights reserved.
//


import UIKit
import SDWebImage
import GooglePlaces


protocol CompleteInfoDelegate {
    func complete()
}

class CompleteInfoViewController: ImagePickerViewController, PickImage  {
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var userImageView : UIView!

    
    private var profileData = UserInfo()
    private var userProfilePicture = ""
    private var userData : [[String:Any]] = []
    private var displayData : [[String:Any]] = []
    private var docuymentUrl = ""
 
    private var categories: [String] = []
    private var typeImage = 0
    
    private var imagePath1 = ""
    private var imagePath2 = ""
    private var currentImage = 0
    
    var delegate : CompleteInfoDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDelegate = self
      
        
        let userInfo = Singleton.shared.userInfo
        
        
        if let filepath = Bundle.main.path(forResource: "user_complete_config", ofType: "json") {
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
        
    
        if(userInfo.id_image1 != nil){
            self.imagePath1 = userInfo.id_image1 ?? ""
        }
        
        if(userInfo.id_image2 != nil){
            self.imagePath2 = userInfo.id_image2 ?? ""
        }
        
        self.userImageView.defaultShadow()
        
        self.getProfileData()
        self.setNavigationBarForClose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }
    
    func geImagePath(image: UIImage, imagePath: String, imageData: Data) {
        
        if(typeImage == 2){
            self.userImage.image = image
        }
        
        self.uplaodUserImage(imageName: imagePath, image: imageData, type: typeImage) { [self] (val) in
            if(self.typeImage == 2){
                self.userProfilePicture = val
            }
        }
     
    }
    
    func selectedItem(name: String, id: Int) {
      
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
    
        
     
      
        self.docuymentUrl = self.profileData.background_document ?? ""
      
        displayData = userData
        
  
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
       
        
        let contactNumber = self.displayData[0]["value"] as! String
        let country = self.displayData[1]["value"] as! String
        let address = self.displayData[2]["value"] as! String
        let addressNumber = self.displayData[3]["value"] as! String
        let addressReference = self.displayData[4]["value"] as! String
      
        
        if(contactNumber.isEmpty){
            Singleton.shared.showToast(text: "Ingresa un número de teléfono")
            return
        } else if(contactNumber.isValidPhone()){
            Singleton.shared.showToast(text: "Ingresa un número de teléfono válido")
            return
        } else if(country.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu pais")
            return
        } else if(address.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu dirección")
            return
        }
        
        ActivityIndicator.show(view: self.view)
        
        let param : [String: Any] = [
            "user_id": Singleton.shared.userInfo.user_id ?? "",
            "contact_number": contactNumber,
            "country": country,
            "address": address,
            "address_number": addressNumber,
            "address_reference": addressReference,
        ]
    
        let url = "\(U_BASE)\(U_COMPLETE_PROFILE)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_EDIT_PROFILE) { response in
            
            self.getProfileData()
            ActivityIndicator.hide()
            self.navigationController?.dismiss(animated: true, completion: {
                if(self.delegate != nil){
                    self.delegate?.complete()
                }
            })
        }
    }

    
   
}

extension CompleteInfoViewController: FieldTableViewCellDelegate{
    
    func tapCollectionItem(indexCell: IndexPath) {
        
       
    }
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
      
       if(indexCell.row == 2){
            
            
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self

            let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue) |
                GMSPlaceField.addressComponents.rawValue |
                                                        GMSPlaceField.formattedAddress.rawValue)
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

extension CompleteInfoViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        
        self.displayData[2]["value"] = "\(place.formattedAddress ?? "")"
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

extension CompleteInfoViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = self.displayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ((field["cell"] as? String)!)) as! FieldTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
    
        if(cell.iconImage != nil){
            cell.iconImage.image = UIImage(named: (field["icon"] as! String))
        }

        let value : String = field["value"] as! String
        let cellType : String = field["cell"] as! String
        
        if(cellType == "fieldData" || cellType == "fieldDataButton" || cellType == "fieldDataWithoutIcon" || cellType == "fieldDataWithPrefix"){
         
            cell.fieldTextField.placeholder = (field["placeholder"] as! String)
            cell.fieldTextField.text = value

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
        }
        
        if(!value.isEmpty){
            cell.borderEditable()
        }else {
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
