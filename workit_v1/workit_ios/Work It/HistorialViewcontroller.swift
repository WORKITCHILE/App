//
//  HistoryViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class HistorialViewController: UIViewController {
    
    
    //MARK: IBOUtlets
    @IBOutlet weak private var segmentControl : UISegmentedControl!
    @IBOutlet weak private var tableView : UITableView!
    @IBOutlet weak private var notJobView : UIView!
    @IBOutlet weak var animation: AnimationView?
    
    private var data : [GetJobResponse] = []
    private var dataReceived : [GetJobResponse] = []
    private  var selectedIndex = 0
    var refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let starAnimation = Animation.named("historial")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.setNavigationBar()
        
        segmentControl.addTarget(self, action: #selector(RunningJobController.indexChanged(_:)), for: .valueChanged)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Tira para Refrescar")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        let userInfo = Singleton.shared.userInfo
        segmentControl.isHidden = userInfo.type == "HIRE"
    }
    
    @objc func refresh(_ sender: AnyObject) {
        if(selectedIndex == 0){
           getMeJobs()
        } else {
            getReceivedJobs()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        animation?.play()
        
        if(selectedIndex == 0){
           getMeJobs()
        } else {
            getReceivedJobs()
        }
    }
    
    func getMeJobs(){
        
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_GET_OWNER_COMPLETED_JOBS)\(Singleton.shared.userInfo.user_id ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: url) { [self] response in
            
            ActivityIndicator.hide()
            refreshControl.endRefreshing()
            data = response!.data
            self.notJobView.isHidden = data.count  > 0
            self.tableView.reloadData()
            
        }
    }
    
    func getReceivedJobs(){
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_GET_VENDOR_COMPLETED_JOB)\(Singleton.shared.userInfo.user_id ?? "")"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetJob.self, requestCode: url) { [self] response in
            
            ActivityIndicator.hide()
            refreshControl.endRefreshing()
            dataReceived = response!.data
            self.notJobView.isHidden = dataReceived.count  > 0
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

extension HistorialViewController {
    func fillDataClient(cell: JobTableView, val : GetJobResponse) -> JobTableView{
    
       
        cell.jobName.text = val.job_name?.uppercased()
        
        if(val.vendor_name == nil){
            cell.userName.text = "Nadie tomo este trabajo"
            cell.userImage.image = UIImage(named: "ic_user_not_found")
            cell.verify.isHidden  = true
        } else {
            
            if(selectedIndex == 0){
                cell.userName.text =  val.vendor_name
                cell.userImage.sd_setImage(with: URL(string: val.vendor_image ?? "" ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                cell.verify.isHidden = !(val.have_vendor_document ?? false)
            } else {
                cell.userName.text =  val.user_name
                cell.userImage.sd_setImage(with: URL(string: val.user_image ?? "" ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
                cell.verify.isHidden = !(val.have_document ?? false)
            }
            
          
            
        }
        
        cell.jobDate.text = val.job_date!
        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
       
  
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        
        if( val.service_amount != nil){
            let formattedNumber = formater.string(from: NSNumber(value: val.service_amount!) )
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        } else {
            let formattedNumber = formater.string(from: NSNumber(value: val.initial_amount!) )
            cell.jobPrice.text =  "$\(formattedNumber ?? "")"
        }
        
        let status : String = val.status ?? ""
        
        cell.statusContainer.backgroundColor = status.statusColor()
        cell.statusLabel.textColor = status.statusHightlightColor()
        cell.statusLabel.text =  status.translanteStatus()
       
      
        cell.card.defaultShadow()
        
        return cell
    }
}

extension HistorialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return selectedIndex == 0 ? self.data.count : self.dataReceived.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = (selectedIndex == 0) ? self.data[indexPath.row] : self.dataReceived[indexPath.row]
       
         
        return fillDataClient(cell: cell, val: val)
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
