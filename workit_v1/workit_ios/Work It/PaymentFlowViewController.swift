//
//  PaymentFlowViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 20-09-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import WebKit


protocol PaymentDelegate {
    func paymentComplete(response : GetTransaction?)
}

class PaymentFlowViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    public var amount = 0
    public var vendor_id = "2"
    public var marketplace = ""
    private var response : GetTransaction?
    
    var delegate : PaymentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        webView.navigationDelegate = self
        
        createPayment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
     
    }
    
    func navigateToPaymentWebFlow(_ url : String){
        
        let url = URL(string: url)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.url?.host) != nil {
            
            debugPrint("PAYENT", navigationAction.request.url!.absoluteString)
            
            let absUrl: String = navigationAction.request.url!.absoluteString 
            let isResultUrl : Bool = absUrl.caseInsensitiveHasPrefix( "https://payment.workitapp.cl/urlreturn")
            
            if(isResultUrl){
                if(delegate != nil){
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.paymentComplete(response: self.response)
                }
            }
           
        }

        decisionHandler(.allow)
    }
    
    func createPayment(){
    
        ActivityIndicator.show(view: self.view)
        
        let params : [String : Any] = [
            "user_id" : Singleton.shared.userInfo.user_id ?? "" ,
            "email" : Singleton.shared.userInfo.email ?? "" ,
            "amount" : amount,
            "vendor_id": vendor_id,
            "marketplace": marketplace
        ]
        
        let url = "\(U_BASE)\(U_POST_PAYMENT)"
        
          SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: params, objectClass: GetTransaction.self, requestCode: U_POST_PAYMENT) { response in
                
                self.response = response
               
            self.navigateToPaymentWebFlow(response?.data?.url ?? "")
            
          }
       
      }
    
   
   
}
