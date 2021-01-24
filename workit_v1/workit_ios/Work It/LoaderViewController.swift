//
//  LoaderViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 18-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import UIKit

class LoaderViewController: UIViewController {

    @IBOutlet weak var engine : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.turn180(self.engine)
    }
    
     func turn180(_ view : UIImageView){
       
  
        UIView.animate(withDuration: 2.0, delay: 0.0, options:.curveLinear, animations: {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: { complete in
            self.turn360(view)
        })
    }
    
    func turn360(_ view : UIImageView){
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        }, completion: { complete in
            self.turn180(view)
        })
    }

}
