//
//  MyBidsViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 16-01-21.
//  Copyright © 2021 qw. All rights reserved.
//


import UIKit
import Lottie

class MyBidsViewController: UIViewController {
    
    
    //MARK: IBOUtlets
    @IBOutlet weak private var segmentControl : UISegmentedControl!
    @IBOutlet weak private var tableView : UITableView!
    @IBOutlet weak private var notJobView : UIView!
    @IBOutlet weak var animation: AnimationView?
    
    private var data : [GetJobResponse] = []
 
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
        getMeAllBids((selectedIndex == 0) ? "POSTED" : "REJECTED")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        animation?.play()
        getMeAllBids((selectedIndex == 0) ? "POSTED" : "REJECTED")
        
    }
    
    func getMeAllBids(_ type : String){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_ALL_BID)\(Singleton.shared.userInfo.user_id ?? "")&type=\(type)"
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetJob.self, requestCode: U_GET_ALL_BID) {
            
            
            ActivityIndicator.hide()
            
            if($0 != nil){
                self.data = $0!.data
                Singleton.shared.vendorAcceptedBids = $0!.data
                
                self.notJobView.isHidden = self.data.count > 0
                self.tableView.reloadData()
                
            }
        }
    }

    
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == selectedIndex){
            return
        }
        selectedIndex = sender.selectedSegmentIndex
        
        getMeAllBids((selectedIndex == 0) ? "POSTED" : "REJECTED")
        
        
        self.tableView.reloadData()
        
        
    }
    
}

extension MyBidsViewController {
    func fillDataClient(cell: JobTableView, val : GetJobResponse) -> JobTableView{
    
       
        cell.jobName.text = val.job_name?.uppercased()
        
        cell.userName.text =  val.user_name
        cell.userImage.sd_setImage(with: URL(string: val.user_image ?? "" ),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))

        cell.jobDate.text = val.job_date!

        cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        
    
        cell.verify.isHidden = !(val.have_document ?? false)
  
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        
        let formattedNumber = formater.string(from: NSNumber(value: val.counteroffer_amount!) )
        cell.jobPrice.text =  "$\(formattedNumber ?? "")"
    
        cell.card.defaultShadow()
        
        return cell
    }
}

extension MyBidsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return  self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.data[indexPath.row]
        return fillDataClient(cell: cell, val: val)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item =  self.data[indexPath.row] 
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
        myVC.jobId = item.job_id
        myVC.modeView = 1
        self.navigationController?.pushViewController(myVC, animated: true)
       
        
    }
}
