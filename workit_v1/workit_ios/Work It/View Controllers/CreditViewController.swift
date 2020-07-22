//
//  CreditViewController.swift
//  Work It
//
//  Created by qw on 20/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class CreditViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var totalCredit: UILabel!
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var noTransactionLabel: DesignableUILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var amountField: UITextField!
    
    var transactionData : GetTransactionResponse?
    var isBackButtonHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.isHidden = self.isBackButtonHidden
        self.getWalletInfo()
    }
    
    func getWalletInfo(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_CREDIT + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetTransaction.self, requestCode: U_GET_CREDIT) { (response) in
            self.transactionData = response.data
            self.totalCredit.text = "$" + (response.data?.credits == "" ? "0": (response.data?.credits ?? "0"))
            self.transactionTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    
    @IBAction func addCreditAction(_ sender: Any) {
        self.popUpView.isHidden = false
        
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.amountField.text = ""
        self.popUpView.isHidden = true
    }
    
    @IBAction func addAction(_ sender: Any) {
        if(self.amountField.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter some amount to add into your wallet")
        }else {
            self.popUpView.isHidden = true
            self.amountField.text?.replacingOccurrences(of: "$", with: "")
            ActivityIndicator.show(view: self.view)
            let param = [
                "user_id":Singleton.shared.userInfo.user_id ?? "",
                "amount":self.amountField.text ?? "0"
            ] as? [String:Any]
            SessionManager.shared.methodForApiCalling(url: U_BASE + U_ADD_CREDIT, method: .post, parameter: param, objectClass: Response.self, requestCode: U_ADD_CREDIT) { (response) in
                ActivityIndicator.hide()
                self.amountField.text = ""
               Singleton.shared.showToast(text: "Amount credited to your wallet")
                self.getWalletInfo()
    
            }
        }
    }
    
    
}

extension CreditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.transactionData?.transactions?.count == 0){
            self.noTransactionLabel.isHidden = false
        }else {
            self.noTransactionLabel.isHidden = true
        }
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
