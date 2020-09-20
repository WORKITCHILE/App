//
//  AccountSettingViewController.swift
//  Work It
//
//  Created by qw on 18/04/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class AccountSettingViewController: UIViewController, AddAccount {
    func refreshAccountTable() {
        self.getAccountData()
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var viewTopBar: View!
    @IBOutlet weak var viewForWallet: UIView!
    @IBOutlet weak var viewForCards: UIView!
    @IBOutlet weak var availBalance: DesignableUILabel!
    
    var accountData = [GetAccountsDetail]()
    var isSelectCard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if(isSelectCard){
            self.viewTopBar.isHidden = true
            self.viewForWallet.isHidden = false
            viewForCards.isHidden = true
        }else {
            self.viewTopBar.isHidden = true
            self.viewForWallet.isHidden = true
            viewForCards.isHidden = false
        }
        self.getWalletInfo()
        self.getAccountData()
        
    }
    
    func getWalletInfo(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_CREDIT + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetTransaction.self, requestCode: U_GET_CREDIT) { (response) in
           let transactionData = response.data
            self.availBalance.text = "Avl. Balance: " + "$" + (response.data?.credits == "" ? "0": (response.data?.credits ?? "0"))
            ActivityIndicator.hide()
        }
    }
    
    func getAccountData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_ACCOUNT_DETAILS + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetAccounts.self, requestCode: U_GET_ACCOUNT_DETAILS) { (response) in
            self.accountData = response.data
            self.accountTable.reloadData()
        }
    }
    
    //MARK: IBAction
    @IBAction func addAccountAction(_ sender: Any) {
        if(isSelectCard){
           let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDetailViewController") as! AccountDetailViewController
           myVC.isEditBankDetail = 2
           myVC.accountDelegate = self
            myVC.isSelectCard = true
           self.present(myVC, animated: true, completion: nil)
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDetailViewController") as! AccountDetailViewController
                              myVC.isEditBankDetail = 2
                   myVC.accountDelegate = self
                   self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    @IBAction func payWalletAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(N_SELECT_BANK_ACCOUNT), object: nil, userInfo: ["isWallet":1,"id":""])
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
}

extension AccountSettingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.accountData[indexPath.row]
        cell.jobName.text  = val.bank
        cell.userName.text = val.full_name ?? ""
        cell.jobPrice.text = (val.account_number ?? "").applyPatternOnNumbers(pattern: "#### #### #### ####", replacmentCharacter: "#")
        cell.jobTime.text = (val.account_type ?? "")
        cell.jobDescription.text =  (val.RUT ?? "")
        cell.jobDate.text = self.convertTimestampToDate(val.updated_at
            ?? 0 , to: "dd.MM.yy")
         if(isSelectCard){
            cell.buttonEdit.isHidden = true
         }else{
            cell.buttonEdit.isHidden = false
        }
        cell.editJob = {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDetailViewController") as! AccountDetailViewController
            myVC.isEditBankDetail = 1
            myVC.accountDetail = val
            myVC.accountDelegate = self
        self.navigationController?.pushViewController(myVC, animated: true)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(isSelectCard){
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(N_SELECT_BANK_ACCOUNT), object: nil, userInfo: ["isWallet":0,"id":self.accountData[indexPath.row].bank_detail_id ?? "","bank": self.accountData[indexPath.row].bank])
            
        }
    }
    
    
}
