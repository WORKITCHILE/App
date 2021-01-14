//
//  AccountSettingViewController.swift
//  Work It
//
//  Created by qw on 18/04/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class AccountSettingViewController: UIViewController {
    
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
    private var bank_id = ""
    private var account_type = ["Cuenta Corriente", "Cuenta Vista / Cuenta Rut", "Cuenta Ahorro"]

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
            self.accountData = response!.data
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
        bank_id = (val?.bank_detail_id)!
        bankNameLabel.text  = val?.bank?.uppercased()
        userNameLabel.text = val?.full_name ?? ""
        accountNumberLabel.text = (val?.account_number ?? "").applyPatternOnNumbers(pattern: "#### #### #### ####", replacmentCharacter: "#")
        accountTypeLabel.text = account_type[Int(val?.account_type ?? "0")!]
        rutLabel.text =  (val?.RUT ?? "")
        createdLabel.text = self.convertTimestampToDate(val?.updated_at
            ?? 0 , to: "dd/MM/yyyy")
        
      
    }
    
    private func requestDeletedAccount(){
        ActivityIndicator.show(view: self.view)
        
        let url = "\(U_BASE)\(U_DELETE_BANK_ACCOUNT)"
        let params: [String : String] = [
            "user_id": Singleton.shared.userInfo.user_id!,
            "bank_id": bank_id
        ]
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: params, objectClass: GetAccounts.self, requestCode: U_DELETE_BANK_ACCOUNT) { [self] (response) in
            
            self.getAccountData()
     
        }
    }
    
    @IBAction func deleteAccount(_ sender: AnyObject){
        let alert = UIAlertController(title: "Workit", message: "¿Estás seguro que quieres eliminar esta cuenta?", preferredStyle: .alert)
                  
           alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
            self.requestDeletedAccount()
             
           })
         
           alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

           self.present(alert, animated: true)
    }
}

