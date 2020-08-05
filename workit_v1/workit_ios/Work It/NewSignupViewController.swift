//
//  SignupViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 04-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import PostalAddressRow
import ImageRow

class NewSignupViewController : FormViewController, UIDocumentPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }

        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        form
            
            +++ Section()
                <<< SwitchRow("switchRowTag") { row in
                    row.title = "you are a worker?"
                }.onChange { row in
                    row.title = (row.value ?? false) ? "Worker" : "Not Worker"
                    row.updateCell()
                }
            
            +++ Section(header:"Worker Profile", footer: nil) {
                    $0.hidden = isWorker()
                }
            
                <<< TextAreaRow(){
                    $0.placeholder = "Profile description"
                }
            
                <<< TextRow(){
                    $0.title = "Occupation"
                }
            
                <<< TextRow(){
                    $0.title = "Rut"
                    $0.placeholder = "11.111.111-11"
                }
            
                <<< ButtonRow(){
                    $0.title = "Upload Record"
                }.onCellSelection({ cellOf, row in
                    let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
                    importMenu.delegate = self
                    importMenu.modalPresentationStyle = .formSheet
                    self.present(importMenu, animated: true, completion: nil)
                })
            
            +++ Section(header:"Account Data", footer: nil)
                <<< EmailRow(){
                    $0.title = "Email"
                }
        
                <<< PasswordRow("password"){
                    $0.title = "Password"
                }
        
                <<< PasswordRow(){
                    $0.title = "Confirm Password"
                    $0.add(rule: RuleEqualsToRow(form: form, tag: "password"))
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
            
            +++ Section(header:"Profile Data", footer: nil)
                <<< ImageRow() {
                    $0.title = "Profile Photo"
                    $0.sourceTypes = .All
                    $0.clearAction = .no
                }
            
                <<< NameRow(){
                    $0.title = "Name"
                    var rules = RuleSet<String>()
                    rules.add(rule: RuleRequired())
      
                    $0.add(ruleSet: rules)
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                }
            
                <<< NameRow(){
                    $0.title = "Father Last Name"
                }
            
                <<< NameRow(){
                    $0.title = "Mother Last Name"
                }
            
                <<< PhoneRow(){
                    $0.title = "Phone Number"
                }
        
            
                <<< DateRow(){
                    $0.title = "Date Birth"
                }
            

            +++ Section()
                <<< CheckRow(){
                    $0.title = "Accept terms & conditions"
                }
            
                <<< ButtonRow(){
                    $0.title = "Read terms & conditions"
                }
                .onCellSelection({ cellOf, row in
                    
                    let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                    let myMC = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController"
                    )
                    self.show(myMC, sender: nil)
                   debugPrint("read")
                })
                
                <<< ButtonRow(){
                    $0.title = "Send"
                }.onCellSelection({ cellOf, row in
                    
                   debugPrint("SEND")
                })
                
                

    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.navigationController?.navigationBar.isHidden = false
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled")
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("didPickDocuments at \(urls)")
    }
    
    func isWorker() -> Condition {
        return Condition.function(["switchRowTag"], { form in
            return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
        })
    }

}


