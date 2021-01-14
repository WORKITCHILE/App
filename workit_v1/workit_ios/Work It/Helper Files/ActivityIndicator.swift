
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
            
           
            self.label.textColor = UIColor.white
            self.label.textAlignment = NSTextAlignment.center
            
           
            view.addSubview(self.backgroundRounded)
            
            self.backgroundRounded.addSubview(self.imageView)
            self.backgroundRounded.addSubview(self.label)
            
            self.label.frame = CGRect(x: 0.0, y: 67.0, width: 100.0, height: 33.0)
            self.imageView.frame = CGRect(x: 26.0, y: 16.0, width: 48.0, height: 48.0)
            
            self.turn180(self.imageView)
           
            
        }
    }
    
    static func turn180(_ view : UIImageView){
       
  
        UIView.animate(withDuration: 2.0, delay: 0.0, options:.curveLinear, animations: {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: { complete in
            self.turn360(view)
        })
    }
    
    static func turn360(_ view : UIImageView){
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        }, completion: { complete in
            self.turn180(view)
        })
    }
    
    static func hide() {
        
        self.overlayView.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.imageView.stopAnimating()
            self.backgroundRounded.removeFromSuperview()
            self.backgroundRounded = UIView()
            self.imageView = UIImageView(image: UIImage(named: "engine"))
        }

    }
}

