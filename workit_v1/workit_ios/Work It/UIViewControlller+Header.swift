//
//  UIVI.swift
//  Work It
//
//  Created by Jorge Acosta on 06-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

extension UIViewController {
    
        func setNavigationBarForClose() {
            
            self.navigationItem.setHidesBackButton(true, animated:false)

            let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

            if let imgBackArrow = UIImage(named: "ic_cross_close") {
                imageView.image = imgBackArrow
            }
            view.addSubview(imageView)

            let backTap = UITapGestureRecognizer(target: self, action: #selector(closeToMain))
            view.addGestureRecognizer(backTap)

            let leftBarButtonItem = UIBarButtonItem(customView: view )
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
         
        }

        func setNavigationBar() {

           self.navigationItem.setHidesBackButton(true, animated:false)

           let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
           let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 12, height: 20))

           if let imgBackArrow = UIImage(named: "back_button") {
               imageView.image = imgBackArrow
           }
           view.addSubview(imageView)

           let backTap = UITapGestureRecognizer(target: self, action: #selector(backToMain))
           view.addGestureRecognizer(backTap)

           let leftBarButtonItem = UIBarButtonItem(customView: view )
           self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
       }

    @objc func closeToMain() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
       @objc func backToMain() {
           self.navigationController?.popViewController(animated: true)
       }
    
        func setTransparentHeader(){
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .red
        }
    
   
}
