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
    @IBOutlet weak var postedLabel: UILabel!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var receivedView: UIView!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var titleLabel: DesignableUILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryPageViewController.indexDelegate = self
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
        
    }
    
    func scrollHistoryView(index: Int) {
        if(index == 0){
            self.receivedLabel.textColor = .lightGray
            self.postedLabel.textColor = .black
            self.receivedView.isHidden = true
            self.postView.isHidden = false
        }else {
            self.receivedLabel.textColor = .black
                   self.postedLabel.textColor = .lightGray
                   self.receivedView.isHidden = false
                   self.postView.isHidden = true
        }
    }
    
    //MARK: BACtions
    @IBAction func postedAction(_ sender: Any) {
        let pageViewController = HistoryPageViewController.dataSource as! HistoryPageViewController
        self.receivedLabel.textColor = .lightGray
        self.postedLabel.textColor = .black
        self.receivedView.isHidden = true
        self.postView.isHidden = false
        pageViewController.setControllerFirst()
    }
    
    @IBAction func receivedAction(_ sender: Any) {
        let pageViewController = HistoryPageViewController.dataSource as! HistoryPageViewController
        self.receivedLabel.textColor = .black
        self.postedLabel.textColor = .lightGray
        self.receivedView.isHidden = false
        self.postView.isHidden = true
        pageViewController.setControllerSecond()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
}
