//
//  ScheduleCalenderViewController.swift
//  Work It
//
//  Created by qw on 18/06/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class ScheduleCalenderViewController: UIViewController {
    //MARK:IBOutlets
    @IBOutlet weak var titleDate : UILabel!
    @IBOutlet weak var calenderView: UITableView!
    @IBOutlet fileprivate var picker : MonthYearPickerView!
    @IBOutlet weak var popupView: UIView!
    
    var calenderData = [CalendarJobsResponse]()
    var monthDays = [31,28,31,30,31,30,31,31,30,31,30,31]
    var isFutureDate = false
    var month = Int()
    var sufixDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        
        self.calenderView.estimatedRowHeight = 100
        self.calenderView.rowHeight = UITableView.automaticDimension
        
        let time = Int(Date().timeIntervalSince1970)

        self.titleDate.text = self.convertTimestampToDate(time, to: "MMMM,YYYY")
        sufixDate = self.convertTimestampToDate(time, to: "MMM YYYY")
        
        self.month = Int(self.convertTimestampToDate(time, to: "M") ) ?? 0
        self.popupView.isHidden =  true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCalenderData(date:Int(Date().timeIntervalSince1970))
    }
    
    func getCalenderData(date: Int){
        ActivityIndicator.show(view: self.view)
        let url =  "\(U_BASE)\(U_USER_CALENDER_JOBS)?user_id=\(Singleton.shared.userInfo.user_id ?? "")&month=\(date)"
 
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: CalendarJobs.self, requestCode: url) { response in
            
            ActivityIndicator.hide()
            
            self.calenderData = response.data
            
            if(self.calenderData.count == 0){
                self.isFutureDate = true
                self.calenderView.reloadData()
                self.calenderView.setContentOffset(.zero, animated: false)
                let indexPath = NSIndexPath(row:0, section: 0)
                self.calenderView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                
            }else {
                self.isFutureDate = false
                let date = self.convertTimestampToDate(Int(Date().timeIntervalSince1970), to: "d")
                self.calenderView.reloadData()
                let indexPath = NSIndexPath(row: (Int(date) ?? 0) - 1, section: 0)
                debugPrint(indexPath)
                self.calenderView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
            }
            
        }
    }
    
    //MARK:IBActions
    @IBAction func dateAction(_ sender: Any) {
        popupView.isHidden = false
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        popupView.isHidden = true
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.popupView.isHidden = true
        let time = Int(picker.date.timeIntervalSince1970)
        self.titleDate.text = self.convertTimestampToDate(time, to: "MMM, YYYY")
        self.month = Int(self.convertTimestampToDate(time, to: "M")) ?? 0
        self.getCalenderData(date:time)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let calendarDetail = segue.destination as! CalendarDetailViewController
        calendarDetail.sufixDate = sufixDate
     
        calendarDetail.calenderData = self.calenderData[calenderView.indexPathForSelectedRow?.row ?? 0].job_data ?? []
    }
}

extension ScheduleCalenderViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
               
        if(!self.isFutureDate){
            let val = self.calenderData[indexPath.row]
            let jobCount = val.job_data
            
           if(jobCount?.count == 1){
                return 160.0
           }
        }
        
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFutureDate ? self.monthDays[self.month - 1] : self.calenderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*  */
        
        if(self.isFutureDate){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderNoProgramViewCell") as! CalenderViewCell
            cell.jobDate.text = "\(indexPath.row + 1) \(sufixDate)"
            return cell
        }
       
        let val = self.calenderData[indexPath.row]
        var cellIdentifier = "CalenderNoProgramViewCell"
        let jobCount = val.job_data
        let jobDetail = jobCount?.first
        
        if(jobCount?.count == 1){
            cellIdentifier = "CalenderViewCell"
            if(jobDetail?.status == "PAID"){
                cellIdentifier = "CalenderPayViewCell"
            } else if(jobDetail?.status == "CANCELED") {
                cellIdentifier = "CalenderCancelViewCell"
            }
            
        } else if(jobCount!.count > 1){
            cellIdentifier = "CalenderMoreViewCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CalenderViewCell
        cell.jobDate.text = "\(indexPath.row + 1) \(sufixDate)"
        
        if(jobCount?.count == 1){
            if(!self.isFutureDate){
               if(jobCount?.count == 1){
                cell.jobTime.text = self.convertTimestampToDate(jobDetail?.job_time ?? 0, to: "h:mm a")
                cell.jobTitle.text = jobDetail?.job_name.uppercased() ?? ""
                cell.jobAddress.text = jobDetail?.job_address ?? ""
               }
            }
            
        } else if(jobCount!.count > 1){
            cell.jobTitle.text = "\(jobCount!.count) Trabajos programados"
        }
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
