//
//  NSAttributedString+size.swift
//  Work It
//
//  Created by Jorge Acosta on 09-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    func height(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(_ height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.width)
    }
}
