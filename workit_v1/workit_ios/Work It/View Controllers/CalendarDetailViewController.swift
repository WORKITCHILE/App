
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
    var monthDays = [31,28,31,30,31,30,31,31,30,31,30,31]
    var isFutureDate = false
    var month = Int()
    var sufixDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.calenderView.delegate = self
        self.calenderView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

}

extension CalendarDetailViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
      
        return 160.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFutureDate ? self.monthDays[self.month-1] : self.calenderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*  */
        let val = self.calenderData[indexPath.row]
        var cellIdentifier = "CalenderViewCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CalenderViewCell
        cell.jobDate.text = "\(indexPath.row + 1) \(sufixDate)"
        
        if(!self.isFutureDate){
        
            cell.jobTime.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.jobTitle.text = val.job_name ?? ""
            cell.jobAddress.text = val.job_address ?? ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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
