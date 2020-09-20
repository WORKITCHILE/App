//
//  String+Validation.swift
//  Work It
//
//  Created by Jorge Acosta on 07-08-20.
//  Copyright © 2020 qw. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}


extension String {
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
