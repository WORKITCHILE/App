//
//  Singleton.swift
//  Agile Sports
//
//  Created by AM on 21/06/19.
//  Copyright © 2019 AM. All rights reserved.
//

import Foundation
import UIKit
import Toaster

class Singleton {
    static let shared = Singleton()
    var userInfo = getUserInfo()
    var getCategories = [GetCategoryResponse]()
    var getStates = [GetStateResponse]()
    var jobData = [GetJobResponse]()
    var postedHistoryData = [GetJobResponse]()
    var receivedHistoryData = [GetJobResponse]()
    var vendorAcceptedBids = [GetJobResponse]()
    var vendorRejectedBids = [GetJobResponse]()
    var runningJobData = [GetJobResponse]()
   
    init() {
        CallAPIViewController.shared.getState { (val) in
            self.getStates = val
        }
    }
    
    public static func getUserInfo() -> UserInfo{
        guard let userData = UserDefaults.standard.data(forKey:UD_USERINFO) else{
            return UserInfo()
        }
        let user = try! JSONDecoder().decode(UserInfo.self, from: userData)
       // K_CURRENT_USER = userInfo.user_type_id!
        return user
    }
    
    public static func saveUserInfo(data: UserInfo){
        let userInfo = try! JSONEncoder().encode(data)
        UserDefaults.standard.setValue(userInfo, forKey: UD_USERINFO)
       }
       
    func initialiseValue() {
         userInfo = UserInfo()
         getCategories = [GetCategoryResponse]()
         jobData = [GetJobResponse]()
         postedHistoryData = [GetJobResponse]()
         receivedHistoryData = [GetJobResponse]()
         vendorAcceptedBids = [GetJobResponse]()
         vendorRejectedBids = [GetJobResponse]()
         runningJobData = [GetJobResponse]()
    }
    
    func showToast(text: String) {
    if (ToastCenter.default.currentToast?.text == text) {
         return
        }
        ToastView.appearance().textColor = .white
        ToastView.appearance().bottomOffsetPortrait = 70
        ToastView.appearance().backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.7)
        ToastView.appearance().font = UIFont.systemFont(ofSize: 17, weight: .medium)
        Toast(text: text, delay: 0, duration: 2).show()
        Toast(text: text, delay: 0, duration: 2).cancel()
    }
    
}

