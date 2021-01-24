//
//  BecomeWorkerViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 08-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

//
//  SignupViewController.swift
//  Work It
//
//  Create d by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import FirebaseStorage
import GooglePlaces
import FirebaseUI
import Firebase

class BecomeWorkerViewController: ImagePickerViewController, PickImage, SelectFromPicker, GMSAutocompleteViewControllerDelegate,CaptureImage {
    
    //MARK: IBOUtlets
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var userImage: ImageView!

    var categories: [String] = []
    var googleId = ""
    var facebookId = ""
    var docuymentUrl = ""

    private var displayData : [[String:Any]] = []
    
    private var image1 : UIImage? = nil
    private var image2 : UIImage? = nil
    
    private var imagePath1 = ""
    private var imagePath2 = ""
    
    private var userProfilePicture = ""
    
    private var currentImage = 0
    private var typeImage = 0
    
    var images = ["camera"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDelegate = self
        let userInfo = Singleton.shared.userInfo
        self.userImage.sd_setImage(with: URL(string: userInfo.profile_picture ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
       
        
        if let filepath = Bundle.main.path(forResource: "user_become_config", ofType: "json") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)!
                
                if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                {
                    displayData = (json["data"] as?  [[String:Any]])!
                    
                    
                }
         
            } catch {
              
            }
        }
        
        self.tableList.delegate = self
        self.tableList.dataSource = self
        self.tableList.separatorColor = UIColor.clear
        self.setNavigationBar()
        
        self.tableList.reloadData()
        setTransparentHeader()
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        setTransparentHeader()
        getCategoryData()
      
    }
    
    func getCategoryData(){
          let url = "\(U_BASE)\(U_GET_CATEGORIES)"
          SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetCategory.self, requestCode: U_GET_CATEGORIES) { (response) in
            self.categories = response!.data.map({
                    $0.category_name!
                })
               
          }
      }
      
    
    func geImagePath(image: UIImage,imagePath: String, imageData: Data) {
        
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
    
    func uploadImage(){
        
        let alert = UIAlertController(title: "Elegir Imagen", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectedItem(name: String, id: Int) {
        self.displayData[2]["value"] = name
        self.tableList.reloadData()
    }
    
    func sendFcmToken(userId: String){
        DispatchQueue.global(qos: .background).async {
            let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
            let param: [String:Any] = [
                "user_id": userId,
                "fcm_token": fcmToken
                ]
            
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_ADD_FCM_TOKEN, method: .post, parameter: param, objectClass: Response.self, requestCode: U_ADD_FCM_TOKEN) { (response) in
                
            }
        }
    }
    
    func getAccessToken(email:String,pass:String){
        ActivityIndicator.show(view: self.view)
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            
            guard self != nil else { return }
            
            ActivityIndicator.hide()
            
            if(authResult == nil){
                Singleton.shared.showToast(text: "Credenciales incorrectas")
            }else {
                self?.sendFcmToken(userId: authResult?.user.uid ?? "")
                
                Singleton.shared.userInfo.name = authResult?.user.displayName
                Singleton.shared.userInfo.token = authResult?.user.refreshToken
                Singleton.shared.userInfo.user_id = authResult?.user.uid ?? ""
                Singleton.shared.userInfo.email = authResult?.user.email
                Singleton.shared.userInfo.profile_picture = authResult?.user.photoURL?.absoluteString
                
                UserDefaults.standard.set(authResult?.user.uid ?? "", forKey: UD_USER_ID)
                
                Singleton.shared.userInfo.contact_number = authResult?.user.phoneNumber
                
                authResult?.user.getIDToken(completion: { (token, error) in
                    if(error == nil){
                        UserDefaults.standard.setValue(token ?? "", forKey: UD_TOKEN)
                    } else {
                       
                    }
                })
                
              
            
                self?.navigationController?.popToRootViewController(animated: true)

            }
        }
    }
    

    //MARK: IBAction
   
    func validateWorkerData() -> Bool{
        
        let userDescription = self.displayData[0]["value"] as! String
        let idNumber = self.displayData[1]["value"] as! String
        let occupation = self.displayData[2]["value"] as! String
        
        
        if(userDescription.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu descripción")
             return false
        }else if(occupation.isEmpty){
            Singleton.shared.showToast(text: "Elige una ocupación")
            return false
        }else if(idNumber.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu rut")
            return false
        }
      
        
        return true
    }
    
    
    @IBAction func continueAction(_ sender: Any) {
        
        if(validateWorkerData() == false){
            return
        }
    
       ActivityIndicator.show(view: self.view)
       let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
      
        
        var param : [String:Any] = [
            "google_handle": self.googleId as Any,
            "facebook_handle": self.facebookId as Any,
            "fcm_token": fcmToken! as Any,
            "profile_picture": self.userProfilePicture,
            "type": "WORK",
            "id_image1": self.imagePath1,
            "id_image2": self.imagePath2,
            "document_background": self.docuymentUrl
       ]
        
        
       
            let profileDescription = self.displayData[11]["value"] as! String
            let idNumber = self.displayData[12]["value"] as! String
            let occupation =  self.displayData[13]["value"] as! String
            
            param["profile_description"] = profileDescription
            param["occupation"] = occupation
            param["id_number"] = idNumber
            
      
     
        

    
       let url = "\(U_BASE)\(U_SIGN_UP)"
       SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SIGN_UP) { (response) in
           
            ActivityIndicator.hide()
            
    
       }

      
        
    }
    
    @IBAction func cancelImageAction(_ sender: Any) {

   
    }
   
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
 
        self.displayData[3]["value"] = "\(place.formattedAddress ?? "")"
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
    
    func showCaptureImage(img: UIImage) {
        let image_path = "\(NSDate().timeIntervalSince1970)_\(UUID().uuidString).png"
       
        if(currentImage == 0){
            self.image1 = img
        } else if(currentImage == 1){
            self.image2 = img
        }
        
        self.tableList.reloadData()
        
        self.uplaodUserImage(imageName: image_path , image: img.pngData()!, type: 1) { [self] val in
           
            if(self.currentImage == 0){
                self.imagePath1 = val
            } else if(self.currentImage == 1){
                self.imagePath2 = val
            }
            
        }
     
    }
    
}


extension BecomeWorkerViewController:   UIDocumentPickerDelegate {
    
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    
        if(urls.count > 0){
        
          do {
            let components = urls[0].absoluteString.split(separator: "/").map { String($0) }
                self.displayData[5]["value"] = components.last
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

extension BecomeWorkerViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
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
        let security: Bool = field["security"] as! Bool
        
        if(!value.isEmpty){
            cell.borderEditable()
        }else {
            cell.borderNotEditable()
        }
        
        if(cellType == "fieldData" || cellType == "fieldDataButton"){
            
            cell.fieldTextField.placeholder = (field["placeholder"] as! String)
            cell.fieldTextField.text = value
            cell.fieldTextField.isSecureTextEntry = security
           
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
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let field = self.displayData[indexPath.row]
        let cellType : String = field["cell"] as! String
        if(cellType == "fieldData" || cellType == "fieldDataButton"){
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


extension BecomeWorkerViewController : FieldTableViewCellDelegate{
    
    
    
    func tapCollectionItem(indexCell: IndexPath) {
        if(indexCell.row == 0){
            self.typeImage = 4
            self.uploadImage()
        }
    }
    
    func tapCollectionDeleteItem(indexCell: IndexPath){
      
        let alert = UIAlertController(title: "Borrar Imagen", message: "¿Quieres borrar esta imagen?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "si", style: .default) { _ in
            self.images.remove(at: indexCell.row)
            self.tableList.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { _ in }

        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        self.present(alert, animated: true, completion: nil)
      
        
    }
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
        
        if(indexCell.row == 2){
            
            let storyboard  = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.pickerDelegate = self
            myVC.pickerData = self.categories
            self.navigationController?.present(myVC, animated: false, completion: nil)
            
        } else if(indexCell.row == 4){
            
            self.currentImage = tagButton
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "CaptureIdCardViewController") as! CaptureIdCardViewController
            myVC.captureDelegate = self
            self.navigationController?.pushViewController(myVC, animated: true)
            
        } else if(indexCell.row == 5){
            
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
            
        }
      
       
    }
    
    func textFieldDidEnd(indexCell: IndexPath, text: String, _ tag : Int){
        displayData[indexCell.row]["value"] = text
        self.tableList.reloadData()
    }
    
    func textChange(indexCell: IndexPath, textField: UITextField, range: NSRange, string: String) {
        
        if(indexCell.row == 1){
         
            
            let str = "\(textField.text ?? "")"
            let regex = try! NSRegularExpression(pattern: "[^_0-9kK]+", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, max(str.count - 1, 0))
            let modString = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "")
                      
            let formatter = NumberFormatter()
            formatter.groupingSeparator = "."
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
          
            if string != "" {
              
                if let doubleVal = Double(modString) {
                    let requiredString = formatter.string(from: NSNumber.init(value: doubleVal))
                    textField.text = "\(requiredString ?? "")-"
                }

            }
           
        }
       
    }
}
