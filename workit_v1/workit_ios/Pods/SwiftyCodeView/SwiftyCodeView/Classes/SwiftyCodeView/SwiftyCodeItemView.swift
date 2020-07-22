//
//  SwiftyCodeItemView.swift
//
//  Created by arturdev on 6/28/18.
//

import UIKit

open class SwiftyCodeItemView: UIView {

    @IBOutlet open weak var textField: SwiftyCodeTextField!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        textField.text = ""
        //applyBorderedShadow()
        
        isUserInteractionEnabled = false
    }
    
    private func applyBorderedShadow() {
        layer.shadowOpacity = 0
       // layer.shadowColor = UIColor(red: 27/255.0, green: 30/255.0, blue: 230/255.0, alpha: 0).cgColor
       // layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0
        //layer.masksToBounds = false
        layer.cornerRadius = 4
    }
    
    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}
