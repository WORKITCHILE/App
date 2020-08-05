
//
//  File.swift
//
//  Created by Manisha  Sharma on 02/01/2019.
//  Copyright © 2019 Qualwebs. All rights reserved.
//

import UIKit

class ActivityIndicator
{
    static var overlayView = UIView()
    static var imageView = UIImageView(image: UIImage(named: "engine"))
    
    static func show(view: UIView) {
        DispatchQueue.main.async {
            self.overlayView = view
            self.overlayView.isUserInteractionEnabled = false
            
            self.imageView.frame = CGRect(x: 0.0, y: 0.0, width: 64.0, height: 64.0)
            self.imageView.center = view.center
            
         
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
                self.imageView.rotate(angle: 180)
            }, completion: { complete in
                
            })
            
            view.addSubview(self.imageView)
        }
    }
    
    static func hide() {
        overlayView.isUserInteractionEnabled = true
        self.imageView.removeFromSuperview()
    }
}


extension UIView {

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }

}
