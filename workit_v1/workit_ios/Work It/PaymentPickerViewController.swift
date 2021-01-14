//
//  PaymentPickerViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 03-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import UIKit
import Lottie

protocol PaymentPickerViewDelete {
    func aceptPayment()
}

class PaymentPickerViewController: UIViewController {

    @IBOutlet weak var card : View!
    @IBOutlet weak var animation: AnimationView?
    
    var delegate : PaymentPickerViewDelete?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = Animation.named("payment_1")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        card.defaultShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
    
    @IBAction func close(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectPayment(_ sender: AnyObject){
        
        self.dismiss(animated: true) {
            if(self.delegate != nil){
                self.delegate?.aceptPayment()
            }
        }
    }

}
