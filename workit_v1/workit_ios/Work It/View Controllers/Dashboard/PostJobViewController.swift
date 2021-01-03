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
    

    @IBOutlet weak var workerName: UITextField!
    @IBOutlet weak var workerImage: ImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var workName: DesignableUITextField!
    @IBOutlet weak var address: DesignableUITextField!
    @IBOutlet weak var address_reference: UITextField!
    @IBOutlet weak var address_number: UITextField!
    
    @IBOutlet weak var subCategory: DesignableUITextField!
    @IBOutlet weak var workDate: DesignableUITextField!
    @IBOutlet weak var workTime: DesignableUITextField!
    @IBOutlet weak var charges: DesignableUITextField!
    @IBOutlet weak var category: DesignableUITextField!
    @IBOutlet weak var jobApproach: DesignableUITextField!
    @IBOutlet weak var viewSubcategoryTitle: View!
    @IBOutlet weak var viewSubcategory: View!

    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var headingLabel: DesignableUILabel!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var postJobButton: CustomButton!
    @IBOutlet weak var mapView: MapVC!
    @IBOutlet weak var buttonRemoveWorker: UIButton!
    
    
    var imageString = ["camera"]
    
    var categoryData = [GetCategoryResponse]()
    var subcategoryData = [GetSubcategoryResponse]()
    var currentPicker = Int()
    var currentDatePicker = Int()
    var selectedCategory = GetCategoryResponse()
    var selectedSubcategory: GetSubcategoryResponse? = nil
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var jobDetail: GetJobResponse?
    var isEditJob = false
    var deleteImageIndex: Int?
    var selectedTime = Int()
    var isRepostJob = false
    var workerSelected : UserInfo?
    var placeHolder = "Descripción del trabajo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
              
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        self.categoryData = Singleton.shared.getCategories
        self.jobDescription.delegate = self
        self.jobDescription.text = placeHolder
        
        if(self.categoryData.count > 0){
            self.category.text = self.categoryData[0].category_name
            self.selectedCategory = self.categoryData[0]
            self.getSubCategoryData(id: self.selectedCategory.category_id ?? "")
           
            self.categoryImage.sd_setImage(with: URL(string: (self.categoryData[0].category_image)!),placeholderImage: #imageLiteral(resourceName: "ic_category_work_blue"))
        }
        
        if(isEditJob || self.isRepostJob){
            self.initialiseView()
        }
        
        self.buttonRemoveWorker.isHidden = true
        self.latitude =  -33.4909571
        self.longitude = -70.5890149
        self.mapView.latitude = self.latitude
        self.mapView.longitude = self.longitude
     
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
                self.selectedSubcategory = self.subcategoryData[0]
                self.subCategory.text = self.selectedSubcategory?.subcategory_name
            } else {
                self.selectedSubcategory = nil
            }
            
            self.viewSubcategory.isHidden = !(self.subcategoryData.count > 0)
            self.viewSubcategoryTitle.isHidden = !(self.subcategoryData.count > 0)
            
            ActivityIndicator.hide()
        }
    }
    
    func selectedItem(name: String, id: Int) {
        if(currentPicker == 3){
            self.category.text = name
            self.selectedCategory = self.categoryData[id]
            self.getSubCategoryData(id: self.selectedCategory.category_id ?? "")
            self.categoryImage.sd_setImage(with: URL(string: (self.categoryData[id].category_image)!),placeholderImage: #imageLiteral(resourceName: "ic_category_work_blue"))
            
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
            self.workDate.text = self.convertTimestampToDate(date, to: "dd/MM/yyyy")
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
        let alert = UIAlertController(title: "Elige", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
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
    
    func deleteImage(url: String){
        // U_DELETE_IMAGE
    }
    
    
    //MARK: IBAction
    
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
        } else {
            
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
        if(self.selectedSubcategory == nil){
            myVC.pickerData = self.selectedCategory.types!
        } else {
            myVC.pickerData = (self.selectedSubcategory?.types!)!
        }
        
        myVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(myVC, animated: false, completion: nil)
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
            let date = self.convertDateToTimestamp(self.workDate.text ?? "", to: "dd/MM/yyyy")
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
        let todayDate = self.convertTimestampToDate(Int(Date().timeIntervalSince1970), to: "dd/MM/yyyy")
        
        if(self.workName.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa un nombre")
        }else if(self.jobDescription.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa una descripción")
        }else if(self.address.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa una dirección")
        }else if(self.jobApproach.text!.isEmpty){
            Singleton.shared.showToast(text: "Selecciona el tipo de trabajo")
        }else if(self.category.text!.isEmpty){
            Singleton.shared.showToast(text: "Selecciona una categoria")
        }else if(self.subCategory.text!.isEmpty){
            Singleton.shared.showToast(text: "Selecciona una subcategoria")
        }else if(self.workDate.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa la fecha del trabajo")
        }else if(self.workTime.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa el horario del trabajo")
        }else if(self.selectedTime < Int(sT.timeIntervalSince1970) && ((self.workDate.text ?? "") == todayDate)){
            Singleton.shared.showToast(text: "El horario del trabajo debe ser dos horas despues.")
        }else if(self.charges.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa el precio del trabajo")
        }else {
            
            var url = String()
            
            if(self.isEditJob){
                url = "\(U_BASE)\(U_EDIT_JOB)"
            }else {
                url = "\(U_BASE)\(U_POST_JOB)"
            }
            
            let work_images = self.imageString.filter{
                $0 != "camera"
            }
            
            var param = [
                "job_id": self.jobDetail?.job_id ?? "",
                "category_name": self.selectedCategory.category_name,
                "category_id": self.selectedCategory.category_id,
                "user_id":Singleton.shared.userInfo.user_id,
                "user_image":"\(Singleton.shared.userInfo.profile_picture ?? "")",
                "user_name": "\(Singleton.shared.userInfo.name) \(Singleton.shared.userInfo.father_last_name)",
                "job_address_latitude":self.latitude,
                "job_address_longitude":self.longitude,
                "job_name":self.workName.text ?? "",
                "job_address":self.address.text ?? "",
                "job_approach": self.jobApproach.text ?? "",
                "job_date":self.workDate.text ?? "",
                "job_time":self.selectedTime,
                "initial_amount": Double(self.charges.text ?? "0")!,
                "job_description": self.jobDescription.text,
                "images": work_images,
                "have_document": Singleton.shared.userInfo.background_document != "" && Singleton.shared.userInfo.background_document != nil
                ] as! [String: Any]
            
            param["address_reference"] = self.address_reference.text ?? ""
            param["address_number"] = self.address_number.text ?? ""
            if(self.selectedSubcategory != nil){
                param["subcategory_id"] = self.selectedSubcategory?.subcategory_id
                param["subcategory_name"] =  self.selectedSubcategory?.subcategory_name
            }
            
            if(self.workerSelected != nil){
                param["worker_selected"] = self.workerSelected?.user_id
            }
           
            
            ActivityIndicator.show(view: self.view)
            
            SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_POST_JOB) { (response) in
                
               
                Singleton.shared.jobData = []
                ActivityIndicator.hide()
                
                if(self.isRepostJob){
                    self.callRepostAPI()
                }
                
                if(self.isEditJob){
                    Singleton.shared.showToast(text: "Trabajo Actualizado correctamente")
                    self.dismiss(animated: true, completion: nil)
                }else {
                    
                    let alert = UIAlertController(title: "Trabajo Publicado", message: "Hemos publicado tu trabajo con exito", preferredStyle: .alert)
                  
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                
                    self.present(alert, animated: true)
                    
                    
                }
                
               
            }
        }
        
    }
    
    @IBAction func dissmissAction(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeWorker(_ sender: AnyObject){
        self.buttonRemoveWorker.isHidden = true
        self.workerName.text = ""
        self.workerImage.image = UIImage(named: "ic_category_work_blue")
        self.workerSelected = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let wsVC = segue.destination as! WorkerSearchViewController
        wsVC.delegate = self
    }
}

extension PostJobViewController: WorkerSearchDelegate {
    func selectWorker(worker: UserInfo) {
        self.workerSelected = worker
        self.workerName.text = "\(self.workerSelected?.name! ?? "") \(self.workerSelected?.father_last_name! ?? "") \(self.workerSelected?.mother_last_name! ?? "")"
        
        self.workerImage.sd_setImage(with: URL(string: (self.workerSelected?.profile_picture)!),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        self.buttonRemoveWorker.isHidden = false
    }
}

extension PostJobViewController: GMSAutocompleteViewControllerDelegate, UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(self.jobDescription.text == placeHolder){
            self.jobDescription.text = ""
            self.jobDescription.textColor = .black
        }else {
            self.jobDescription.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if(self.jobDescription.text == ""){
            self.jobDescription.text = placeHolder
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

        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
     
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

extension PostJobViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func delete(index : Int) {
        
        let url = self.imageString[index]
        let store = storageRef.storage.reference(forURL: url)
        
        store.delete { error in
            if error != nil {
                
            }else {
                self.imageString.remove(at: index)
                self.imageCollection.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        
        if(imageString[indexPath.row] == "camera"){
            cell.jobImage.image = #imageLiteral(resourceName: "ic_plus_form")
            cell.addBtn.isHidden = false
            cell.deleteBtn.isHidden = true
            cell.addButton = {
                self.imageDelegate = self
                self.uploadImage()
            }
        } else {
            cell.addBtn.isHidden = true
            cell.deleteBtn.isHidden = false
            cell.jobImage.sd_setImage(with: URL(string: self.imageString[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.deleteButton = {
                
                let alert = UIAlertController(title: "Borrar Imagen", message: "¿Quieres borrar esta imagen?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "si", style: .default) { _ in
                    self.delete(index: indexPath.row)
                }
                let noAction = UIAlertAction(title: "No", style: .default) { _ in }

                alert.addAction(noAction)
                alert.addAction(yesAction)
                
                self.present(alert, animated: true, completion: nil)
                
               
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

