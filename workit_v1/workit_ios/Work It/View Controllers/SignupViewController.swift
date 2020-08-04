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

class SignupViewController: ImagePickerViewController, UITextFieldDelegate, PickImage,UITextViewDelegate, SelectFromPicker, GMSAutocompleteViewControllerDelegate,CaptureImage {
    func showCaptureImage(img: UIImage) {
        if(imagePath2 != nil){
            storageRef.storage.reference(withPath: imagePath2 ?? "").delete(completion: nil)
        }
        self.uplaodUserImage(imageName: self.imagePath2 ?? "", image: img.pngData()!, type: 1) { (val) in
            self.viewUploadImage.isHidden = true
            self.viewIdImage.isHidden = false
            self.idImage.image = img
            self.imagePath2 = val
        }
    }
    
    
    //MARK: IBOUtlets
    
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var idNumber: DesignableUITextField!
    @IBOutlet weak var motherName: DesignableUITextField!
    @IBOutlet weak var fatherName: DesignableUITextField!
    @IBOutlet weak var username: DesignableUITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var address: DesignableUITextField!
    @IBOutlet weak var imageTick: ImageView!
    @IBOutlet weak var idImage: UIImageView!
    @IBOutlet weak var nationality: DesignableUITextField!
    @IBOutlet weak var confirmPassword: DesignableUITextField!
    @IBOutlet weak var password: DesignableUITextField!
    @IBOutlet weak var email: DesignableUITextField!
    @IBOutlet weak var mobileNumber: DesignableUITextField!
    @IBOutlet weak var occupation: DesignableUITextField!
    //@IBOutlet weak var verifyButton: CustomButton!
    // @IBOutlet weak var otpView: View!
    // @IBOutlet weak var verifyOtpButton: CustomButton!
    @IBOutlet weak var otpText: DesignableUITextField!
    @IBOutlet weak var viewIdImage: View!
    @IBOutlet weak var viewUploadImage: View!
    
    
    
    var imagePath1: String?
    var imagePath2: String?
    var currentImage: Int?
    var countries: [String] = []
    var googleId: String?
    var facebookId: String?
    var fName = String()
    var lName = String()
    var userEmail = String()
    let authUI = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.text = self.fName
        self.fatherName.text = self.lName
        self.email.text = self.userEmail
        self.userDescription.text = "Profile Description"
        self.mobileNumber.text = "+56"
        self.mobileNumber.delegate = self
        self.idNumber.delegate = self
        self.userDescription.delegate = self
        
        datePicker.maximumDate = Date()
        self.userDescription.textColor = .lightGray
        DispatchQueue.main.async {
            for code in NSLocale.isoCountryCodes  {
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                self.countries.append(name)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.navigationBar.isHidden = false
    }
       
    
    func geImagePath(image: UIImage,imagePath: String, imageData: Data) {
        if(currentImage == 2){
            
        }else if(currentImage == 1){
            if(imagePath1 != nil){
                storageRef.storage.reference(withPath: imagePath1 ?? "").delete(completion: nil)
            }
            self.uplaodUserImage(imageName: imagePath, image: imageData, type: 2) { (val) in
                self.userImage.image = image
                self.imagePath1 = val
            }
        }
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
    
    func selectedItem(name: String, id: Int) {
        self.nationality.text = name
    }
    
    func sendFcmToken(userId: String){
        DispatchQueue.global(qos: .background).async {
            let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
            let param = [
                "user_id":userId,
                "fcm_token":fcmToken
                ] as? [String:Any]
            
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_ADD_FCM_TOKEN, method: .post, parameter: param, objectClass: Response.self, requestCode: U_ADD_FCM_TOKEN) { (response) in
                
            }
        }
    }
    
    func getAccessToken(email:String,pass:String){
        ActivityIndicator.show(view: self.view)
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if(authResult == nil){
                Singleton.shared.showToast(text: "Wrong credentials")
                ActivityIndicator.hide()
            }else {
                self?.sendFcmToken(userId: authResult?.user.uid ?? "")
                
                Singleton.shared.userInfo.name = authResult?.user.displayName
                Singleton.shared.userInfo.token = authResult?.user.refreshToken
                Singleton.shared.userInfo.user_id = authResult?.user.uid ?? ""
                Singleton.shared.userInfo.email = authResult?.user.email
                //                    if(self!.isNewUser){
                //                     Singleton.shared.userInfo.is_email_verified = 0
                //                    }else{
                //                        Singleton.shared.userInfo.is_email_verified = 1
                //                    }
                Singleton.shared.userInfo.profile_picture = authResult?.user.photoURL?.absoluteString
                UserDefaults.standard.set(authResult?.user.uid ?? "", forKey: UD_USER_ID)
                Singleton.shared.userInfo.contact_number = authResult?.user.phoneNumber
                authResult?.user.getIDToken(completion: { (token, error) in
                    if(error == nil){
                        UserDefaults.standard.setValue(token ?? "", forKey: UD_TOKEN)
                    }else {
                        print(error)
                    }
                })
                ActivityIndicator.hide()
               
                let myVC = self?.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                myVC.isNewuser = true
                myVC.emailAdd = authResult?.user.email ?? ""
                self?.navigationController?.pushViewController(myVC, animated: true)
//                self?.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
//                    if vc.isKind(of: SignupViewController.self) {
//                        return true
//                    } else {
//                        return false
//                    }
//                })
            }
        }
    }
    
    //MARK: IBAction
    @IBAction func addressAction(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            GMSPlaceField.addressComponents.rawValue |
            GMSPlaceField.formattedAddress.rawValue)!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        autocompleteController.modalPresentationStyle = .overFullScreen
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func selectnationality(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerData = self.countries
        myVC.pickerDelegate = self
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if(imagePath1 == nil){
            Singleton.shared.showToast(text: "Upload profile image")
        }else if(userDescription.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter profile description")
        }else if(username.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter User Name")
        }else if(fatherName.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Father's Last Name")
        }else if(motherName.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Mother's Last Name")
        }else if(occupation.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter occupation")
        }else if(idNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter ID Number")
        }else if(email.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Email Address")
        }else if !(self.isValidEmail(emailStr:self.email.text!)){
            Singleton.shared.showToast(text: "Enter valid Email Address")
        } else if(self.address.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Address")
        }else if(mobileNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Mobile Number")
        }else if(mobileNumber.text!.count < 10){
            Singleton.shared.showToast(text: "Enter valid Phone Number")
        }else if(password.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter your Password")
        }else if(confirmPassword.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter Confirm Password")
        }else if(confirmPassword.text != self.password.text){
            Singleton.shared.showToast(text: "Confirm Password does not match")
        }else if(nationality.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter your Nationality")
        }else if(self.imagePath2 == nil){
            Singleton.shared.showToast(text: "Upload ID Picture")
        }else if(self.imageTick.image == #imageLiteral(resourceName: "Rectangle 1")){
            Singleton.shared.showToast(text: "Accept Terms & Conditions")
        }else {
            ActivityIndicator.show(view: self.view)
            let fcmToken = UserDefaults.standard.value(forKey: UD_FCM_TOKEN) as? String
            
            let param : [String:Any] = [
                "name": self.username.text,
                "email": self.email.text ?? "",
                "password": self.password.text,
                "date_of_birth": Int(datePicker.date.timeIntervalSince1970),
                "contact_number": self.mobileNumber.text,
                "address": self.address.text,
                "nationality": self.nationality.text,
                "father_last_name": self.fatherName.text,
                "mother_last_name": self.motherName.text,
                "id_number": self.idNumber.text,
                "id_image1": self.imagePath2,
                "profile_picture": imagePath1,
                "credits": "0.00",
                "fcm_token": fcmToken,
                "profile_description": self.userDescription.text,
                "occupation": self.occupation.text,
                "google_handle": self.googleId,
                "facebook_handle": self.facebookId
            ]
            
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_SIGN_UP, method: .post, parameter: param, objectClass: Response.self, requestCode: U_SIGN_UP) { (response) in
                ActivityIndicator.hide()
                self.getAccessToken(email:self.email.text ?? "", pass: self.password.text ?? "")
                self.openSuccessPopup(img: #imageLiteral(resourceName: "tick"), msg: "Thanks, you account has been successfully created.", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
            }
        }
        
    }
    
    @IBAction func tickAction(_ sender: Any) {
        if(self.imageTick.image == UIImage(named: "checked")){
            self.imageTick.image = #imageLiteral(resourceName: "Rectangle 1")
        }else {
            self.imageTick.image = #imageLiteral(resourceName: "checked")
        }
    }
    
    @IBAction func profileImageAction(_ sender: Any) {
        self.currentImage = 1
        self.imageDelegate = self
        self.uploadImage()
    }
    
    @IBAction func cancelImageAction(_ sender: Any) {
        self.viewUploadImage.isHidden = false
        self.viewIdImage.isHidden = true
        self.idImage.image = nil
        self.imagePath2 = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.currentImage = 2
        let myVC = segue.destination as! CaptureIdCardViewController
         myVC.captureDelegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == mobileNumber){
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                return isBackSpace == -92 || textField.text!.count <= 11
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
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(self.userDescription.text == "Profile Description"){
            self.userDescription.text = ""
        }
        
        self.userDescription.textColor = .black
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.userDescription.text == "" {
            self.userDescription.text = "Profile Description"
            self.userDescription.textColor = .lightGray
        }else {
            self.userDescription.textColor = .black
        }
    }
    

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.address.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
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
