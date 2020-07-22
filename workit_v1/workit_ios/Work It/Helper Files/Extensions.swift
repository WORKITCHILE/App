//
//  Extemsions.swift
//
//  Created by Manisha  Sharma on 02/01/2019.
//  Copyright © 2019 Qualwebs. All rights reserved.
//

import UIKit
import SideMenu
import CoreLocation
import FirebaseStorage


extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

extension UIViewController {
    
    func showAlert(title: String?, message: String?, action1Name: String?, action2Name: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: action1Name, style: .default, handler: nil))
        if action2Name != nil {
            alertController.addAction(UIAlertAction(title: action2Name, style: .default, handler: nil))
        }
        DispatchQueue.main.async {
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func uplaodUserImage(imageName: String,image: Data, type: Int,completionHandler: @escaping (String) -> Void) {
        ActivityIndicator.show(view: self.view)
        var storeImg = StorageReference()
        let lastPathComponent = "\(Int(Date().timeIntervalSince1970))"
        if(type == 1){
            storeImg = storageRef.child("id_images/").child(lastPathComponent)
        }else if(type == 2){
             storeImg = storageRef.child("profile_images/").child(lastPathComponent)
        }else if(type == 3){
             storeImg = storageRef.child("job_images/").child(lastPathComponent)
        }
        storeImg.putData(image, metadata:StorageMetadata(dictionary: ["contentType": "image/png"])) { (snapshot, error) in
            // When the image has successfully uploaded, we get it's download URL
             storeImg.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                completionHandler(downloadURL.absoluteString)
                ActivityIndicator.hide()
            })
        }
    }
    
    
    func calculateAge(timeStamp: Int) -> String {
        let calendar = Calendar.current
        let myVal = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let ageComponents = calendar.dateComponents([.year, .month, .day], from:
        myVal, to: Date())
        if(ageComponents.year == 0){
            return "\(ageComponents.month ?? 0) months"
        }
        return "\(ageComponents.year ?? 0) years"
    }
    
    
    
    @objc func back() {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func calculateTimeDifference(date1: Int, date2: Int) -> Int{
        let d1 = Date(timeIntervalSince1970: TimeInterval(date1))
        let d2 = Date(timeIntervalSince1970: TimeInterval(date2))
        let diff = Int(d2.timeIntervalSince1970 - d1.timeIntervalSince1970)
        return diff
    }
    
    func convertTimestampToDate(_ timestamp: Int, to format: String) -> String {
        var myVal = Int()
        var intValue:Int64 = 10000000000
        if(timestamp/Int(truncatingIfNeeded: intValue) == 0){
            myVal = timestamp
        }else {
            myVal = timestamp/1000
        }
        let date = Date(timeIntervalSince1970: TimeInterval(myVal))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func convertDateToTimestamp(_ date: String, to format: String) -> Int{
           let dfmatter = DateFormatter()
           dfmatter.dateFormat = format
            dfmatter.timeZone = TimeZone(abbreviation: "GMT-5")
           let date = dfmatter.date(from: date)
           var dateStamp:TimeInterval?
           if let myDate = date {
               dateStamp = myDate.timeIntervalSince1970
               let dateSt:Int = Int(dateStamp!)
               return dateSt
           }else {
               return Int(Date().timeIntervalSince1970)
           }
       }
    
    func openSuccessPopup(img: UIImage, msg: String, yesTitle: String?, noTitle: String?, isNoHidden : Bool?){
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessMsgViewController") as! SuccessMsgViewController
        myVC.image = img
        myVC.titleLabel = msg
        myVC.okBtnTtl = yesTitle
        myVC.cancelBtnTtl = noTitle
        myVC.cancelBtnHidden = isNoHidden ?? true
        myVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(myVC, animated: true, completion: nil)
    }
    
    func menu() {
        SideMenuManager.default.menuFadeStatusBar = false
        guard let sideMenuNavController =  SideMenuManager.defaultManager.menuLeftNavigationController else {
            let sideMenuController = storyboard?.instantiateViewController(withIdentifier: "SideDrawerViewController") as! SideDrawerViewController
            SideMenuManager.defaultManager.menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuController)
            SideMenuManager.defaultManager.menuWidth = UIScreen.main.bounds.width * 0.75
                SideMenuManager.defaultManager.menuLeftNavigationController?.setNavigationBarHidden(true, animated: false)
            present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
            return
        }
        present(sideMenuNavController, animated: true, completion: nil)
    }

    
    func openUrl(urlStr: String) {
        let url = URL(string: urlStr)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func changeColor(string:String,colorString: String,color: UIColor,field:UILabel){
        let main_string = string
        var string_to_color = colorString
        //colorString.font
        var range = (main_string as NSString).range(of: string_to_color)
        
        let attribute = NSMutableAttributedString.init(string: main_string)
        if let font = UIFont(name: "Raleway-SemiBold", size: 20) {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (string_to_color as NSString).size(withAttributes: fontAttributes)
        }
    attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
        field.attributedText = attribute
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                hasPermission = false
            case .authorizedAlways, .authorizedWhenInUse:
                hasPermission = true
            }
        } else {
            hasPermission = false
        }

        return hasPermission
    }
    
    func callNumber(phoneNumber:String) {

        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        }
    }
}

extension UIView {
    func setCircularShadow() {
        self.layer.shadowColor = UIColor(red: 111/255, green: 113/255, blue: 121/255, alpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func addConstraintsWithFormatString(formate: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: formate, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func setShadow(cornerRadius: CGFloat)
    {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 1
    }

}

extension UILabel {
    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }
        
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil).size
        
        return labelTextSize.height > bounds.size.height
    }
}

extension UIImageView {
    func changeTint(color: UIColor) {
        let templateImage =  self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}


extension String {
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    func formatName(name: String) -> String{
        let nameFormatter = PersonNameComponentsFormatter()
        if let nameComps  = nameFormatter.personNameComponents(from: name), let firstLetter = nameComps.givenName, let lastName = nameComps.familyName?.first {
            return "\(firstLetter) \(lastName)."
    }
        return name
   }
        
}



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}



class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: text)
            self.attributedText = NSAttributedString(string: text, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])

            attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
            
//            self.attributedText = NSAttributedString(string: text, attributes:
//                [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
}

extension UITextView {
    func adjustUITextViewHeight(arg : UITextView){
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
}


final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

extension UIViewController {
    
     func getCountryPhonceCode (_ country : String) -> String
    {
        var countryDictionary  = [
                                  "AF":"93",
                                  "CA":"1",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        let key = countryDictionary[country]
        if(key != "" || key != nil){
            return key ?? ""
        }else {
            return ""
        }
            //countryDictionary.allKeysForValue(val:country)
//        var currentCountry = [String]()
//        if(keys.count > 1){
//          currentCountry = keys.filter{$0 == Locale.current.regionCode!}
//        }else {
//           currentCountry = keys
//        }
//        if(currentCountry != []){
//            var myCurrencyCode = Locale.myCurrency[currentCountry[0]]
//            print(myCurrencyCode?.code)
//            return myCurrencyCode!.code!
//        }else {
//            return ""
//        }
    }
    
    
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

extension Locale {
    static let myCurrency: [String: (code: String?, symbol: String?)] = Locale.isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol)
    }
}


extension UIDevice {
    enum DeviceType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown = "iPadOrUnknown"
    }

    var deviceType: DeviceType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
