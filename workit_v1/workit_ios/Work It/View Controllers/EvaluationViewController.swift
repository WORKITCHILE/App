//
//  EvaluationViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Cosmos
import Lottie

class EvaluationViewController: UIViewController {
    
    //MARK: IBOUtlets
    @IBOutlet weak var evaluationTable: ContentSizedTableView!
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var emptyView: UIView!
    
    
    var evaluationData = [GetRatingResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = Animation.named("empty_evaluation")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
      
        self.setNavigationBar()
               
        getUserRating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
    
    func getUserRating(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_RATING)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetRating.self, requestCode: U_GET_RATING) { 
            self.evaluationData = $0.data
            self.emptyView.isHidden = self.evaluationData.count != 0
            self.evaluationTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    
}

extension EvaluationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.evaluationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.evaluationData[indexPath.row]
       
        let userName =  val.rate_from_name
        let imagePath = val.rate_from_image
        
        cell.userName.text = userName
        cell.userImage.sd_setImage(with: URL(string: imagePath!),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        cell.jobName.text = val.job_name?.uppercased()
        cell.timeLabel.text = val.job_date
        cell.rateView.rating = val.rating
        cell.jobAddress.text = val.comment
        cell.card.defaultShadow()
        
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
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusContainer: UIView!
}
