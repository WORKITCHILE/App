
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
    @IBOutlet weak var postedLabel: UILabel!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var receivedView: UIView!
    @IBOutlet weak var receivedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountPageViewController.indexDelegate = self
        self.receivedLabel.textColor = .lightGray
        self.postedLabel.textColor = .black
        self.postedLabel.text = "Accounts"
        self.receivedLabel.text = "Credits"
    }
    
    func scrollAccountView(index: Int) {
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
        let pageViewController = AccountPageViewController.dataSource as! AccountPageViewController
        self.receivedLabel.textColor = .lightGray
        self.postedLabel.textColor = .black
        self.receivedView.isHidden = true
        self.postView.isHidden = false
        pageViewController.setControllerFirst()
    }
    
    @IBAction func receivedAction(_ sender: Any) {
        let pageViewController = AccountPageViewController.dataSource as! AccountPageViewController
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
