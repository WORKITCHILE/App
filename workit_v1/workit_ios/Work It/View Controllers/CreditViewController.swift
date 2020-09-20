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
    @IBOutlet weak var totalCredit: UILabel!
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
            self.totalCredit.text = "$" + ($0.data?.credits == "" ? "0": ($0.data?.credits ?? "0"))
            self.transactionTable.reloadData()
            ActivityIndicator.hide()
            self.emptyView.isHidden = self.transactionData?.transactions?.count ?? 0 > 0
        }
    }
    

    
    @IBAction func addAction(_ sender: Any) {
        /*
        if(self.amountField.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter some amount to add into your wallet")
        }else {
            self.amountField.text?.replacingOccurrences(of: "$", with: "")
            ActivityIndicator.show(view: self.view)
            let param : [String:Any] = [
                "user_id":Singleton.shared.userInfo.user_id ?? "",
                "amount":self.amountField.text ?? "0"
            ]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_ADD_CREDIT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_ADD_CREDIT) { (response) in
                ActivityIndicator.hide()
                self.amountField.text = ""
               Singleton.shared.showToast(text: "Amount credited to your wallet")
                self.getWalletInfo()
    
            }
        }
        */
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
