//
//  TermConditionsViewcontroller.swift
//  Work It
//
//  Created by Jorge Acosta on 26-12-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import WebKit

class TermConditionsViewcontroller: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        self.setNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTerms()
    }
    

    func getTerms(){
        
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_TERMS_CONDITION)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetTNC.self, requestCode: url) { [self] response in
            
            ActivityIndicator.hide()
          
            self.webView.loadHTMLString((response?.data?.terms_and_conditions!)!, baseURL:nil)
        }
    }
   

}
