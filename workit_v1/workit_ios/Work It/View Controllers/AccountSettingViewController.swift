//
//  AccountSettingViewController.swift
//  Work It
//
//  Created by qw on 18/04/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class AccountSettingViewController: UIViewController, AddAccount {
    
    //MARK: IBOutlets
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var emptyView : UIView!
           
    var accountData = [GetAccountsDetail]()
    var isSelectCard = false

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.getAccountData()
        
        let starAnimation = Animation.named("add_account")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
    
    func getAccountData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_ACCOUNT_DETAILS + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: GetAccounts.self, requestCode: U_GET_ACCOUNT_DETAILS) { (response) in
            self.accountData = response.data
            self.accountTable.reloadData()
            self.emptyView.isHidden = self.accountData.count > 0
        }
    }
    
    func refreshAccountTable() {
        self.getAccountData()
    }
}

extension AccountSettingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        let val = self.accountData[indexPath.row]
        cell.jobName.text  = val.bank?.uppercased()
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
