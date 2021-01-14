//
//  ProfileViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: ImagePickerViewController, PickImage, SelectFromPicker  {
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var userImageView : UIView!
    @IBOutlet weak var editButton : UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    
    private var profileData = UserInfo()
    private var imagePath1 = ""
    private var userData : [[String:Any]] = []
    private var displayData : [[String:Any]] = []
    private var editMode = false
    var docuymentUrl = ""
    var images = ["camera"]
    private var image1 : UIImage? = nil
    private var image2 : UIImage? = nil
    
    var categories: [String] = []

    private var imagePath2 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDelegate = self
        
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
        
        self.buttonContainer.isHidden = true
        
        let userInfo = Singleton.shared.userInfo
        
        self.userName.text = "\(userInfo.name!) \(userInfo.father_last_name!)"
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        self.userImageView.defaultShadow()
        
        self.getProfileData()
        self.getCategoryData()
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
        
        self.userImage.image = image
       
        self.uplaodUserImage(imageName: imagePath, image: imageData, type: 2) { val in
            self.imagePath1 = val
        }
     
    }
    
    func selectedItem(name: String, id: Int) {
        //self.nationality.text = name
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
        userData[11]["value"] =  self.profileData.profile_description
        
        displayData = userData //.filter({ ($0["workerField"] as? Bool)! })

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
        
        let contactNumber = self.userData[7]["value"] as! String
        let address = self.userData[8]["value"] as! String
        let addressNumber = self.userData[9]["value"] as! String
        let addressReference = self.userData[10]["value"] as! String
        let profileDescription = self.userData[11]["value"] as! String
        
        let param : [String:String] = [
            "user_id": Singleton.shared.userInfo.user_id ?? "",
            "email":  Singleton.shared.userInfo.email ?? "",
            "contact_number": contactNumber,
            "profile_description": profileDescription,
            "address": address,
            "address_number": addressNumber,
            "address_reference": addressReference,
            "profile_picture": self.imagePath1
        ]
        
        let url = "\(U_BASE)\(U_EDIT_PROFILE)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_EDIT_PROFILE) { response in
            
            self.getProfileData()
            ActivityIndicator.hide()
        }
    }

    @IBAction func addImage(_ sender: Any) {
        if(editMode == false) { return }
        
        self.uploadImage()

    }
    
    @IBAction func saveMode(_ sender : Any){
        self.editMode = true;
        self.buttonContainer.isHidden = false
        self.buttonContainer.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0) {
            self.editButton.alpha = 0.0
            self.buttonContainer.alpha = 1.0
        } completion: { isCompleted in
            self.editButton.isEnabled = false
        }

        self.tableList.reloadData()
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
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
        
        if(indexCell.row == 0){
          
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
            self.navigationController?.pushViewController(myVC, animated: true)
            
        } else if(indexCell.row == 13){
           
           let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
           importMenu.delegate = self
           importMenu.modalPresentationStyle = .formSheet
           self.present(importMenu, animated: true, completion: nil)
           
         } else if(indexCell.row == 11){
            
            let storyboard  = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.pickerDelegate = self
            myVC.pickerData = self.categories
            self.navigationController?.present(myVC, animated: false, completion: nil)
         }
    }
    
    func textFieldDidEnd(indexCell: IndexPath, text: String){
        displayData[indexCell.row]["value"] = text
        self.tableList.reloadData()
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
        
        if(cellType == "fieldData"  || cellType == "fieldDataButton"){
            cell.fieldTextField.placeholder = (field["placeholder"] as! String)
            cell.fieldTextField.text = value
            cell.fieldTextField.isEnabled = editMode && editable
        } else if(cellType == "fieldDataBigText") {
            
            if(value == ""){
                cell.fieldTextView.text = (field["placeholder"] as! String)
            } else {
                cell.fieldTextView.text = value
            }
          
           
        } else if(cellType == "FieldDataButtons") {
            
            if(cell.button1 != nil && self.image1 != nil){
                cell.button1.setBackgroundImage(self.image1, for: .normal)
                cell.button1.setBackgroundImage(self.image1, for: .highlighted)
            }
            
            if(cell.button2 != nil && self.image2 != nil){
                cell.button2.setBackgroundImage(self.image2, for: .normal)
                cell.button2.setBackgroundImage(self.image2, for: .highlighted)
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
        
        if((field["cell"] as? String) == "fieldData" || (field["cell"] as? String) == "fieldDataButton"){
            return 60.0
        } else {
            return 150.0
        }
    }
    
}
