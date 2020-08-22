//
//  HistoryViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, ScrollView {
    
    
    //MARK: IBOUtlets
    @IBOutlet weak var segmentControl : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        self.setNavigationBar()
        
        HistoryPageViewController.indexDelegate = self
        K_CURRENT_TAB = K_RUNNING_JOB_TAB
             /*
        self.receivedLabel.textColor = .lightGray
        self.postedLabel.textColor = .black
        self.receivedView.isHidden = true
        self.postView.isHidden = false
        
   
        if(K_CURRENT_TAB == K_HISTORY_TAB){
            self.postedLabel.text = "Posted Jobs"
            self.receivedLabel.text = "Received Jobs"
            self.titleLabel.text = "History"
        }else if(K_CURRENT_TAB == K_MYBID_TAB){
           self.postedLabel.text = "Active Bids"
           self.receivedLabel.text = "Rejected Bids"
           self.titleLabel.text = "My Bids"
        }else if(K_CURRENT_TAB == K_RUNNING_JOB_TAB){
            self.postedLabel.text = "Posted Jobs"
            self.receivedLabel.text = "Received Jobs"
            self.titleLabel.text = "Running Jobs"
        }else if(K_CURRENT_TAB == K_CURRENT_JOB_TAB){
            self.postedLabel.text = "Bids Placed"
            self.receivedLabel.text = "Running Job"
            self.titleLabel.text = "My Bids"
        }
//        */
        
        segmentControl.addTarget(self, action: #selector(HistoryViewController.indexChanged(_:)), for: .valueChanged)
        
    }
    
    
    func scrollHistoryView(index: Int) {
        
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        debugPrint(self.segmentControl.selectedSegmentIndex )
        let pageViewController = HistoryPageViewController.dataSource as! HistoryPageViewController
        if self.segmentControl.selectedSegmentIndex == 0 {
            pageViewController.setControllerFirst()
        } else if self.segmentControl.selectedSegmentIndex == 1 {
            pageViewController.setControllerSecond()
        }
    }
    
}
