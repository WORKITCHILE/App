//
//  VendorReviewsViewController.swift
//  Work It
//
//  Created by qw on 03/06/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class VendorReviewsViewController: UIViewController {
    //MARK:IBOutlets
    @IBOutlet weak var evaluationTable: UITableView!
    @IBOutlet weak var noDataLabel: DesignableUILabel!
    
    var userId = String()
    var evaluationData = [GetRatingResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getReviewList()
    }
    
        func getReviewList(){
            ActivityIndicator.show(view: self.view)
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_RATING + "\(userId)&type=WORK", method: .get, parameter: nil, objectClass: GetRating.self, requestCode: U_GET_RATING) { (response) in
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
        
    }

    extension VendorReviewsViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.evaluationData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
            let val = self.evaluationData[indexPath.row]
            cell.userImage.sd_setImage(with: URL(string: val.rate_from_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.userName.text = val.rate_from_name!.formatName()
            cell.timeLabel.text = self.convertTimestampToDate(val.job_time ?? 0, to: "h:mm a")
            cell.rateView.rating = Double(val.rating ?? "0")!
            cell.jobAddress.text = val.comment
            return cell
        }
    }
