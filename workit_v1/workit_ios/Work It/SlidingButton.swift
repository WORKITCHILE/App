

import Foundation

import Foundation
import UIKit

protocol SlideButtonDelegate{
    func buttonStatus(status:String, sender:MMSlidingButton)
}

@IBDesignable class MMSlidingButton: UIView{
    
    var delegate: SlideButtonDelegate?
    
    @IBInspectable var dragPointWidth: CGFloat = 35 {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var dragPointColor: UIColor = UIColor.darkGray {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.gray {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonText: String = "Start Job" {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var imageName: UIImage = UIImage() {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonTextColor: UIColor = UIColor.white {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var dragPointTextColor: UIColor = UIColor.white {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonUnlockedTextColor: UIColor = UIColor.white {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonCornerRadius: CGFloat = 30 {
        didSet{
            setStyle()
        }
    }
    
    @IBInspectable var buttonUnlockedText: String   = "UNLOCKED"
    @IBInspectable var buttonUnlockedColor: UIColor = UIColor.black
    var buttonFont                                  = UIFont.boldSystemFont(ofSize: 17)
    
    
    var dragPoint            = UIView()
    var buttonLabel          = UILabel()
    var dragPointButtonLabel = UILabel()
    var imageView            = UIImageView()
    var unlocked             = false
    var layoutSet            = false
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    override func layoutSubviews() {
        if !layoutSet{
            self.setUpButton()
            self.layoutSet = true
        }
    }
    
    func setStyle(){
        self.buttonLabel.text               = self.buttonText
        self.dragPointButtonLabel.text      = self.buttonText
        self.dragPoint.frame.size.width     = 46//self.dragPointWidth
        self.dragPoint.backgroundColor      = self.dragPointColor
        self.backgroundColor                = self.buttonColor
        self.imageView.image                = imageName
        self.buttonLabel.textColor          = self.buttonTextColor
        self.dragPointButtonLabel.textColor = self.dragPointTextColor
        
        self.dragPoint.layer.cornerRadius   = buttonCornerRadius
        self.layer.cornerRadius             = buttonCornerRadius
    }
    
    func setUpButton(){
        
        self.backgroundColor              = darkBlue//self.buttonColor
        
        self.dragPoint    = UIView(frame: CGRect(x: 2, y:2 , width: 46 , height: 46))
        
        self.dragPoint.backgroundColor  = .white
        
        //dragPointColor
        self.dragPoint.layer.cornerRadius = 46/2
        self.dragPoint.clipsToBounds = true
        //buttonCornerRadius
        self.addSubview(self.dragPoint)
        
        if !self.buttonText.isEmpty{

            self.buttonLabel               = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            self.buttonLabel.textAlignment = .center
            self.buttonLabel.text          = buttonText
            self.buttonLabel.textColor     = UIColor.white
            self.buttonLabel.font          = self.buttonFont
            self.buttonLabel.textColor     = self.buttonTextColor
            self.addSubview(self.buttonLabel)

            self.dragPointButtonLabel               = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            self.dragPointButtonLabel.textAlignment = .center
            self.dragPointButtonLabel.text          = buttonText
            self.dragPointButtonLabel.textColor     = UIColor.white
            self.dragPointButtonLabel.font          = self.buttonFont
            self.dragPointButtonLabel.textColor     = self.dragPointTextColor
            self.dragPoint.addSubview(self.dragPointButtonLabel)
        }
        self.bringSubviewToFront(self.dragPoint)
        
        if self.imageName != UIImage(){
            self.imageView.frame.size = CGSize(width: 22, height: 22)
            self.imageView.center.y = 23
            self.imageView.center.x = 23
            
                //UIImageView(frame: CGRect(x: self.dragPoint.center.x, y: self.dragPoint.center.y, width: 20, height: 20))
            self.imageView.contentMode = .scaleToFill
            self.imageView.image = self.imageName
            self.imageView.clipsToBounds = true
            self.dragPoint.addSubview(self.imageView)
        }
        
       // self.layer.masksToBounds = true
        
        // start detecting pan gesture
        let panGestureRecognizer                    = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(sender:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        self.dragPoint.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panDetected(sender: UIPanGestureRecognizer){
        var translatedPoint = sender.translation(in: self)
       // translatedPoint     = CGPoint(x: translatedPoint.x, y: self.frame.size.height / 2)
        if(translatedPoint.x < (self.frame.width - 46)){
            if(translatedPoint.x > 0){
                self.dragPoint.frame.origin.x =  translatedPoint.x
            }else {
                return
            }
        }
        self.buttonLabel.alpha = self.buttonLabel.alpha - 0.01
        if sender.state == .ended{
            let velocityX = sender.velocity(in: self).x * 0.2
            var finalX    = translatedPoint.x + velocityX
            
            if finalX < 0{
                finalX = 0
                self.buttonLabel.alpha = 1
            }else if finalX + self.dragPointWidth  >  (self.frame.size.width - 46){
                unlocked = true
                self.unlock()
            }
            
            let animationDuration:Double = abs(Double(velocityX) * 0.0002) + 0.2
            UIView.transition(with: self, duration: animationDuration, options: UIView.AnimationOptions.curveEaseOut, animations: {
                }, completion: { (Status) in
                    if Status{
                        self.animationFinished()
                    }
            })
        }
    }
    
    func animationFinished(){
        if !unlocked{
            self.reset()
        }
    }
    
    //lock button animation (SUCCESS)
    func unlock(){
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame = CGRect(x: self.frame.size.width - self.dragPoint.frame.size.width, y: 2, width: self.dragPoint.frame.size.width, height: self.dragPoint.frame.size.height)
        }) { (Status) in
            if Status{
                self.dragPointButtonLabel.text      = self.buttonUnlockedText
                self.imageView.isHidden               = true
                self.dragPoint.backgroundColor      = self.buttonUnlockedColor
                self.dragPointButtonLabel.textColor = self.buttonUnlockedTextColor
                self.buttonLabel.alpha = 0
                self.delegate?.buttonStatus(status: "Unlocked", sender: self)
            }else {
                self.buttonLabel.alpha = 1
            }
        }
    }
    
    //reset button animation (RESET)
    func reset(){
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame =  CGRect(x: 2, y:2 , width: 46 , height: 46)
            self.buttonLabel.alpha = 1
        }) { (Status) in
            if Status{
                self.dragPointButtonLabel.text      = self.buttonText
                self.buttonLabel.alpha = 1
                self.imageView.isHidden               = false
                self.dragPoint.backgroundColor      =  lightBlue
                self.dragPointButtonLabel.textColor = self.dragPointTextColor
                self.unlocked                       = false
                //self.delegate?.buttonStatus("Locked")
            }
        }
    }
}
