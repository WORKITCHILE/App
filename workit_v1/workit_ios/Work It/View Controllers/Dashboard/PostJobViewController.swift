//
//  PostJobViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import GooglePlaces

class PostJobViewController: ImagePickerViewController, PickImage, SelectFromPicker, SelectDate {
    //MARK: IBOutlets
    @IBOutlet weak var workName: DesignableUITextField!
    @IBOutlet weak var address: DesignableUITextField!
    @IBOutlet weak var subCategory: DesignableUITextField!
    @IBOutlet weak var workDate: DesignableUITextField!
    @IBOutlet weak var workTime: DesignableUITextField!
    @IBOutlet weak var charges: DesignableUITextField!
    @IBOutlet weak var category: DesignableUITextField!
    @IBOutlet weak var jobApproach: DesignableUITextField!
    @IBOutlet weak var viewSubcategory: View!
    //   @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var headingLabel: DesignableUILabel!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var postJobButton: CustomButton!
    @IBOutlet weak var dummyImage: UIView!
    @IBOutlet weak var mapView: MapVC!
    
    
    var imageString = [String]()
    
    var categoryData = [GetCategoryResponse]()
    var subcategoryData = [GetSubcategoryResponse]()
    var currentPicker = Int()
    var currentDatePicker = Int()
    var selectedCategory = GetCategoryResponse()
    var selectedSubcategory = GetSubcategoryResponse()
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var jobDetail: GetJobResponse?
    var isEditJob = false
    var deleteImageIndex: Int?
    var selectedTime = Int()
    var isRepostJob = false
    
    //["All", "In Person", "Come and get it", "Take it to workplace" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
              
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        self.categoryData = Singleton.shared.getCategories
        self.jobDescription.delegate = self
        self.jobDescription.text = "Job Description"
        
        
        if(self.categoryData.count > 0){
            self.category.text = self.categoryData[0].category_name
            self.selectedCategory = self.categoryData[0]
            self.getSubCategoryData(id: self.selectedCategory.category_id ?? "")
            
        }
        if(isEditJob || self.isRepostJob){
            self.initialiseView()
            
        }
        
        self.address.text = "General Bustamante 1015, Providencia, Chile"
    }
    
    func initialiseView(){
        if(isRepostJob){
            //self.headingLabel.text = "Repost Job"
            //self.postJobButton.setTitle("Repost", for: .normal)
        }else{
            //self.headingLabel.text = "Edit Job"
            //self.postJobButton.setTitle("Save", for: .normal)
        }
        
        self.workName.text = self.jobDetail?.job_name
        self.workDate.text = self.jobDetail?.job_date
        self.workTime.text = self.convertTimestampToDate(self.jobDetail?.job_time ?? 0, to: "h:mm a")
        //self.jobDetail?.job_time
        self.imageString = self.jobDetail!.images ?? []
        
        CallAPIViewController.shared.getCategory { (category) in
            self.categoryData = category
                for val in self.categoryData {
                    if(self.isEditJob || self.isRepostJob){
                        if(val.category_name == self.jobDetail?.category_name){
                            self.selectedCategory = val
                            self.category.text = self.jobDetail?.category_name
                        }
                    }
                }
        }
        
        self.selectedSubcategory = GetSubcategoryResponse(subcategory_image: nil, category_id: nil, subcategory_name: self.jobDetail?.subcategory_name, subcategory_id: self.jobDetail?.subcategory_id)
        self.imageCollection.reloadData()
        self.jobDescription.text = self.jobDetail?.job_description
        self.address.text = self.jobDetail?.job_address
        self.jobDescription.textColor = .black
        self.jobApproach.text = self.jobDetail?.job_approach
        self.subCategory.text = self.jobDetail?.subcategory_name
        self.latitude = CLLocationDegrees(exactly: self.jobDetail?.job_address_latitude ?? 0)!
        self.longitude = CLLocationDegrees(exactly:self.jobDetail?.job_address_longitude ?? 0)!
        self.selectedTime = self.jobDetail?.job_time ?? 0
        self.mapView.latitude = self.latitude
        self.mapView.longitude = self.longitude
        self.mapView.address = self.jobDetail?.job_address ?? ""
        self.charges.text = "\(self.jobDetail?.initial_amount ?? 0)"
        
    }
    
    func callRepostAPI(){
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_OWNER_REPOST_JOB, method: .post, parameter: ["job_id":self.jobDetail?.job_id ?? ""], objectClass: GetSubcategory.self, requestCode: U_OWNER_REPOST_JOB) { (response) in
            print("status removed")
        }
    }
    
    func getSubCategoryData(id: String){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_SUBCATEGORIES + id, method: .get, parameter: nil, objectClass: GetSubcategory.self, requestCode: U_GET_SUBCATEGORIES) { (response) in
            
            self.subcategoryData = response.data
            if(self.subcategoryData.count > 0){
                self.viewSubcategory.isHidden = false
                self.selectedSubcategory = self.subcategoryData[0]
                self.subCategory.text = self.selectedSubcategory.subcategory_name
            }else {
                self.viewSubcategory.isHidden = true
            }
            ActivityIndicator.hide()
        }
    }
    
    func selectedItem(name: String, id: Int) {
        if(currentPicker == 3){
            self.category.text = name
            self.selectedCategory = self.categoryData[id]
            self.getSubCategoryData(id: self.selectedCategory.category_id ?? "")
        }else if(currentPicker == 4){
            self.selectedSubcategory =
                self.subcategoryData[id]
            self.subCategory.text = name
        }else if(currentPicker == 5){
            self.jobApproach.text = name
        }
    }
    
    func selectedDate(date: Int) {
        if(currentDatePicker == 1){
            self.workDate.text = self.convertTimestampToDate(date, to: "dd.MM.yyyy")
            self.workTime.text = ""
            self.selectedTime = date
        }else if(currentDatePicker == 2){
            self.selectedTime = date
            self.workTime.text = self.convertTimestampToDate(date, to: "h:mm a")
        }
    }
    
    func geImagePath(image: UIImage, imagePath: String, imageData: Data) {
        self.uplaodUserImage(imageName: imagePath, image: imageData, type: 3) { (val) in
            self.imageString.append(val)
            self.imageCollection.reloadData()
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
    
    func deleteImage(url: String){
        // U_DELETE_IMAGE
    }
    
    
    //MARK: IBAction
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
  
    @IBAction func addImageAction(_ sender: Any) {
      self.imageDelegate = self
      self.uploadImage()
    }
    
    @IBAction func categoryAction(_ sender: Any) {
        currentPicker = 3
        let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = mainStoryboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        
 
        myVC.pickerDelegate = self
        if(self.categoryData.count == 0){
            ActivityIndicator.show(view: self.view)
            CallAPIViewController.shared.getCategory { (category) in
                self.categoryData = category
                if(self.categoryData.count > 0){
                    for val in self.categoryData {
                        myVC.pickerData.append(val.category_name ?? "")
                    }
                    myVC.modalPresentationStyle = .overFullScreen
                    ActivityIndicator.hide()
                    self.navigationController?.present(myVC, animated: true, completion: nil)
                }
            }
        }else {
            
            myVC.pickerDelegate = self
            for val in self.categoryData {
                myVC.pickerData.append(val.category_name ?? "")
            }
            myVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func subCategoryAction(_ sender: Any) {
        currentPicker = 4
        if(self.subcategoryData.count > 0){
            let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
            let myVC = mainStoryboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            myVC.pickerDelegate = self
            for val in self.subcategoryData {
                myVC.pickerData.append(val.subcategory_name ?? "")
            }
            myVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func jobApproachAction(_ sender: Any) {
        currentPicker = 5
         let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = mainStoryboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.pickerDelegate = self
        myVC.pickerData = ["All", "In Person", "Come and get it", "Take it to workplace" ]
        myVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func dateAction(_ sender: Any) {
        currentDatePicker = 1
        let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = mainStoryboard.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        myVC.pickerMode = 1
        myVC.dateDelegate = self
        myVC.minDate = Date()
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func timeAction(_ sender: Any) {
           currentDatePicker = 2
        let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
           let myVC = mainStoryboard.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
           myVC.pickerMode = 2
        
        if(self.workDate.text!.isEmpty){
            myVC.selectedDate = Int(Date().addingTimeInterval(121*60).timeIntervalSince1970)
        }else {
            let date = self.convertDateToTimestamp(self.workDate.text ?? "", to: "dd.MM.yyyy")
            let todayData = self.convertTimestampToDate(Int(Date().timeIntervalSince1970), to: "dd.MM.yyyy")
            
            if((self.workDate.text ?? "") == todayData){
               myVC.selectedDate = Int(Date().addingTimeInterval(121*60).timeIntervalSince1970)
            }else{
              myVC.selectedDate = date
            }
            
        }
           myVC.dateDelegate = self
           self.navigationController?.present(myVC, animated: true, completion: nil)
       }
    
    
    @IBAction func mapFullScreenAction(_ sender: Any) {
        let mainStoryboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = mainStoryboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        myVC.latitude = self.latitude
        myVC.longitude = self.longitude
        
    self.navigationController?.pushViewController(myVC, animated: true)
    }
    
   
    
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
    
    @IBAction func postJobAction(_ sender: Any) {
        var sT = Date(timeIntervalSince1970: Double(Int(Date().timeIntervalSince1970)))
        sT = sT.addingTimeInterval(TimeInterval(60*120))
        let todayDate = self.convertTimestampToDate(Int(Date().timeIntervalSince1970), to: "dd.MM.yyyy")
        if(self.workName.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter job name")
        }else if(self.jobDescription.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter description for the job")
        }else if(self.address.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter job address")
        }else if(self.jobApproach.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter job approach")
        }else if(self.category.text!.isEmpty){
            Singleton.shared.showToast(text: "Select job category")
        }else if(self.subCategory.text!.isEmpty){
            Singleton.shared.showToast(text: "Select job subcategory")
        }else if(self.workDate.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter work date")
        }else if(self.workTime.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter work time")
        }else if(self.selectedTime < Int(sT.timeIntervalSince1970) && ((self.workDate.text ?? "") == todayDate)){
            Singleton.shared.showToast(text: "Start time should be atleast 2 hours more from current time.")
        }else if(self.charges.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter payment for the service")
        }else {
            var url = String()
            if(self.isEditJob){
                url = U_BASE + U_EDIT_JOB
            }else {
                url = U_BASE + U_POST_JOB
            }
            self.imageString = self.imageString.filter{
                $0 != "camera"
            }
            let param = [
                "job_id": self.jobDetail?.job_id ?? "",
                "category_name": self.selectedCategory.category_name,
                "subcategory_name": self.selectedSubcategory.subcategory_name,
                "category_id": self.selectedCategory.category_id,
                "subcategory_id":self.selectedSubcategory.subcategory_id,
                "user_id":Singleton.shared.userInfo.user_id,
                "job_address_latitude":self.latitude,
                "job_address_longitude":self.longitude,
                "job_name":self.workName.text ?? "",
                "job_address":self.address.text ?? "",
                "job_approach": self.jobApproach.text ?? "",
                "job_date":self.workDate.text ?? "",
                "job_time":self.selectedTime,
                "initial_amount":Double(self.charges.text ?? "0")!,
                "job_description":self.jobDescription.text,
                "images":self.imageString
                ] as! [String: Any]
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_POST_JOB) { (response) in
                Singleton.shared.jobData = []
                ActivityIndicator.hide()
                if(self.isRepostJob){
                    self.callRepostAPI()
                }
                if !(self.isEditJob){
                    self.openSuccessPopup(img: #imageLiteral(resourceName: "tick"), msg: "Your job is posted successfully", yesTitle: "Ok", noTitle: nil, isNoHidden: true)
                }else {
                    Singleton.shared.showToast(text: "Job updated successfully")
                }
                if(self.isRepostJob){
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                    Singleton.shared.jobData = []
                    self.navigationController?.pushViewController(myVC, animated: true)
                }else {
                  self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    @IBAction func dissmissAction(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
}

extension PostJobViewController: GMSAutocompleteViewControllerDelegate, UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(self.jobDescription.text == "Job Description"){
            self.jobDescription.text = ""
            self.jobDescription.textColor = .black
        }else {
            self.jobDescription.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if(self.jobDescription.text == ""){
            self.jobDescription.text = "Job Description"
            self.jobDescription.textColor = .lightGray
        }else {
            self.jobDescription.textColor = .black
        }
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.address.text = place.formattedAddress
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        self.mapView.latitude = place.coordinate.latitude
        self.mapView.longitude = place.coordinate.longitude
        self.mapView.address = place.formattedAddress ?? ""
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension PostJobViewController: UICollectionViewDelegate, UICollectionViewDataSource, SuccessPopup{
    func yesAction() {
        
        let url = self.imageString[deleteImageIndex ?? 0]
        let store = storageRef.storage.reference(forURL: url)
        
        store.delete { error in
            if let error = error {
                print(error)
            }else {
                self.imageString.remove(at: self.deleteImageIndex ?? 0)
                self.imageCollection.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if(self.imageString.count == 0){
            self.dummyImage.isHidden = false
        }else {
            self.dummyImage.isHidden = true
            self.imageString = self.imageString.filter{
                $0 != "camera"
            }
            self.imageString.append("camera")
        }
        return self.imageString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        if(imageString[indexPath.row] == "camera"){
            cell.jobImage.image = #imageLiteral(resourceName: "dummyProfile")
            cell.addBtn.isHidden = false
            cell.deleteBtn.isHidden = true
            cell.addButton = {
                self.imageDelegate = self
                self.uploadImage()
            }
        }else {
            cell.addBtn.isHidden = true
            cell.deleteBtn.isHidden = false
            cell.jobImage.sd_setImage(with: URL(string: self.imageString[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.deleteButton = {
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
                self.deleteImageIndex = indexPath.row
                myVC.image = #imageLiteral(resourceName: "dummyProfile")
                myVC.titleLabel = "¿Borrar Imagen?"
                myVC.okBtnTtl = "Si"
                myVC.cancelBtnTtl = "No"
                myVC.cancelBtnHidden = false
                myVC.successDelegate = self
                myVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(myVC, animated: true, completion: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: self.imageString[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
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
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
    
}

