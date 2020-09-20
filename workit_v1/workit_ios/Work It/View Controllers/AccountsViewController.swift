
//
//  AccountsViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController, ScrollAccount {
    
    //MARK: IBOUtlets
    @IBOutlet weak var segmentControl : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountPageViewController.indexDelegate = self
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        self.setNavigationBar()
        
         segmentControl.addTarget(self, action: #selector(HistoryViewController.indexChanged(_:)), for: .valueChanged)
        
    }
    
   
           
    @objc func indexChanged(_ sender: UISegmentedControl) {
    
         
           if self.segmentControl.selectedSegmentIndex == 0 {
            
              let pageViewController = AccountPageViewController.dataSource as! AccountPageViewController
              pageViewController.setControllerFirst()
            
           } else if self.segmentControl.selectedSegmentIndex == 1 {
               let pageViewController = AccountPageViewController.dataSource as! AccountPageViewController
               pageViewController.setControllerSecond()
           }
       }

    func scrollAccountView(index: Int) {
        /*
        if(index == 0){
           
            self.receivedView.isHidden = true
            self.postView.isHidden = false
        }else {
        
                   self.receivedView.isHidden = false
                   self.postView.isHidden = true
        }
        */
    }
    
 
    
}
