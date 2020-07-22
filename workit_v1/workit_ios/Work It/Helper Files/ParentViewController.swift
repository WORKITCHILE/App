//
//  ParentViewController.swift
//  Agile Sports
//
//  Created by qw on 23/12/19.
//  Copyright © 2019 AM. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func push(controller: String){
           var myVC = UIViewController()
           myVC = (self.storyboard?.instantiateViewController(withIdentifier: controller))!
           self.navigationController?.pushViewController(myVC, animated: true)
       }
       
        func dismiss(controller: UIViewController){
            self.navigationController?.dismiss(animated: true, completion: nil)
        }

}
