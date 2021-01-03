//
//  UIView+Shadow.swift
//  Work It
//
//  Created by Jorge Acosta on 07-11-20.
//  Copyright © 2020 qw. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    func defaultShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 6.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.masksToBounds = false
    }
}
