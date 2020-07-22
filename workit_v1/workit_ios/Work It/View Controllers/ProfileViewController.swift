//
//  ProfileViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: ImagePickerViewController, PickImage, SelectDate, SelectFromPicker,CaptureImage  {
    func showCaptureImage(img: UIImage) {
       
        if(imagePath2 != nil){
            let url = imagePath2
            let store = storageRef.storage.reference(forURL: url)
            store.delete { error in
                if let error = error {
                    print(error)
                }else {
                    self.uplaodUserImage(imageName: self.imagePath2 ?? "", image: img.pngData()!, type: 1) { (val) in
                        self.idImage.image = img
                        self.imagePath2 = val
                    }
                }
            }
        }
    }
    
    func selectedItem(name: String, id: Int) {
        self.nationality.text = name
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userName: DesignableUITextField!
    @IBOutlet weak var userAge: DesignableUITextField!
    @IBOutlet weak var credit: DesignableUITextField!
    @IBOutlet weak var email: DesignableUITextField!
    @IBOutlet weak var idNumber: DesignableUITextField!
    @IBOutlet weak var address: DesignableUITextField!
    @IBOutlet weak var fatherlastName: DesignableUITextField!
    @IBOutlet weak var motherLastName: DesignableUITextField!
    @IBOutlet weak var occupation: DesignableUITextField!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var viewForImage: UIView!
    @IBOutlet weak var userDetailStack: UIStackView!
    @IBOutlet weak var porfileHeading: DesignableUILabel!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nationality: DesignableUITextField!
    @IBOutlet weak var nationalityButton: UIButton!
    @IBOutlet weak var idImage: UIImageView!
    @IBOutlet weak var contactNumber: DesignableUITextField!
    
    
    
    var profileData = UserInfo()
    var imagePath1 = String()
    var imagePath2 = String()
    var currentImage = Int()
    var userDate = Int()
    var countries = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.delegate = self
        self.email.delegate = self
        self.idNumber.delegate = self
        self.address.delegate = self
        self.contactNumber.delegate = self
        self.fatherlastName.delegate = self
        self.motherLastName.delegate = self
        self.occupation.delegate = self
        self.userDescription.delegate = self
        DispatchQueue.main.async {
            for code in NSLocale.isoCountryCodes  {
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                self.countries.append(name)
            }
        }
        self.getProfileData()
    }
    
    func selectedDate(date: Int) {
        self.userDate = date
        self.userAge.text = self.calculateAge(timeStamp: date)
    }
    
    func geImagePath(image: UIImage, imagePath: String, imageData: Data) {
        if(currentImage == 1){
            
            if(imagePath1 != nil){
                let url = imagePath1 ?? ""
                let store = storageRef.storage.reference(forURL: url)
                
                store.delete { error in
                    if let error = error {
                        print(error)
                    }else {
                        self.uplaodUserImage(imageName: imagePath, image: imageData, type: 2) { (val) in
                            self.userImage.image = image
                            self.imagePath1 = val
                        }
                    }
                }
            }
        }else if(self.currentImage == 2) {

        }
    }
    
    func getProfileData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
            self.profileData = response.data!
            Singleton.shared.userInfo = response.data!
            Singleton.saveUserInfo(data:Singleton.shared.userInfo)
            self.manageView()
            ActivityIndicator.hide()
        }
    }
    
    func manageView(){
        self.userImage.sd_setImage(with: URL(string: self.profileData.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        imagePath1 = self.profileData.profile_picture ?? ""
        self.idImage.sd_setImage(with: URL(string: self.profileData.id_image1 ?? ""),placeholderImage: #imageLiteral(resourceName: "camera"))
        imagePath2 = self.profileData.id_image1 ?? ""
        self.userName.text = self.profileData.name
        self.userAge.text = self.calculateAge(timeStamp: self.profileData.date_of_birth ?? 0)
        self.userDate = self.profileData.date_of_birth ?? 0
        self.contactNumber.text = self.profileData.contact_number
        self.credit.text = "$" + (self.profileData.credits ?? "0")
        self.email.text = self.profileData.email
        self.idNumber.text = self.profileData.id_number
        self.address.text = self.profileData.address
        self.nationality.text = self.profileData.nationality
        
        self.occupation.text = self.profileData.occupation
        self.credit.text = (self.profileData.credits == "") ? "$0":(self.profileData.credits ?? "$0")
        self.fatherlastName.text = self.profileData.father_last_name
        self.motherLastName.text = self.profileData.mother_last_name
        self.userDescription.text = self.profileData.profile_description
        self.userDescription.textColor = .black
    }
    
    func uploadImage(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
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
    @IBAction func nationalityAction(_ sender: Any) {
        if(editButton.titleLabel!.text == "Save"){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            myVC.modalPresentationStyle = .overFullScreen
            myVC.pickerData = self.countries
            myVC.pickerDelegate = self
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func userAgeAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        myVC.pickerMode = 1
        myVC.dateDelegate = self
        myVC.selectedDate = self.profileData.date_of_birth ?? 0
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        if(editImage.isHidden){
            if(self.imagePath1 == nil){
                Singleton.shared.showToast(text: "Upload profile image")
            }else if(self.userName.text!.isEmpty){
                Singleton.shared.showToast(text: "Username cannot be empty")
            }else if(self.userDate == 0){
                Singleton.shared.showToast(text: "Select user date of birth")
            }else if(self.email.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter email address")
            }else if !(self.isValidEmail(emailStr: self.email.text ?? "")){
                Singleton.shared.showToast(text: "Enter valid email address")
            }else if(self.contactNumber.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter contact number")
            }else if(self.idNumber.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter ID number")
            }else if(self.address.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter address")
            }else if(self.fatherlastName.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter Father's Last Name")
            }else if(self.motherLastName.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter Mother's Last Name")
            }else if(self.occupation.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter occupation")
            }else if(self.userDescription.text!.isEmpty){
                Singleton.shared.showToast(text: "Enter user description")
            }else {
                ActivityIndicator.show(view: self.view)
                let param = [
                    "user_id":Singleton.shared.userInfo.user_id ?? "",
                    "name": self.userName.text ?? "",
                    "email": self.email.text,
                    "date_of_birth": self.userDate,
                    "address": self.address.text,
                    "nationality":self.nationality.text,
                    "contact_number":self.contactNumber.text,
                    
                    "profile_description":self.userDescription.text,
                    "father_last_name": self.fatherlastName.text,
                    "mother_last_name": self.motherLastName.text,
                    "id_image1":self.imagePath2,
                    "profile_picture":self.imagePath1,
                    "id_number": self.idNumber.text
                    ] as? [String:Any]
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_EDIT_PROFILE, method: .post, parameter: param, objectClass: Response.self, requestCode: U_EDIT_PROFILE) { (response) in
                    self.editImage.isHidden = false
                    self.editButton.setTitle("", for: .normal)
                    self.porfileHeading.text = "Profile"
                    self.getProfileData()
                    self.openSuccessPopup(img: #imageLiteral(resourceName: "tick"), msg: "Profile updated successfully", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                    self.viewForImage.isUserInteractionEnabled = false
                    self.userDetailStack.isUserInteractionEnabled = false
                    ActivityIndicator.hide()
                }
                
            }
        }else{
            self.editImage.isHidden = true
            self.editButton.setTitle("Save", for: .normal)
            self.porfileHeading.text = "Edit Profile"
            self.viewForImage.isUserInteractionEnabled = true
            self.userDetailStack.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func addImage(_ sender: Any) {
        if(editButton.titleLabel!.text == "Save"){
            self.imageDelegate = self
            self.currentImage = 1
            self.uploadImage()
        }
    }
    
    @IBAction func addIdImage(_ sender: Any) {
        if(editButton.titleLabel!.text == "Save"){
            self.currentImage = 2
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "CaptureIdCardViewController") as! CaptureIdCardViewController
            myVC.captureDelegate = self
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
}

extension ProfileViewController: UITextViewDelegate,UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(self.userDescription.text == "Type here"){
            self.userDescription.text = ""
            self.userDescription.textColor = .black
        }else {
            self.userDescription.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if(self.userDescription.text == ""){
            self.userDescription.text = "Type here"
            self.userDescription.textColor = .lightGray
        }else {
            self.userDescription.textColor = .black
        }
        textView.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == contactNumber){
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92 || textField.text!.count <= 12) {
                    return true
                }else {
                    return false
                }
            }
        }else if(textField == idNumber){
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92 || textField.text!.count <= 10) {
                    if(self.idNumber.text!.count == 9 && !(isBackSpace == -92)){
                        self.idNumber.text = (self.idNumber.text ?? "") + "-"
                    }
                    return true
                }else {
                    return false
                }
            }
        }
        return true
    }
}
