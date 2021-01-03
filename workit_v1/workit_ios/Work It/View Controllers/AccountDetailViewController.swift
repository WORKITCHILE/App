//
//  AccountDetailViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController, SelectFromPicker {
    
    func selectedItem(name: String, id: Int) {
        if(currentPicker == 1){
            self.bankName.text = name
            self.sbif = self.bankNames.filter { $0["label"] == name }.first!["sbif"]!
        }else if(currentPicker == 2){
            self.accountType.text = name
            self.accountTypeId = "\(id)"
        }
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var bankName: DesignableUITextField!
    @IBOutlet weak var accountType: DesignableUITextField!
    @IBOutlet weak var accountNumber: DesignableUITextField!
    @IBOutlet weak var userName: DesignableUITextField!
    @IBOutlet weak var idNumber: DesignableUITextField!
    
    
    var bankNames = [
        [
            "label":"BancoEstado",
            "sbif":"0012"
        ],
        [
            "label":"Banco de Chile / Banco Edwards / Citi",
            "sbif":"0001"
        ],
        [
            "label":"Banco Internacional",
            "sbif":"0009"
        ],
        [
            "label":"Scotiabank Chile",
            "sbif":"0014"
        ],
        [
            "label": "Banco de Crédito e Inversiones",
            "sbif":"0016"
        ],
        [
            "label":"Corpbanca",
            "sbif":"0027"
        ],
        [
            "label" : "Banco Bice",
            "sbif" : "0028"
        ],
        [
            "label":"HSBC Bank",
            "sbif":"0031"
        ],
        [
            "label":"Banco Santander",
            "sbif":"0037"
        ],
        [
            "label":"Banco Itaú Chile",
            "sbif":"0039"
        ],
        [
            "label": "Banco Security",
            "sbif":"0049"
        ],
        [
            "label": "Banco Falabella",
            "sbif" : "0051"
        ],
        [
            "label": "Banco Ripley",
            "sbif":"0053"
        ],
        [
            "label" : "Rabobank Chile",
            "sbif" : "0054"
        ],
        [
            "label" : "Banco Consorcio",
            "sbif": "0055"
        ],
        [
            "label": "Banco Penta",
            "sbif":"0056"
        ],
        [
            "label": "Banco Paris",
            "sbif":"0057"
        ],
        [
            "label": "BBVA",
            "sbif":"0504"
        ]
    ]
    

    var accountsType = ["Cuenta Corriente", "Cuenta Vista / Cuenta Rut", "Cuenta Ahorro"]
    var currentPicker = Int()
    var accountDetail = GetAccountsDetail()
    var isSelectCard = false
    var sbif = ""
    var accountTypeId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.idNumber.delegate = self
        self.accountNumber.delegate = self
        setNavigationBar()
       
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
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
      
        let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerData = self.accountsType
        myVC.pickerDelegate = self
        self.currentPicker = 2
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func selectBankAction(_ sender: Any) {
        
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
      
        let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerData = self.bankNames.map({ $0["label"]! })
        myVC.pickerDelegate = self
        self.currentPicker = 1
        self.present(myVC, animated: true, completion: nil)
    }

    
    @IBAction func bidAction(_ sender: Any) {
        if(userName.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu nombre")
            return
        }else if(idNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu rut")
            return
        }else if(bankName.text!.isEmpty){
            Singleton.shared.showToast(text: "Elige un banco")
            return
        }else if(accountType.text!.isEmpty){
            Singleton.shared.showToast(text: "Elige un tipo de cuenta")
            return
        }else if(accountNumber.text!.isEmpty){
            Singleton.shared.showToast(text: "Ingresa tu numero de cuenta")
            return
        }
        
        let card = self.accountNumber.text?.replacingOccurrences(of: " ", with: "")
        ActivityIndicator.show(view: self.view)
        
        
        let param: [String:Any] = [
            "user_id":Singleton.shared.userInfo.user_id!,
            "email":Singleton.shared.userInfo.email!,
            "phone":Singleton.shared.userInfo.contact_number!,
            "RUT": self.idNumber.text,
            "full_name":self.userName.text ?? "",
            "bank":self.bankName.text,
            "sbif": self.sbif,
            "account_number": card ?? "",
            "account_type": accountTypeId
            ]
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_POST_BANK_DETAIL, method: .post, parameter: param, objectClass: Response.self, requestCode: U_POST_BANK_DETAIL) { (response) in
            ActivityIndicator.hide()
            Singleton.shared.showToast(text: "Cuenta Agregada exitosamente")
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}

extension AccountDetailViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == idNumber){
            
            
            let str = "\(textField.text ?? "")"
            let regex = try! NSRegularExpression(pattern: "[^_0-9kK]+", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, max(str.count - 1, 0))
            let modString = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "")
                      
            let formatter = NumberFormatter()
            formatter.groupingSeparator = "."
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
          
            if string != "" {
              
                if let doubleVal = Double(modString) {
                    let requiredString = formatter.string(from: NSNumber.init(value: doubleVal))
                    textField.text = "\(requiredString ?? "")-"
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

