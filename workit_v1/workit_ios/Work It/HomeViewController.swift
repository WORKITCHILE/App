//
//  HomeViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 10-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var button_client: UIButton!
    @IBOutlet weak var button_worker: UIButton!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var clientView : UIView!
    @IBOutlet weak var workerView : UIView!
    @IBOutlet weak var labelClient : UILabel!
    @IBOutlet weak var labelWorker : UILabel!
    @IBOutlet weak var circleHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var whiteViewContraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let userInfo = Singleton.shared.userInfo
        self.nameLabel.text = "Hola \(userInfo.name ?? "")"
        button_client.layer.cornerRadius = 32
        button_client.layer.shadowColor = UIColor.black.cgColor
        button_client.layer.shadowOpacity = 0.4
        button_client.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button_client.layer.shadowRadius = 20.0
        
        button_worker.layer.cornerRadius = 32
        button_worker.layer.shadowColor = UIColor.black.cgColor
        button_worker.layer.shadowOpacity = 0.4
        button_worker.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button_worker.layer.shadowRadius = 20.0
    
    
        
        self.workerView.isHidden = true
        
        styleSelectButtonClient(button: self.button_client, label: self.labelClient, icon:"person_outline")
        styleUnselectButtonClient(button: self.button_worker, label: self.labelWorker, icon: "worker_outline")
        
        
        
        if(self.view.frame.size.height == 667.0 || self.view.frame.size.height == 736.0){
            self.circleHeaderTop.constant = -50.0
            self.whiteViewContraint.constant = 197.0
            self.topHeight.constant = 30
        } 
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }
    
    private func styleSelectButtonClient(button : UIButton, label: UILabel, icon: String){
        let selected_blue = UIColor(named: "selected_blue")
        button.backgroundColor = selected_blue
        let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        label.textColor = selected_blue
    }
    
    private func styleUnselectButtonClient(button : UIButton, label: UILabel, icon: String){
        let border = UIColor(named: "border")
        button.backgroundColor = .white
        let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = border
        label.textColor = border
    }
    
    
    @IBAction func switchModeWorker(_ sender : AnyObject){
        self.clientView.isHidden = true
        self.workerView.isHidden = false

        styleSelectButtonClient(button: self.button_worker, label: self.labelWorker, icon: "worker_outline")
        styleUnselectButtonClient(button: self.button_client, label: self.labelClient, icon: "person_outline")
    }
    
    @IBAction func switchModeClient(_ sender : AnyObject){
        self.clientView.isHidden = false
        self.workerView.isHidden = true
        
        styleSelectButtonClient(button: self.button_client, label: self.labelClient, icon: "person_outline")
        styleUnselectButtonClient(button: self.button_worker, label: self.labelWorker, icon: "worker_outline")
    }


}
