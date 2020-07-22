//
//  EvaluationViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Cosmos

class EvaluationViewController: UIViewController {
    //MARK: IBOUtlets
    @IBOutlet weak var evaluationTable: ContentSizedTableView!
    
    @IBOutlet weak var noDataLabel: DesignableUILabel!
    
    var evaluationData = [GetRatingResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserRating()
    }
    
    func getUserRating(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_RATING + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetRating.self, requestCode: U_GET_RATING) { (response) in
            self.evaluationData = response.data
            if(self.evaluationData.count == 0){
                self.noDataLabel.isHidden = false
            }else{
                self.noDataLabel.isHidden = true
            }
            self.evaluationTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
}

extension EvaluationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.evaluationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.evaluationData[indexPath.row]
        if(val.rate_to == Singleton.shared.userInfo.user_id){
            cell.userImage.sd_setImage(with: URL(string: val.rate_from_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text =  (val.rate_from_name ?? "").formatName(name:val.rate_from_name ?? "")
                
        }else {
            cell.userImage.sd_setImage(with: URL(string: val.rate_to_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = (val.rate_to_name ?? "").formatName(name:val.rate_to_name ?? "")
                
        }
        cell.jobName.text = val.job_name
        cell.timeLabel.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.rateView.rating = Double(val.rating ?? "0")!
        cell.jobAddress.text = val.job_address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
        myVC.jobId = self.evaluationData[indexPath.row].job_id ?? ""
        myVC.isEvaluationScreen = true
        myVC.evaluationRating = self.evaluationData[indexPath.row].rating ?? "0"
        myVC.evaluationText = self.evaluationData[indexPath.row].comment ?? ""
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
}


class EvaluationTableView: UITableViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userName: DesignableUILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var timeLabel: DesignableUILabel!
    @IBOutlet weak var jobName: DesignableUILabel!
    @IBOutlet weak var jobAddress: DesignableUILabel!
    @IBOutlet weak var count: DesignableUILabel!
}
