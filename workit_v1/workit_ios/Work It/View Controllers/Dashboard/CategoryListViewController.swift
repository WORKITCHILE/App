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

class CategoryListViewController: UIViewController, ApplyFilter {
    

    func reloadTable(approach: String, price: Float, distance: Float, address: String,lat: CLLocationDegrees, long: CLLocationDegrees) {
        
        self.getJobData(address: address, lat: "\(lat)", long: "\(long)", approach: approach, price: "\(price)", distance:"\(distance)")
    }
    
    //MARK: IBOUtlets
    @IBOutlet weak var jobTable: UITableView!
    @IBOutlet weak var noJobFound: DesignableUILabel!
   
    var jobData = [GetJobResponse]()
    var subcategories : [GetSubcategoryResponse] = []
    var refreshControl = UIRefreshControl()
    var selectedDate = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        jobTable.tableFooterView = UIView()
        jobTable.addSubview(refreshControl)
        
        setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.getJobData(address: "", lat: "", long: "", approach: "", price: "", distance: "")
    }
    
    @objc func refresh() {
        refreshControl.endRefreshing()
     
        self.getJobData(address: "", lat: "", long: "", approach: "", price: "", distance: "")
    }
    
    func getJobData(address: String, lat:String, long: String, approach: String, price: String, distance: String){
         var latitude = CLLocationDegrees()
         var longitude = CLLocationDegrees()
         let locManager =  CLLocationManager()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                          CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                          guard let currentLocation = locManager.location else {
                              return
                          }
                   longitude = currentLocation.coordinate.longitude
                   latitude = currentLocation.coordinate.latitude
        }
        
        ActivityIndicator.show(view: self.view)
        
      
        var param : [String:Any] = [
           
            "subcategory_id": self.subcategories.map{ $0.subcategory_id! },
            "user_id": Singleton.shared.userInfo.user_id ?? "",
            "current_latitude": latitude,
            "current_longitude": longitude
            ]
        
        if(distance != ""){
            param["distance"] = distance
        }
        
        if(price != ""){
            param["price"] = price
        }
        
        if(approach != ""){
            param["job_approach"] =  "\(approach)"
        }
        
        debugPrint(param)
    
        let url = "\(U_BASE)\(U_GET_WORKER_POSTED_JOB)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: GetJob.self, requestCode: U_GET_WORKER_POSTED_JOB) { (response) in
           
            self.jobData = []

            
            self.jobData = response!.data.sorted(by: {$0.job_time! < $1.job_time!})
            self.jobData = self.jobData.filter{
                $0.user_id != Singleton.shared.userInfo.user_id
            }
           self.jobTable.reloadData()
           ActivityIndicator.hide()
       }
    }
    
    //MARK: IBActions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "filterId"){
            let reduced = subcategories.map{ $0.types! }.reduce([], +)
            let unique = Array(Set(reduced))
            let fVC =  segue.destination as! FilterViewController
            fVC.filterDelegate = self
            fVC.filterData = unique
        }
      
    }
    
}

extension CategoryListViewController: UITableViewDelegate,UITableViewDataSource {
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
       
        cell.jobName.text = val.job_name?.uppercased()
        
        cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? Singleton.shared.userInfo.profile_picture ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.userName.text =  val.user_name
    
        cell.jobDate.text = val.job_date
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.card.defaultShadow()
        cell.verify.isHidden = !val.have_document
  
        
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        let formattedNumber = formater.string(from: NSNumber(value: val.initial_amount!) )
        
        
        cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
        myVC.jobId = self.jobData[indexPath.row].job_id ?? ""
        myVC.modeView = 1
        self.navigationController?.pushViewController(myVC, animated: true)
      
    }
    
    
  
}

