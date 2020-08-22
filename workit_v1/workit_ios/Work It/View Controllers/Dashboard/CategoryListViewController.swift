//
//  CategoryListViewController.swift
//  Work It
//
//  Created by qw on 07/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class CategoryListViewController: UIViewController, ApplyFilter,SelectDate {
    
func selectedDate(date: Int) {
    self.selectedDate = date
    self.filterDate.text = self.convertTimestampToDate(date, to: "dd.MM.yyyy")
}
    
    func reloadTable(approach: String, price: Float, address: String,lat: CLLocationDegrees, long: CLLocationDegrees) {
        self.getJobData(address: address, lat: "\(lat)", long: "\(long)", approach: approach, price: "\(price)", distane:"40",searchText:"", date: self.selectedDate)
    }
    
    //MARK: IBOUtlets
    @IBOutlet weak var jobTable: UITableView!
    @IBOutlet weak var noJobFound: DesignableUILabel!
    @IBOutlet weak var filterDate: UILabel!
    @IBOutlet weak var distanceSliderValue: UILabel!
    @IBOutlet weak var viewSortby: UIView!
    @IBOutlet weak var distanceSlider: UISlider!
    
  //  @IBOutlet weak var searchField: DesignableUITextField!
    
    
      
    var jobData = [GetJobResponse]()
    var subcategoryId = [String]()
    var refreshControl = UIRefreshControl()
    var searchText = ""
    var selectedDate = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      self.getJobData(address: "", lat: "", long: "", approach: "All", price: "", distane: "",searchText:"", date: 0)
    }
    
    @objc func refresh() {
        refreshControl.endRefreshing()
        self.getJobData(address: "", lat: "", long: "", approach: "All", price: "", distane: "",searchText:"", date:0)
    }
    
    func getJobData(address: String, lat:String, long: String, approach: String, price: String, distane: String,searchText: String,date:Int){
         var latitude = CLLocationDegrees()
         var longitude = CLLocationDegrees()
         var locManager =  CLLocationManager()
        
                if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                          CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                          guard let currentLocation = locManager.location else {
                              return
                          }
                   longitude = currentLocation.coordinate.longitude
                   latitude = currentLocation.coordinate.latitude
        }
        
        ActivityIndicator.show(view: self.view)
        let param : [String:Any] = [
            "subcategory_id": self.subcategoryId,
            "user_id": Singleton.shared.userInfo.user_id ?? "",
            "address":address,
            "current_longitude":longitude,
            "current_latitude":latitude,
            "address_latitude":lat,
            "address_longitude":long,
            "job_approach":approach,
            "price":price,
            "distance":distane,
            "search": searchText,
            "date_filter":(date == 0 ? "":date)
            ]
           SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_WORKER_POSTED_JOB , method: .post, parameter: param, objectClass: GetJob.self, requestCode: U_GET_WORKER_POSTED_JOB) { (response) in
               
            self.jobData = []
            self.jobData = response.data.sorted(by: {$0.job_time! < $1.job_time!})
            self.jobData = self.jobData.filter{
                $0.user_id != Singleton.shared.userInfo.user_id
            }
               self.jobTable.reloadData()
               ActivityIndicator.hide()
           }
    }
    
    //MARK: IBActions
    @IBAction func sortByAction(_ sender: Any) {
        self.viewSortby.isHidden = false
    }
    
    @IBAction func sortList(_ sender: Any) {
        self.getJobData(address: "", lat: "", long: "", approach: "All", price: "", distane: self.distanceSliderValue.text ?? "",searchText:"", date: self.selectedDate)
        self.viewSortby.isHidden = true
    }
    
    @IBAction func hideAction(_ sender: Any) {
        self.selectedDate = Int()
        self.filterDate.text = ""
        self.distanceSliderValue.text = ""
        self.distanceSlider.value = 0
        self.viewSortby.isHidden = true
    }
    
    @IBAction func selectDateAction(_ sender: Any) {
           let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
           myVC.dateDelegate = self
           myVC.pickerMode = 1
           self.present(myVC, animated: true, completion: nil)
       }
    
    @IBAction func distanceChangeAction(_ sender: UISlider) {
          sender.value = roundf(sender.value)
           self.distanceSliderValue.text = "\(sender.value)"
    }
    
    
    @IBAction func filterAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        myVC.filterDelegate = self
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        debugPrint(segue.destination)
    }
    
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.jobData.count == 0){
            self.noJobFound.isHidden = false
        }else {
            self.noJobFound.isHidden = true
        }
        return self.jobData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.jobData[indexPath.row]
        cell.jobPrice.text = "$" + "\(val.initial_amount ?? 0)"
        cell.jobName.text = val.job_name
        if(Singleton.shared.userInfo.user_id != val.user_id){
            cell.userImage.sd_setImage(with: URL(string: val.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                   cell.userName.text = val.user_name ?? ""
            cell.userRating.rating = Double(val.user_average_rating ?? "0")!
        }else {
            cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.vendor_name ?? Singleton.shared.userInfo.name ?? ""
            cell.userRating.rating = Double(val.user_average_rating ?? "0")!
        }
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.jobDescription.text = val.job_description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if (isHistory == false){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
            myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        */
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      //  self.getJobData(address: "", lat: "", long: "", approach: "All", price: "", distane: "",searchText: textField.text ?? "")
    }
}

