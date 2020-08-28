
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
    @IBOutlet weak var selectedMonth: DesignableUITextField!
    @IBOutlet weak var calenderView: UITableView!
    
    var calenderData = [GetJobResponse]()
    var monthDays = [31,28,31,30,31,30,31,31,30,31,30,31]
    var isFutureDate = false
    var month = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calenderView.estimatedRowHeight = 90
        self.calenderView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    //MARK:IBActions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CalendarDetailViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calenderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderViewCell") as! CalenderViewCell
        let jobData = self.calenderData[indexPath.row]
        cell.jobDate.text =  self.convertTimestampToDate(jobData.job_time ?? 0, to: "d MMM,YYYY")
        cell.jobTime.text = self.convertTimestampToDate(jobData.job_time ?? 0, to: "h:mm a")
        cell.jobTitle.text = jobData.job_name ?? ""
        cell.jobStatus.text = jobData.status ?? ""
        cell.jobAddress.text = jobData.job_address ?? ""
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CalenderViewCell
        let val = self.calenderData[indexPath.row]
        switch val.status {
        case K_POST_JOB:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
            initialViewController.jobId = val.job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        case K_ACCEPT:
            if(K_CURRENT_USER == K_WANT_JOB){
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                initialViewController.jobId = val.job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }else {
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                initialViewController.jobId = val.job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            break
        case K_START:
            if(K_CURRENT_USER == K_WANT_JOB){
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                initialViewController.jobId = val.job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }else {
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                initialViewController.jobId = val.job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            break
        case K_FINISH:
            if(K_CURRENT_USER == K_WANT_JOB){
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartJobViewController") as! StartJobViewController
                                       initialViewController.jobId = val.job_id ?? ""
                                       self.navigationController?.pushViewController(initialViewController, animated: true)
            }else {
                let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
                initialViewController.jobId = val.job_id ?? ""
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            
            break
        case K_PAID:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = val.job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        case K_REJECT:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewJobViewController") as! ViewJobViewController
            initialViewController.jobId = val.job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        case K_CANCEL:
            let   initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
            initialViewController.jobId = val.job_id ?? ""
            self.navigationController?.pushViewController(initialViewController, animated: true)
            break
        default:
            break
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
}
