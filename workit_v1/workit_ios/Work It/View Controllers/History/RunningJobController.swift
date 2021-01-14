//
//  HistoryViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class RunningJobController: UIViewController {
    
    
    //MARK: IBOUtlets
    @IBOutlet weak private var segmentControl : UISegmentedControl!
    @IBOutlet weak private var tableView : UITableView!
    
    private var data : [GetJobResponse] = []
    private var dataReceived : [GetJobResponse] = []
    private  var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)

        segmentControl.addTarget(self, action: #selector(RunningJobController.indexChanged(_:)), for: .valueChanged)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMeJobs()
    }
    
    func getMeJobs(){
        
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_GET_OWNER_RUNNING_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: url) { [self] response in
            
            ActivityIndicator.hide()
            
            data = response!.data
            self.tableView.reloadData()
            
        }
    }
    
    func getReceivedJobs(){
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_GET_VENDOR_RUNNING_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: url) { [self] response in
            
            ActivityIndicator.hide()
            
            dataReceived = response!.data
            self.tableView.reloadData()
            
        }
    }
    
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == selectedIndex){
            return
        }
        selectedIndex = sender.selectedSegmentIndex
        
        if(selectedIndex == 0){
           getMeJobs()
        } else {
            getReceivedJobs()
        }
        
        
        self.tableView.reloadData()
        
        
    }
    
}

extension RunningJobController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 152.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return selectedIndex == 0 ? self.data.count : self.dataReceived.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*  */
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = (selectedIndex == 0) ? self.data[indexPath.row] : self.dataReceived[indexPath.row]
       
        
        if(selectedIndex == 0){
            cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? "" ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.vendor_name
        } else {
            cell.userImage.sd_setImage(with: URL(string: val.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  val.user_name
           
        }
        
        cell.jobName.text = val.job_name?.uppercased()
       
        cell.jobDate.text = val.job_date!

        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        
        cell.card.defaultShadow()
        cell.verify.isHidden = !val.have_document
  
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        let formattedNumber = formater.string(from: NSNumber(value: val.service_amount!) )
        
        cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = (selectedIndex == 0) ? self.data[indexPath.row] : self.dataReceived[indexPath.row]
        let storyboard  = UIStoryboard(name: "Home", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "bidDetail") as! BidDetailViewController
        myVC.jobData = item
        myVC.mode = (selectedIndex == 0) ? "HIRE" : "WORK"
        self.navigationController?.pushViewController(myVC, animated: true)
        
    }
}
