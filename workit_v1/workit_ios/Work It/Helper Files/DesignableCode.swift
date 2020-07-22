

import UIKit

@IBDesignable
class CustomButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var fontSize: Int {
        get {
            return fontSize
        } set {
            self.titleLabel?.font = changeFont(val: newValue)
            
        }
    }
    
    
    @IBInspectable var circle: Bool {
        get {
            return circle
        } set {
            if newValue {
                self.layer.cornerRadius = self.frame.width/2
                self.clipsToBounds = true
            }
        }
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return shadow
        } set {
            if newValue {
                layer.shadowOpacity = 1
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOffset = CGSize(width: 0, height: 0.5)
                layer.shadowRadius = 2
                layer.masksToBounds = false
                //layer.cornerRadius = 4
            }
        }
    }
    
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return cornerRadius
        } set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
}

@IBDesignable
class View: UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return borderWidth
        } set {
            self.layer.borderWidth = newValue
            self.layer.masksToBounds = false
        }
    }
    
    @IBInspectable var topCorner: CGFloat {
        get {
            return cornerRadius
        } set {
            
            self.roundCorners([.topLeft, .topRight], radius: newValue)
            //self.clipsToBounds = true
            //self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var bottomCorner: CGFloat {
        get {
            return cornerRadius
        } set {
            
            self.roundCorners([.bottomLeft, .bottomRight], radius: newValue)
            //self.clipsToBounds = true
            //self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return cornerRadius
        } set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
            self.layer.masksToBounds = false
        }
    }
    
    @IBInspectable var circle: Bool {
        get {
            return circle
        } set {
            if newValue {
                self.layer.cornerRadius = self.frame.width/2
                self.clipsToBounds = true
                self.layer.masksToBounds = false
            }
        }
    }

     @IBInspectable var shadow: Bool {
           get {
               return shadow
           } set {
               if newValue {
                   layer.shadowOpacity = 1
                   layer.shadowColor = shadowColor.cgColor
                   layer.shadowOffset = CGSize(width: 0, height: 0)
                   layer.shadowRadius = 2
                   layer.masksToBounds = false
                   //layer.cornerRadius = 4
               }
           }
       }
    
//    @IBInspectable var shadowOffset: CGFloat {
//              get {
//                  return shadowOffset
//              }set {
//                  layer.shadowOffset = CGSize(width: 0, height: 0)
//                  layer.shadowRadius = 0
//                  self.layer.masksToBounds = false
//              }
//          }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }


}

@IBDesignable
class ImageView: UIImageView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
   
    @IBInspectable var shadow: Bool {
           get {
               return shadow
           } set {
               if newValue {
                   layer.shadowOpacity = 1
                   layer.shadowColor = shadowColor.cgColor
                   layer.shadowOffset = CGSize(width: 0, height: 0.5)
                   layer.shadowRadius = 2
                   layer.masksToBounds = false
                   //layer.cornerRadius = 4
               }
           }
       }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return cornerRadius
        } set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var circle: Bool {
        get {
            return circle
        } set {
            if newValue {
                self.layer.cornerRadius = self.frame.height/2
                self.clipsToBounds = true
                self.layer.masksToBounds = true
                self.contentMode = .scaleAspectFill
            }
        }
    }
    
    @IBInspectable var customTintColor: UIColor {
        get {
            return customTintColor
        } set {
            let templateImage =  self.image?.withRenderingMode(.alwaysTemplate)
            self.image = templateImage
            self.tintColor = newValue
        }
    }
}

@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 0
    @IBInspectable var placeholderTextColor: UIColor? = .lightGray
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var fontSize: Int {
        get {
            return fontSize
        } set {
            self.font = changeFont(val: newValue)
            
        }
    }
    
    @IBInspectable var placeHolderText: String {
        get {
            return placeHolderText
        } set {
            self.attributedPlaceholder = NSAttributedString(string: newValue, attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor])
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }
        
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadow: Bool {
           get {
               return shadow
           } set {
               if newValue {
                   layer.shadowOpacity = 1
                   layer.shadowColor = shadowColor.cgColor
                   layer.shadowOffset = CGSize(width: 0, height: 0.5)
                   layer.shadowRadius = 2
                   layer.masksToBounds = false
                   //layer.cornerRadius = 4
               }
           }
       }
    
    
    @IBInspectable var color: UIColor = lightBlue {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            rightView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
    }
}


@IBDesignable
class DesignableUILabel: UILabel {
    
    // Provides left padding for images
    
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 0
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return cornerRadius
        } set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var fontSize: Int {
        get {
            return fontSize
        } set {
            self.font = changeFont(val: newValue)
            
        }
    }
    
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        } set {
            self.layer.shadowOpacity = newValue
        }
    }
    
}





func changeFont(val: Int) -> UIFont {
    
    switch val {
    //For Main heading
    case 1:
        return   UIFont(name: "RobotoMono-Bold", size: 35)!   //UIFont.boldSystemFont(ofSize: 36)
    //FOR Main Title
    case 2:
        return UIFont(name: "RobotoMono-Bold", size: 22)!
    //FOR Main Sub-heading
    case 3:
        return UIFont(name: "RobotoMono-Medium", size: 19)!
    //FOR Body heading
    case 4:
        return UIFont(name: "verdana", size: 17)!
    //FOR small heading
    case 5:
        return UIFont(name: "verdana", size: 14)!
    case 6:
        return UIFont(name: "verdana", size: 13)!
    case 8:
       return UIFont(name: "verdana", size: 19)!
    //FOR extra small heading
    default:
        return UIFont(name: "verdana", size: 17)!
    }
    
}
