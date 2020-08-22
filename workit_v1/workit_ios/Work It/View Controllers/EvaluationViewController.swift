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

        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
      
        self.setNavigationBar()
               
        getUserRating()
    }
    
    func getUserRating(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_RATING)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetRating.self, requestCode: U_GET_RATING) { 
            self.evaluationData = $0.data
            self.noDataLabel.isHidden = self.evaluationData.count != 0
            self.evaluationTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! AcceptJobViewController
        
        myVC.isEvaluationScreen = true
        myVC.jobId = self.evaluationData[self.evaluationTable.indexPathForSelectedRow!.row].job_id ?? ""
        myVC.evaluationRating = self.evaluationData[self.evaluationTable.indexPathForSelectedRow!.row].rating ?? "0"
        myVC.evaluationText = self.evaluationData[self.evaluationTable.indexPathForSelectedRow!.row].comment ?? ""
    }
 
    
}

extension EvaluationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.evaluationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.evaluationData[indexPath.row]
        let isMyProfile = val.rate_to == Singleton.shared.userInfo.user_id
        let userName = isMyProfile ? val.rate_from_name : val.rate_to_name
        let imagePath = isMyProfile ? val.rate_from_image : val.rate_to_image
        
        cell.userName.text = userName?.formatName()
        cell.userImage.sd_setImage(with: URL(string: imagePath!),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.jobName.text = val.job_name
        cell.timeLabel.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
        cell.rateView.rating = Double(val.rating ?? "0")!
        cell.jobAddress.text = val.job_address
        
        return cell
    }

}


class EvaluationTableView: UITableViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var userImage: ImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var jobName: UILabel!
    @IBOutlet weak var jobAddress: UILabel!
    @IBOutlet weak var count: UILabel!
}
