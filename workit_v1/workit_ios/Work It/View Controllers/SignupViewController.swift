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

class SignupViewController: ImagePickerViewController, PickImage, SelectFromPicker, GMSAutocompleteViewControllerDelegate,CaptureImage {
    
    //MARK: IBOUtlets
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var check : UISwitch!
    
    var categories: [String] = []
    var googleId: String?
    var facebookId: String?
    
    var fName = ""
    var lName = ""
    var socialPicture = ""
    var userEmail = ""
    var docuymentUrl = ""
    
    let authUI = FUIAuth.defaultAuthUI()
    private var userData : [[String:Any]] = []
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
        
        if let filepath = Bundle.main.path(forResource: "user_signup_config", ofType: "json") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)!
                
                if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                {
                    userData = (json["data"] as?  [[String:Any]])!
                    
                    if(self.fName != ""){
                        self.userData[3]["value"] = fName
                        self.userData[4]["value"] = lName
                    }
                    
                    if(self.userEmail != ""){
                        self.userData[0]["value"] = self.userEmail
                    }
                    self.filterData(false)
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
        self.displayData[13]["value"] = name
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
                
              
                let storyboard  = UIStoryboard(name: "signup", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                myVC.isNewuser = true
                myVC.emailAdd = authResult?.user.email ?? ""
                self?.navigationController?.pushViewController(myVC, animated: true)

            }
        }
    }
    
    private func filterData(_ isWorker: Bool){
        
        displayData = userData.filter({
            
            let isWorkerField = ($0["workerField"] as? Bool)!
            return (isWorkerField && isWorker) || !isWorkerField
        })
    }
    
    //MARK: IBAction
    @IBAction  func segmentedControlValueChanged(segment: UISegmentedControl) {
           
        let isWorker = segment.selectedSegmentIndex == 1
        filterData(isWorker)
        self.tableList.reloadData()
    }
    

    func validateClientData() -> Bool {
        
        let name = self.displayData[0]["value"] as! String
        let fatherName = self.displayData[1]["value"] as! String
        let motherName = self.displayData[2]["value"] as! String
        let address = self.displayData[3]["value"] as! String
        let mobileNumber = self.displayData[6]["value"] as! String
        let email = self.displayData[7]["value"] as! String
        let password = self.displayData[8]["value"] as! String
        let confirmPassword = self.displayData[9]["value"] as! String
        let nationality = self.displayData[10]["value"] as! String
       
       
        if(userProfilePicture == ""){
           Singleton.shared.showToast(text: "Sube una imagen de perfil")
            return false
        } else if(name.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu nombre")
            return false
        }else if(fatherName.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu apellido paterno")
            return false
        }else if(motherName.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu apellido materno")
            return false
        } else if(email.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu correo")
            return false
        } else if !(self.isValidEmail(emailStr: email)){
            Singleton.shared.showToast(text: "Ingresa un correo valido")
            return false
        } else if(mobileNumber.isEmpty){
            Singleton.shared.showToast(text: "Ingresa un numero de telefono")
            return false
        } else if(mobileNumber.count < 10){
            Singleton.shared.showToast(text: "Ingresa un numero de telefono valido")
            return false
        } else if(address.isEmpty){
            Singleton.shared.showToast(text: "Ingresa una dirección")
            return false
        }  else if(password.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu contraseña")
            return false
        } else if(confirmPassword.isEmpty){
            Singleton.shared.showToast(text: "Confirma tu contraseña")
            return false
        } else if(confirmPassword != password){
            Singleton.shared.showToast(text: "Las contraseñas no coinciden")
            return false
        } else if(nationality.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu pais")
            return false
        }
      
        
        return true
    }
    
    func validateWorkerData() -> Bool{
        
        let userDescription = self.displayData[11]["value"] as! String
        let idNumber = self.displayData[12]["value"] as! String
        let occupation = self.displayData[13]["value"] as! String
        
        
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
        
        
      
        
       let isWorker = self.segmentControl.selectedSegmentIndex == 1
       let isValidClientData = validateClientData()
      
   
        if(isValidClientData == false){
            return
        }
        
        if(isWorker && validateWorkerData() == false){
            return
        }
     
        if(!check.isOn){
            let alert = UIAlertController(title: "Workit", message: "Tienes que aceptar los terminos y condiciones", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Ok", style: .default) { _ in
            
            }
           
            
            alert.addAction(yesAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
       ActivityIndicator.show(view: self.view)
       let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
       
        let name = self.displayData[0]["value"] as! String
        let fatherName = self.displayData[1]["value"] as! String
        let motherName = self.displayData[2]["value"] as! String
        let address = self.displayData[3]["value"] as! String
        let addressNumber = self.displayData[4]["value"] as! String
        let addressReference = self.displayData[5]["value"] as! String
        let mobileNumber = self.displayData[6]["value"] as! String
        let email = self.displayData[7]["value"] as! String
        let password = self.displayData[8]["value"] as! String
        let nationality = self.displayData[10]["value"] as! String
    
        
        var param : [String:Any] = [
            "google_handle": self.googleId as Any,
            "facebook_handle": self.facebookId as Any,
            "fcm_token": fcmToken! as Any,
            "profile_picture": self.userProfilePicture,
            "email":email,
            "name":name,
            "father_last_name": fatherName,
            "mother_last_name": motherName,
            "password": password,
            "nationality": nationality,
            "contact_number": mobileNumber,
            "address": address,
            "type": isWorker ? "WORK": "HIRE",
            "id_image1": self.imagePath1,
            "id_image2": self.imagePath2,
            "address_reference":addressReference,
            "address_number" : addressNumber,
            "document_background": self.docuymentUrl
       ]
        
        
        if(isWorker){
            let profileDescription = self.displayData[11]["value"] as! String
            let idNumber = self.displayData[12]["value"] as! String
            let occupation =  self.displayData[13]["value"] as! String
            
            param["profile_description"] = profileDescription
            param["occupation"] = occupation
            param["id_number"] = idNumber
            
        }
     
        
    
    
       let url = "\(U_BASE)\(U_SIGN_UP)"
       SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SIGN_UP) { (response) in
           
            ActivityIndicator.hide()
            self.getAccessToken(email: email, pass: password)
            
    
       }

      
        
    }
    
    
    @IBAction func profileImageAction(_ sender: Any) {
     
        self.typeImage = 2
        self.uploadImage()
      
    }
    
    @IBAction func cancelImageAction(_ sender: Any) {

   
    }
    
    @IBAction func showTerm(_ sender : AnyObject){
        
        let storyboard  = UIStoryboard(name: "signup", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "terms") as! TermConditionsViewcontroller

        self.navigationController?.pushViewController(myVC, animated: true)
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


extension SignupViewController:   UIDocumentPickerDelegate {
    
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    
        if(urls.count > 0){
        
          do {
            let components = urls[0].absoluteString.split(separator: "/").map { String($0) }
                self.displayData[16]["value"] = components.last
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

extension SignupViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
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
        
        if(cellType == "fieldData" || cellType == "fieldDataButton" || cellType == "fieldDataWithoutIcon"){
            
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


extension SignupViewController : FieldTableViewCellDelegate{
    
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
        
        if(indexCell.row == 13){
            
            let storyboard  = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.pickerDelegate = self
            myVC.pickerData = self.categories
            self.navigationController?.present(myVC, animated: false, completion: nil)
            
        } else if(indexCell.row == 15){
            
            self.currentImage = tagButton
            let storyboard  = UIStoryboard(name: "signup", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "CaptureIdCardViewController") as! CaptureIdCardViewController
            myVC.captureDelegate = self
            self.navigationController?.pushViewController(myVC, animated: true)
            
        } else if(indexCell.row == 16){
            
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
            
        } else if(indexCell.row == 3){
            
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
    
    func textFieldDidEnd(indexCell: IndexPath, text: String){
        displayData[indexCell.row]["value"] = text
        self.tableList.reloadData()
    }
    
    func textChange(indexCell: IndexPath, textField: UITextField, range: NSRange, string: String) {
        
        if(indexCell.row == 12){
         
            
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
