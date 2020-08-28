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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
              
    
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        
        self.calenderView.estimatedRowHeight = 100
        self.calenderView.rowHeight = UITableView.automaticDimension
        
        let time = Int(Date().timeIntervalSince1970)

        self.titleDate.text = self.convertTimestampToDate(time, to: "MMM,YYYY")
        self.month = Int(self.convertTimestampToDate(time, to: "M") ) ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCalenderData(date:Int(Date().timeIntervalSince1970))
    }
    
    func getCalenderData(date: Int){
        ActivityIndicator.show(view: self.view)
        let url =  U_BASE + U_USER_CALENDER_JOBS + "?user_id=\(Singleton.shared.userInfo.user_id ?? "")&month=\(date)"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: CalendarJobs.self, requestCode: url) { (response) in
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
                self.calenderView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
            }
            
        }
    }
    
    //MARK:IBActions
    @IBAction func dateAction(_ sender: Any) {
        popupView.isHidden = false
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        popupView.isHidden = false
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.popupView.isHidden = true
        let time = Int(picker.date.timeIntervalSince1970)
        self.titleDate.text = self.convertTimestampToDate(time, to: "MMM,YYYY")
        self.month = Int(self.convertTimestampToDate(time, to: "M")) ?? 0
        self.getCalenderData(date:time)
    }
}

extension ScheduleCalenderViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let val = self.calenderData[indexPath.row]
              
               
               if(self.isFutureDate){
                 
                   if(K_CURRENT_USER == K_WANT_JOB){
                       
                   }else {
                       /*
                       //let todayData = Int(Date().timeIntervalSince1970)
                       //let futuretDate = self.convertDateToTimestamp((cell.jobDate.text ?? ""), to:  "d MMM,YYYY")
                       if(futuretDate > todayData){
                           
                       }else {
                          
                       }
                        */
                   }
                 
               }else {
                   
            
                   var jobCount:[GetJobResponse]?
                   
                   if(K_CURRENT_USER == K_POST_JOB){
                       jobCount = val.job_data?.filter{
                           $0.user_id == Singleton.shared.userInfo.user_id
                       }
                   }else {
                       jobCount = val.job_data?.filter{
                           $0.user_id != Singleton.shared.userInfo.user_id
                       }
                   }
                   
                   if(jobCount?.count==0){
                
                       
                       
                       if(K_CURRENT_USER == K_WANT_JOB){
                          
                       }else {
                          
                       }
                
                  
                   }else if(jobCount?.count == 1){
                  
                       
                    return 160.0
                   }else{
                       
                   }
               }
        
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFutureDate ? self.monthDays[self.month-1] : self.calenderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*  */
        let val = self.calenderData[indexPath.row]
        var cellIdentifier = "CalenderViewCell"
        
        if(self.isFutureDate){
          
            if(K_CURRENT_USER == K_WANT_JOB){
                
            }else {
                /*
                //let todayData = Int(Date().timeIntervalSince1970)
                //let futuretDate = self.convertDateToTimestamp((cell.jobDate.text ?? ""), to:  "d MMM,YYYY")
                if(futuretDate > todayData){
                    
                }else {
                   
                }
                 */
            }
          
        }else {
            
            let val = self.calenderData[indexPath.row]
            var jobCount:[GetJobResponse]?
            
            if(K_CURRENT_USER == K_POST_JOB){
                jobCount = val.job_data?.filter{
                    $0.user_id == Singleton.shared.userInfo.user_id
                }
            }else {
                jobCount = val.job_data?.filter{
                    $0.user_id != Singleton.shared.userInfo.user_id
                }
            }
            
            if(jobCount?.count==0){
         
                
                
                if(K_CURRENT_USER == K_WANT_JOB){
                   
                }else {
                   
                }
         
           
            }else if(jobCount?.count == 1){
                debugPrint("COUNT 1")
                
               cellIdentifier = "CalenderViewCellPay"
            }else{
                
            }
        }
        
        /* */
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CalenderViewCell

        cell.jobDate.text = "\(indexPath.row + 1) \(self.titleDate.text ?? "")"
        
        if(self.isFutureDate){
            cell.jobTime.text = "--:--"
            cell.jobTitle.text = ""
            cell.jobAddress.text = ""
            if(K_CURRENT_USER == K_WANT_JOB){
                cell.jobStatus.text =  "NO JOB SCHEDULED"
            }else {
                let todayData = Int(Date().timeIntervalSince1970)
                let futuretDate = self.convertDateToTimestamp((cell.jobDate.text ?? ""), to:  "d MMM,YYYY")
                if(futuretDate > todayData){
                    cell.jobStatus.text = "POST A JOB NOW"
                }else {
                    cell.jobStatus.text = "NO JOB SCHEDULED"
                }
            }
            cell.jobStatus.textColor = .white
        }else {
            
           
            var jobCount:[GetJobResponse]?
            
            if(K_CURRENT_USER == K_POST_JOB){
                jobCount = val.job_data?.filter{
                    $0.user_id == Singleton.shared.userInfo.user_id
                }
            }else {
                jobCount = val.job_data?.filter{
                    $0.user_id != Singleton.shared.userInfo.user_id
                }
            }
            
            if(jobCount?.count==0){
         
                cell.jobTime.text = "--:--"
                
                if(K_CURRENT_USER == K_WANT_JOB){
                    cell.emptyJobStatus.text =  "Sin Programar"
                }else {
                    let todayData = Int(Date().timeIntervalSince1970)
                    let futuretDate = self.convertDateToTimestamp((cell.jobDate.text ?? ""), to:  "d MMM,YYYY")
                    cell.emptyJobStatus.text = futuretDate > todayData ? "Postear Trabajo" : "Sin Programar"
                }
         
           
            }else if(jobCount?.count == 1){
                cell.jobTime.text = self.convertTimestampToDate(jobCount?[0].job_time ?? 0, to: "h:mm a")
                cell.jobTitle.text = jobCount?[0].job_name ?? ""
                //cell.jobStatus.text = jobCount?[0].status ?? ""
                cell.jobAddress.text = jobCount?[0].job_address ?? ""
                /*
                if(cell.jobStatus.text == K_ACCEPT || cell.jobStatus.text == K_FINISH || cell.jobStatus.text == K_START){
                    cell.jobStatus.textColor = lightGreen
                }else if(cell.jobStatus.text == K_REJECT || cell.jobStatus.text == K_CANCEL){
                    cell.jobStatus.textColor = .red
                }else if(cell.jobStatus.text == K_PAID){
                    cell.jobStatus.textColor = .green
                }else if(cell.jobStatus.text == K_POSTED){
                    cell.jobStatus.textColor = lightYellow
                }else {
                    cell.jobStatus.textColor = .white
                }
                */
            }else{
                cell.jobTime.text = ""
                cell.jobTitle.text = "Click here to view details."
                cell.jobAddress.text = ""
                cell.jobStatus.text = "\(jobCount?.count ?? 0) jobs scheduled."
                cell.jobStatus.textColor = .green
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CalenderViewCell
       
        if(self.isFutureDate){
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
            self.navigationController?.pushViewController(myVC, animated: true)
            
        }else {
            let val = self.calenderData[indexPath.row]
            var jobCount:[GetJobResponse]?
            if(K_CURRENT_USER == K_POST_JOB){
                jobCount = val.job_data?.filter{
                    $0.user_id == Singleton.shared.userInfo.user_id
                }
            }else {
                jobCount = val.job_data?.filter{
                    $0.user_id != Singleton.shared.userInfo.user_id
                }
            }
            if(jobCount?.count == 0){
                if(cell.jobStatus.text == "POST A JOB NOW"){
                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostJobViewController") as! PostJobViewController
                    self.navigationController?.pushViewController(myVC, animated: true)
                }
            }else if(jobCount?.count == 1){
                let val = jobCount?[0]
                switch val?.status {
                case K_POST_JOB:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                case K_ACCEPT:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                case K_START:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                case K_FINISH:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                case K_PAID:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                case K_REJECT:
                    let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
                    initialViewController.jobId = val?.job_id ?? ""
                    self.navigationController?.pushViewController(initialViewController, animated: true)
                    break
                case K_CANCEL:
                    if(K_CURRENT_USER == K_POST_JOB){
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }else {
                        let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                        initialViewController.jobId = val?.job_id ?? ""
                        self.navigationController?.pushViewController(initialViewController, animated: true)
                    }
                    break
                default:
                    break
                }
            }else{
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarDetailViewController") as! CalendarDetailViewController
                if(K_CURRENT_USER == K_WANT_JOB){
                  myVC.calenderData =  (self.calenderData[indexPath.row].job_data!.filter{
                    $0.user_id != Singleton.shared.userInfo.user_id
                    })
                }else {
                  myVC.calenderData =  (self.calenderData[indexPath.row].job_data!.filter{
                    $0.user_id == Singleton.shared.userInfo.user_id
                    })
                }
                
                self.navigationController?.pushViewController(myVC, animated: true)
            }
        }
    }
}
