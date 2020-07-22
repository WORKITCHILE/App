//
//  SuccessMsgViewController.swift
//  Work It
//
//  Created by qw on 05/03/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

protocol SuccessPopup {
    func yesAction()
}

class SuccessMsgViewController: UIViewController {
   //MARK: IBOutlets
    
    @IBOutlet weak var popupImage: UIImageView!
    @IBOutlet weak var popupMessage: DesignableUILabel!
    @IBOutlet weak var okButton: CustomButton!
    @IBOutlet weak var cancelButton: CustomButton!
    
    var image = UIImage()
    var titleLabel = String()
    var okBtnTtl : String?
    var cancelBtnTtl : String?
    var cancelBtnHidden = true
    var successDelegate: SuccessPopup?  = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupImage.image = image
        self.popupMessage.text = self.titleLabel
        self.cancelButton.isHidden = cancelBtnHidden
        self.okButton.setTitle(okBtnTtl ?? "Ok", for: .normal)
        self.cancelButton.setTitle(cancelBtnTtl ?? "No", for: .normal)
    }
    
    //MARK: IBActions
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        if(okButton.titleLabel?.text == "Yes" || okButton.titleLabel?.text == "Repost"){
            self.successDelegate?.yesAction()
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
