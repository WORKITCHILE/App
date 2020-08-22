//
//  MainTabViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 09-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {
    
    var menuButton :UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiddleButton()
        selectedIndex = 2
    }

    // MARK: - Setups
    func setupMiddleButton() {
       
        
        self.menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        self.menuButton.layer.shadowColor = UIColor.black.cgColor
        self.menuButton.layer.shadowOpacity = 0.4
        self.menuButton.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        self.menuButton.layer.shadowRadius = 20.0
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - 10 - bottomPadding!
        } else {
            menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - 10
        }
        
        self.menuButton.frame = menuButtonFrame

        self.menuButton.backgroundColor = UIColor(named: "workit_green")
        self.menuButton.layer.cornerRadius = menuButtonFrame.height/2
        view.addSubview(self.menuButton)

        self.menuButton.setImage(UIImage(named: "main_tab_button"), for: .normal)
        self.menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)

        view.layoutIfNeeded()
    }


    // MARK: - Actions

    @objc private func menuButtonAction(sender: UIButton) {
        selectedIndex = 2
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       
    }

}
