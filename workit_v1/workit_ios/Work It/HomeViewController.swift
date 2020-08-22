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
    @IBOutlet weak var clientView : UIView!
    @IBOutlet weak var workerView : UIView!
    @IBOutlet weak var labelClient : UILabel!
    @IBOutlet weak var labelWorker : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        button_client.layer.cornerRadius = 32
        //button_client.layer.masksToBounds = true
        button_client.layer.shadowColor = UIColor.black.cgColor
        button_client.layer.shadowOpacity = 0.4
        button_client.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button_client.layer.shadowRadius = 20.0
        
        button_worker.layer.cornerRadius = 32
        //button_worker.layer.masksToBounds = true
        button_worker.layer.shadowColor = UIColor.black.cgColor
        button_worker.layer.shadowOpacity = 0.4
        button_worker.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button_worker.layer.shadowRadius = 20.0
        
        self.workerView.isHidden = true
        
        styleSelectButtonClient()
        styleUnselectButtonWorker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentHeader()
    }
    
    private func styleSelectButtonClient(){
        let selected_blue = UIColor(named: "selected_blue")
        self.button_client.backgroundColor = selected_blue
        let image = UIImage(named: "person_outline")?.withRenderingMode(.alwaysTemplate)
        self.button_client.setImage(image, for: .normal)
        self.button_client.tintColor = .white
        self.labelClient.textColor = selected_blue
    }
    
    private func styleUnselectButtonClient(){
        let border = UIColor(named: "border")
        self.button_client.backgroundColor = .white
        let image = UIImage(named: "person_outline")?.withRenderingMode(.alwaysTemplate)
        self.button_client.setImage(image, for: .normal)
        self.button_client.tintColor = border
        self.labelClient.textColor = border
    }
    
    private func styleSelectButtonWorker(){
        let intense_blue = UIColor(named: "intense_blue")
        self.button_worker.backgroundColor = intense_blue
        let image = UIImage(named: "worker_outline")?.withRenderingMode(.alwaysTemplate)
        self.button_worker.setImage(image, for: .normal)
        self.button_worker.tintColor = .white
        self.labelWorker.textColor = intense_blue
    }
    
    private func styleUnselectButtonWorker(){
        let border = UIColor(named: "border")
        self.button_worker.backgroundColor = .white
        let image = UIImage(named: "worker_outline")?.withRenderingMode(.alwaysTemplate)
        self.button_worker.setImage(image, for: .normal)
        self.button_worker.tintColor = border
        self.labelWorker.textColor = border
    }
    
    @IBAction func switchModeWorker(_ sender : AnyObject){
        self.clientView.isHidden = true
        self.workerView.isHidden = false

        styleSelectButtonWorker()
        styleUnselectButtonClient()
    }
    
    @IBAction func switchModeClient(_ sender : AnyObject){
        self.clientView.isHidden = false
        self.workerView.isHidden = true
        
        styleSelectButtonClient()
        styleUnselectButtonWorker()
    }


}
