//
//  PaymentFlowViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 20-09-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import WebKit

class PaymentFlowViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    public var amount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       

        
        createPayment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
     
    }
    
    func navigateToPaymentWebFlow(_ url : String){
        let url = URL(string: url)!
        webView.loadRequest(URLRequest(url: url))
    }
    
    func createPayment(){
      ActivityIndicator.show(view: self.view)
        let params : [String : String] = [
            "user_id" : Singleton.shared.userInfo.user_id ?? "" ,
            "email" : Singleton.shared.userInfo.email ?? "" ,
            "amount" : String(amount)
        ]
        
        
        
      let url = "\(U_BASE)\(U_POST_PAYMENT)"
        

        
      SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: params, objectClass: GetTransaction.self, requestCode: U_POST_PAYMENT) { response in
              
            self.navigateToPaymentWebFlow(response.payment?.url ?? "")

          debugPrint(response.payment?.url)
      }
       
      }
    
   
   
}
