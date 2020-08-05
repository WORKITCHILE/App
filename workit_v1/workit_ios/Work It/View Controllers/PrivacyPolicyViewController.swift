//
//  PrivacyPolicyViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    
    //MARK: IBOUtlets
    @IBOutlet weak var webView: WKWebView!
    
    var heading: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTermsCondition()
    }
    
    func getTermsCondition(){
        ActivityIndicator.show(view: self.view)
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_TERMS_CONDITION, method: .get, parameter: nil, objectClass: GetTNC.self, requestCode: U_TERMS_CONDITION) { response in

                   self.webView.loadHTMLString(response.data?.terms_and_conditions?.html2String ?? "", baseURL: Bundle.main.bundleURL)
               }
        
    }
    
    //MARK: IBActions
    @IBAction func acept(sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }

    
}
