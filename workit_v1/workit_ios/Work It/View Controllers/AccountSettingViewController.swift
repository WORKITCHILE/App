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
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var emptyView : UIView!
    
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var rutLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
           
    var accountData = [GetAccountsDetail]()
    var isSelectCard = false

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        let starAnimation = Animation.named("add_account")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.cardView.defaultShadow()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
      
        self.setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
        self.getAccountData()
    }
    
    func getAccountData(){
        
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_GET_ACCOUNT_DETAILS)\((Singleton.shared.userInfo.user_id ?? ""))"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetAccounts.self, requestCode: U_GET_ACCOUNT_DETAILS) { [self] (response) in
            ActivityIndicator.hide()
            self.accountData = response.data
            self.emptyView.isHidden = self.accountData.count > 0
            if(self.accountData.count > 0){
                self.fillData()
            }
        }
    }
    
    func refreshAccountTable() {
        self.getAccountData()
    }
    
    func fillData(){
        let val = self.accountData.first
        bankNameLabel.text  = val?.bank?.uppercased()
        userNameLabel.text = val?.full_name ?? ""
        accountNumberLabel.text = (val?.account_number ?? "").applyPatternOnNumbers(pattern: "#### #### #### ####", replacmentCharacter: "#")
        accountTypeLabel.text = (val?.account_type ?? "")
        rutLabel.text =  (val?.RUT ?? "")
        createdLabel.text = self.convertTimestampToDate(val?.updated_at
            ?? 0 , to: "dd.MM.yy")
        
      
    }
}

