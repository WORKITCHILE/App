//
//  String+Validation.swift
//  Work It
//
//  Created by Jorge Acosta on 07-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import Foundation
import UIKit


extension Int {
    func toFormatDate() -> String{
        let unixTimestamp = self / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return dateFormatter.string(from: date)
    }
}


extension String {
    
    func currencyInputFormatting() -> String {

            var number: NSNumber!
            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyAccounting
            formatter.currencySymbol = "$"
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
 

            var amountWithPrefix = self

          
            let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
            amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

            let double = (amountWithPrefix as NSString).doubleValue
            number = NSNumber(value: double)

          
            guard number != 0 as NSNumber else {
                return ""
            }

        return formatter.string(from: number)!.replacingOccurrences(of: ",", with: ".")
        }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    
    
    func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        return lowercased().starts(with: prefix.lowercased())
    }
    
    func toRutFormatter() -> String {
        
        if(self.count <= 1){
            return self
        }
        var filtered = self.asciiValues
            .filter { ($0 >= 47 && $0 <= 56 || $0 == 107) }
            .map { String(UnicodeScalar($0)) }
        
        let last = filtered.popLast()
        
        let joined = Int(filtered.joined(separator: ""))
        
        return  "\(joined!.formattedWithSeparator)-\(last ?? "")"
    }
    
    func translanteStatus() -> String {
  
        switch self {
            case "POSTED":
                return "Publicado"
            case "ACCEPTED":
                return "Aceptado"
            case "STARTED":
                return "Iniciado"
            case "CANCELED":
                return "Cancelado"
            case "CLOSED":
                return "Cancelado"
            case "PAID":
                return "Pagado"
            case "FINISHED":
                return "Finalizado"
            default:
                return self
        }
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func statusHightlightColor() -> UIColor {
        switch self {
            case "POSTED":
                return UIColor(named: "calendar_blue") ?? UIColor.black
            case "ACCEPTED":
                return UIColor(named: "calendar_blue") ?? UIColor.black
            case "STARTED":
                return UIColor(named: "calendar_blue") ?? UIColor.black
            case "CANCELED":
                return UIColor(named: "calendar_red") ?? UIColor.black
            case "CLOSED":
                return UIColor(named: "calendar_red") ?? UIColor.black
            case "PAID":
                return UIColor(named: "calendar_green") ?? UIColor.black
            case "FINISHED":
                return UIColor(named: "calendar_green") ?? UIColor.black
            default:
                return UIColor(named: "calendar_blue") ?? UIColor.black
        }
    }
    
    func statusColor()-> UIColor {
        switch self {
            case "POSTED":
                return UIColor(named: "light_blue") ?? UIColor.black
            case "ACCEPTED":
                return UIColor(named: "light_blue") ?? UIColor.black
            case "STARTED":
                return UIColor(named: "light_blue") ?? UIColor.black
            case "CANCELED":
                return UIColor(named: "calendar_border_red") ?? UIColor.black
            case "CLOSED":
                return UIColor(named: "calendar_border_red") ?? UIColor.black
            case "PAID":
                return UIColor(named: "calendar_border_green") ?? UIColor.black
            case "FINISHED":
                return UIColor(named: "calendar_border_green") ?? UIColor.black
            default:
                return UIColor(named: "light_blue") ?? UIColor.black
        }
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}
