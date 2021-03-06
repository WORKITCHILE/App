//
//  APIManager.swift
//
//  Created by Manisha  Sharma on 02/01/2019.
//  Copyright © 2019 Qualwebs. All rights reserved.
//

import UIKit
import Alamofire

class SessionManager: NSObject {

    static var shared = SessionManager()

    var createWallet: Bool = true

    func methodForApiCalling<T: Codable>(url: String, method: HTTPMethod, parameter: Parameters?, objectClass: T.Type, requestCode: String,completionHandler: @escaping (T) -> Void) {
        print("URL: \(url)")
        print("METHOD: \(method)")
        print("PARAMETERS: \(parameter)")
        print("TOKEN: \(getHeader(reqCode: requestCode))")

        Alamofire.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: getHeader(reqCode: requestCode)).responseString { (dataResponse) in

            let statusCode = dataResponse.response?.statusCode
            print("statusCode: ",dataResponse.response?.statusCode)
            print("dataResponse: \(dataResponse)")

            switch dataResponse.result {
            case .success(_):
                let object = self.convertDataToObject(response: dataResponse.data, T.self)
                let errorObject = self.convertDataToObject(response: dataResponse.data, Response.self)
               
                
                if (statusCode == 200 || statusCode == 201) && object != nil
                    //                    && (requestCode != U_VALIDATE_USER)
                {
                    completionHandler(object!)
                    
                }else if(statusCode == 401 && requestCode == U_CHANGE_USER_ROLE){
                    
                    NotificationCenter.default.post(name: NSNotification.Name(N_USER_UNAUTHORIZED), object: nil)
                } else if statusCode == 404  {
                    
                    self.showAlert(msg:errorObject?.message)

                    //                    if (UserDefaults.standard.string(forKey: K_TOKEN) == nil) &&
                    //                        if requestCode == U_VALIDATE_USER {
                    //                        completionHandler(object!)
                    //                    } else {
                    //                        //Showing error message on alert
                    //                        //                        UIApplication.shared.keyWindow?.rootViewController?.showAlert(message: message!, title: "Error", isPopBack: false)
                    //                    }
                    //                    self.webServiceDelegate?.dataNotFound!(msg: message)
                }else if(statusCode == 400) {
                    
                    self.showAlert(msg: errorObject?.message)
                }
                ActivityIndicator.hide()
                break
            case .failure(_):
                ActivityIndicator.hide()
                let error = dataResponse.error?.localizedDescription
                if error == "The Internet connection appears to be offline." {
                    //Showing error message on alert
                    self.showAlert(msg: error)
                } else {
                    //Showing error message on alert
                    self.showAlert(msg: error)
                }
                break
            }
        }
    }

    private func showAlert(msg: String?) {
        UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "Error", message: msg, action1Name: "Ok", action2Name: nil)

    }

        func makeMultipartRequest(url: String, fileData: Data, param: [String:Any], fileName: String, completionHandler: @escaping (Any) -> Void) {

            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in param {
                    if key != "file_path" {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    } else {
                        multipartFormData.append(value as! Data, withName: key as! String, fileName: "image.png", mimeType: "image/png")
                    }
                }

            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: getHeader(reqCode: U_IMAGE_UPLOAD)) { (encodingResult) in

                switch encodingResult {
                case .success(let response,_,_):
                    response.responseString(completionHandler: { (dataResponse) in

                        let errorObject = self.convertDataToObject(response: dataResponse.data, Response.self)

                        if dataResponse.response?.statusCode == 200 {
                            let object = self.convertDataToObject(response: dataResponse.data, Response.self)
                          //  completionHandler(object?.response)
                        } else {
                            UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "Error", message: errorObject?.message, action1Name: "Ok", action2Name: nil)
                        }
                    })
                    break
                case .failure(let error):
                    //Showing error message on alert
    UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "Error", message: error.localizedDescription, action1Name: "Ok", action2Name: nil)
                    break
                }
            }
        }

    private func convertDataToObject<T: Codable>(response inData: Data?, _ object: T.Type) -> T? {
        if let data = inData {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                print(error)
            }
        }
        return nil
    }

    func getHeader(reqCode: String) -> HTTPHeaders? {
        var token = UserDefaults.standard.string(forKey: UD_TOKEN)
        if (reqCode != U_LOGIN){
            if(token == nil){
                return nil
            }else {
                return ["Authorization": "Bearer " + token!]
            }
        } else {
            return nil
        }
    }
}

