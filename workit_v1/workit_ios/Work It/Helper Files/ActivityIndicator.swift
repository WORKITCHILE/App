
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
    static var backgroundRounded = UIView()
    static var label = UILabel()
    static var imageView = UIImageView(image: UIImage(named: "engine"))
    
    static func show(view: UIView) {
        DispatchQueue.main.async {
            self.overlayView = view
            self.overlayView.isUserInteractionEnabled = false
            
            self.backgroundRounded = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
            self.backgroundRounded.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            self.backgroundRounded.layer.cornerRadius = 10
            self.backgroundRounded.center = view.center
            
            self.label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 33.0))
            self.label.text = "Espera"
            self.label.center = view.center
            self.label.frame = CGRect(x: self.label.frame.origin.x, y: self.label.frame.origin.y + 35.0, width: 100.0, height: 33.0)
            self.label.textColor = UIColor.white
            self.label.textAlignment = NSTextAlignment.center
            
            self.imageView.frame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 48.0)
            self.imageView.center = view.center
            
            self.turn180(self.imageView)
           
            view.addSubview(self.backgroundRounded)
            view.addSubview(self.imageView)
            view.addSubview(self.label)
        }
    }
    
    static func turn180(_ view : UIView){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            view.rotate(angle: 180)
        }, completion: { complete in
            self.turn360(view)
        })
    }
    
    static func turn360(_ view : UIView){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            view.rotate(angle: 359)
        }, completion: { complete in
            self.turn180(view)
        })
    }
    
    static func hide() {
        overlayView.isUserInteractionEnabled = true
        self.imageView.removeFromSuperview()
        self.backgroundRounded.removeFromSuperview()
        self.label.removeFromSuperview()
    }
}


extension UIView {

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }

}
