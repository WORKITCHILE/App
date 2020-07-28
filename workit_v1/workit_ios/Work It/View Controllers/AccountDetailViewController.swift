//
//  AccountDetailViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

protocol AddAccount{
    func refreshAccountTable()
}

class AccountDetailViewController: UIViewController, SelectFromPicker {
    func selectedItem(name: String, id: Int) {
        if(currentPicker == 1){
            self.bankName.text = name
        }else if(currentPicker == 2){
            self.accountType.text = name
        }
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var bankName: DesignableUITextField!
    @IBOutlet weak var accountType: DesignableUITextField!
    @IBOutlet weak var accountNumber: DesignableUITextField!
    @IBOutlet weak var userName: DesignableUITextField!
    @IBOutlet weak var idNumber: DesignableUITextField!
    @IBOutlet weak var viewBackButton: UIView!
    @IBOutlet weak var headingLabel: DesignableUILabel!
    
    
    var bankNames = ["Banco de Chile / Banco Edwards / Citi","Banco Internacional", "Scotiabank Chile", "Banco de Crédito e Inversiones", "Corpbanca", "Banco Bice", "HSBC Bank", "Banco Santander", "Banco Itaú Chile", "Banco Security", "Banco Falabella", "Deutsche Bank", "Banco RIpley", "Rabobank Chile", "Banco Consorcio", "Banco Penta", "Banco Paris", "BBVA"]
    var accountsType = ["Current", "Saving"]
    var currentPicker = Int()
    var accountDetail = GetAccountsDetail()
    var isEditBankDetail = 0
    var accountDelegate:AddAccount?  = nil
    var isSelectCard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.idNumber.delegate = self
        self.accountNumber.delegate = self
        if(self.isEditBankDetail == 1){
            self.headingLabel.text = "Edit your bank account details for the deposit of your service"
            self.viewBackButton.isHidden = false
            self.userName.text = accountDetail.full_name
            self.idNumber.text = accountDetail.RUT
            self.accountNumber.text = accountDetail.account_number
            self.accountType.text = accountDetail.account_type
            self.bankName.text = accountDetail.bank
        }else if(self.isEditBankDetail == 2){
            self.viewBackButton.isHidden = false
        }
    }
    
    func getProfileData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_PROFILE + (Singleton.shared.userInfo.user_id ?? ""), method: .get, parameter: nil, objectClass: LoginResponse.self, requestCode: U_GET_PROFILE) { (response) in
            Singleton.shared.userInfo = response.data!
            Singleton.saveUserInfo(data:Singleton.shared.userInfo)
            ActivityIndicator.hide()
        }
    }
    
    //MARK:IBACtion
    @IBAction func accountTypeAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerData = self.accountsType
        myVC.pickerDelegate = self
        self.currentPicker = 2
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func selectBankAction(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerData = self.bankNames
        myVC.pickerDelegate = self
        self.currentPicker = 1
        self.present(myVC, animated: true, completion: nil)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func bidAction(_ sender: Any) {
        if(userName.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter full name")
        }else if(idNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter ID Number")
        }else if(bankName.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter your bank name")
        }else if(accountType.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter account type")
        }else if(accountNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Enter account number")
        }else {
            if(self.isEditBankDetail == 1){
                let card = self.accountNumber.text?.replacingOccurrences(of: " ", with: "")
                ActivityIndicator.show(view: self.view)
                let param:[String:Any] = [
                    "user_id": Singleton.shared.userInfo.user_id,
                    "bank_detail_id":self.accountDetail.bank_detail_id ?? "",
                    "RUT":self.idNumber.text ?? "",
                    "full_name":self.userName.text ?? "",
                    "bank":self.bankName.text ?? "",
                    "account_number":card ?? "",
                    "account_type":self.accountType.text ?? ""
                ]
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_EDIT_BANK_DETAILS, method: .post, parameter: param, objectClass: Response.self, requestCode: U_EDIT_BANK_DETAILS) { (response) in
                    Singleton.shared.showToast(text: "Successfully updated bank details")
                    ActivityIndicator.hide()
                    self.accountDelegate?.refreshAccountTable()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }else{
                let card = self.accountNumber.text?.replacingOccurrences(of: " ", with: "")
                ActivityIndicator.show(view: self.view)
                let param = [
                    "user_id":Singleton.shared.userInfo.user_id,
                    "RUT":self.idNumber.text,
                    "full_name":self.userName.text,
                    "bank":self.bankName.text,
                    "account_number":card,
                    "account_type":self.accountType.text
                    ] as? [String:Any]
                SessionManager.shared.methodForApiCalling(url: U_BASE + U_POST_BANK_DETAIL, method: .post, parameter: param, objectClass: Response.self, requestCode: U_POST_BANK_DETAIL) { (response) in
                    ActivityIndicator.hide()
                    Singleton.shared.showToast(text: "Successfully added bank details")
                    if(self.isEditBankDetail == 2){
                        self.accountDelegate?.refreshAccountTable()
                        if(self.isSelectCard){
                            self.dismiss(animated: true, completion: nil)
                        }else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else if(self.isEditBankDetail == 3){
                        self.getProfileData()
                        self.accountDelegate?.refreshAccountTable()
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.getProfileData()
                            if(K_CURRENT_USER == K_WANT_JOB){
                                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                                self.navigationController?.pushViewController(myVC, animated: true)
                            }else {
                                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
                                K_CURRENT_TAB = ""
                                self.navigationController?.pushViewController(myVC, animated: true)
                            }
                      
                    }
                    
                }
            }
        }
    }
    
}

extension AccountDetailViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == idNumber){
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92 || textField.text!.count <= 9) {
                    return true
                }else {
                    return false
                }
            }
        }else if(textField == accountNumber){
            let currentCharacterCount = self.accountNumber.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            self.accountNumber.text = self.accountNumber.text?.applyPatternOnNumbers(pattern: "#### #### #### ####", replacmentCharacter: "#")
            return newLength <= 19
        }
        return true
    }
}

