
//
//  File.swift
//
//  Created by Manisha  Sharma on 02/01/2019.
//  Copyright © 2019 Qualwebs. All rights reserved.
//

import UIKit


class ActivityIndicator
{

    private init(){}
  
    static func show(view: UIView) {
        
        ANLoader.activityBackgroundColor = UIColor(named: "Overlay")!
   
        
        ANLoader.showLoading("Espere", disableUI: true)
       
    }
    
    static func hide() {
        ANLoader.hide()
       
    }
}
