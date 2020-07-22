////
////  Router.swift
////  Diamonium
////
////  Created by Manisha  Sharma on 04/01/2019.
////  Copyright © 2019 Qualwebs. All rights reserved.
////
//
//import UIKit
//import Foundation
//
//class Router {
//    
//    static func launchSplash() {
//        let splachScreen = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
//        getRootViewController().pushViewController(splachScreen, animated: false)
//    }
//    
//    static func tutorVC() {
//        let tutorController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        getRootViewController().pushViewController(tutorController, animated: false)
//    }
//    
//    static func tuteeVC() {
//        let tuteeController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
//        getRootViewController().pushViewController(tuteeController, animated: false)
//    }
//    
//    static func getRootViewController() -> UINavigationController {
//        let navController = UINavigationController()
//        self.getWindow()?.rootViewController = navController
//        return navController
//    }
//    
//    static private func getWindow() -> UIWindow? {
//        var window: UIWindow? = nil
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            window = appDelegate.window
//        }
//        return window
//    }
//}
