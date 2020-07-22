//
//  CallAPIViewController.swift
//  Agile Sports
//
//  Created by qw on 23/12/19.
//  Copyright © 2019 AM. All rights reserved.
//

import UIKit

class CallAPIViewController: ParentViewController {
    
    static var shared = CallAPIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getState(completionHandler: @escaping ([GetStateResponse]) -> Void){
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_STATE, method: .get, parameter: nil, objectClass: GetState.self, requestCode: U_GET_STATE) { (response) in
            completionHandler(response.data)

        }
    }
    
    func getCategory(completionHandler: @escaping ([GetCategoryResponse]) -> Void){
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_CATEGORIES, method: .get, parameter: nil, objectClass: GetCategory.self, requestCode: U_GET_CATEGORIES) { (response) in
            completionHandler(response.data)
        }

    }
}
