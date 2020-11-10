//
//  CreditViewController.swift
//  Work It
//
//  Created by qw on 20/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class CreditViewController: UIViewController {
    
    
    //MARK: IBOutlets
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var emptyView : UIView!
    @IBOutlet weak var animation: AnimationView?
     
    var transactionData : GetTransactionResponse?
    var isBackButtonHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getWalletInfo()
        
        let starAnimation = Animation.named("wallet")
        animation!.animation = starAnimation
        animation?.loopMode = .loop 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
        
    
    func getWalletInfo(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_CREDIT)\(Singleton.shared.userInfo.user_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetTransaction.self, requestCode: U_GET_CREDIT) {
            self.transactionData = $0.data
            self.transactionTable.reloadData()
            ActivityIndicator.hide()
            self.emptyView.isHidden = self.transactionData?.transactions?.count ?? 0 > 0
        }
    }
    
}

extension CreditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.transactionData?.transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.transactionData?.transactions?[indexPath.row]

            cell.userImage.sd_setImage(with: URL(string: val?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        if(val?.transaction_type == "CREDIT"){
            if(val?.transaction_for == "JOB"){
                cell.userName.text = val?.opposite_user ?? ""
            }else {
                cell.userName.text = val?.user_name ?? ""
            }
            cell.jobAddress.text = "Credited to wallet"
            cell.count.text = "$" + (val?.amount ?? "")
            cell.count.textColor = lightBlue
        }else if(val?.transaction_type == "DEBIT"){
             cell.userName.text = val?.opposite_user ?? val?.user_name ?? ""
            if(val?.payment_option == "BANK"){
              cell.jobAddress.text = "Debited from bank"
            }else{
              cell.jobAddress.text = "Debited from wallet"
            }
            cell.count.text = "$" + (val?.amount ?? "")
            cell.count.textColor = .red
        }
        cell.timeLabel.text = self.convertTimestampToDate(val?.created_at ?? 0, to: "MMM dd, h:mm a")
        cell.card.defaultShadow()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AcceptJobViewController") as! AcceptJobViewController
        myVC.jobId = self.transactionData?.transactions?[indexPath.row].job_id
        if(myVC.jobId != nil){
           self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
}
