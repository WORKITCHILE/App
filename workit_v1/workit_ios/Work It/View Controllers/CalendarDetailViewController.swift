
//
//  CalendarDetailViewController.swift
//  Work It
//
//  Created by qw on 18/06/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {
    //MARK:IBOutlets
    @IBOutlet weak var calenderView: UITableView!
    
    var calenderData = [CalendarJob]()
    var sufixDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.calenderView.delegate = self
        self.calenderView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        setNavigationBar()
    }
    

}

extension CalendarDetailViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calenderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*  */
        let val = self.calenderData[indexPath.row]
       
        var cellIdentifier = "CalenderViewCell"
        
        if(val.status == "PAID"){
            cellIdentifier = "CalenderViewCellPay"
        } else if(val.status == "CANCELED"){
            cellIdentifier = "CalenderViewCellCancel"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CalenderViewCell
        cell.jobDate.text = "\(sufixDate)"
        
        cell.jobTime.text = self.convertTimestampToDate(val.job_time , to: "h:mm a")
        cell.jobTitle.text = val.job_name
        cell.jobAddress.text = val.job_address
        cell.card.defaultShadow()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let job = self.calenderData[indexPath.row]
        self.getJobDetail(jobId: job.job_id)
    }
    
    func getJobDetail(jobId: String){
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_GET_SINGLE_JOB_OWNER)\(Singleton.shared.userInfo.user_id ?? "")&job_id=\(jobId )"
        
        SessionManager.shared.methodForApiCalling(url: url , method: .get, parameter: nil, objectClass: GetSingleJob.self, requestCode: U_GET_SINGLE_JOB_OWNER) {
            
            ActivityIndicator.hide()
            
           
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "bidDetail") as! BidDetailViewController
            myVC.jobData = $0?.data
            myVC.mode = "HIRE"
            self.navigationController?.pushViewController(myVC, animated: true)
            
           
            
        }
    }
}



class CalenderViewCell: UITableViewCell{
    //MARK:IBOUtlets
    @IBOutlet weak var emptyJobStatus: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var jobTime: UILabel!
    @IBOutlet weak var jobStatus: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobAddress: UILabel!
    @IBOutlet weak var card: UIView!
}
