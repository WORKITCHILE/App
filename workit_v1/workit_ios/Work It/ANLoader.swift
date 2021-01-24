//
//  ANLoader.swift
//  Pods
//
//  Created by Anand on 17/08/17.
//  Copyright (c) 2017 anscoder. All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
import UIKit
import QuartzCore

public struct ANLoader {
    
    //MARK: - Change the variables values here for Custom uses
    public static var showFadeOutAnimation = false
    public static var pulseAnimation = true
    public static var activityColor: UIColor = UIColor.white
    public static var activityBackgroundColor: UIColor = UIColor.darkGray
    public static var activityTextColor: UIColor = UIColor.white
    public static var activityTextFontName: UIFont = UIFont.systemFont(ofSize: 23)
    fileprivate static var activityWidth = (UIScreen.screenWidth / widthDivision) / 2
    fileprivate static var activityHeight = activityWidth
    public static var widthDivision: CGFloat {
        get {
            guard UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad else {
                return 1.6
            }
            return 3.5
        }
    }
    public static var viewBackgroundDark: Bool = false
    public static var loadOverApplicationWindow: Bool = false
    
    
    //MARK: - Loading View
    public static var instance: LoadingResource?
    public static var backgroundView: UIView!
    fileprivate static var hidingInProgress = false
    
    
    public static func showLoading(_ text: String, disableUI: Bool) {
        ANLoader().startLoadingActivity(text, with: disableUI)
    }
    
    public static func showLoading() {
        ANLoader().startLoadingActivity("", with: false)
    }
    
    public static func hide(){
        DispatchQueue.main.async {
            instance?.hideActivity()
        }
    }
    
    //MARK: - Main Loading View creating here
    public class LoadingResource: UIView {
        fileprivate var textLabel: UILabel!
        fileprivate var activityView: UIImageView!
        fileprivate var disableUIIntraction = false
        
        convenience init(text: String, disableUI: Bool) {
            self.init(frame: CGRect(x: 0,
                                    y: 0,
                                    width: activityWidth,
                                    height: activityHeight))
            center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            autoresizingMask = [.flexibleTopMargin,
                                .flexibleLeftMargin,
                                .flexibleBottomMargin,
                                .flexibleRightMargin]
            backgroundColor = activityBackgroundColor
            alpha = 1
            layer.cornerRadius = 10
            
            let yPosition = frame.height/2 - 30
            
            addActivityView(yPosition)
            
            addTextLabel(yPosition + activityView.frame.size.height, text: text)
            
            checkActivityBackgroundColor()
            
            guard disableUI else {
                return
            }
            UIApplication.shared.beginIgnoringInteractionEvents()
            disableUIIntraction = true
        }
        
        private func checkActivityBackgroundColor(){
            guard activityBackgroundColor != .clear else {
                return
            }
           
        
            addPulseAnimation()
        }
        
        //MARK: - Pulse Animation adding here
        fileprivate func addPulseAnimation(){
            guard pulseAnimation else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
                pulseAnimation.duration = 0.4
                pulseAnimation.fromValue = 0.8
                pulseAnimation.toValue = 1
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = .greatestFiniteMagnitude
                self?.layer.add(pulseAnimation, forKey: "animateOpacity")
            }
        }
        
        fileprivate func addActivityView(_ yPosition: CGFloat){
            activityView = UIImageView(image: UIImage(named: "engine"))
            
            activityView.frame = CGRect(x: (frame.width/2) - 20, y: yPosition, width: 40, height: 40)
          
            turn180(activityView)
            
        }
        
        
        fileprivate func turn180(_ view : UIImageView){
            UIView.animate(withDuration: 2.0, delay: 0.0, options:.curveLinear, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: { complete in
                self.turn360(view)
            })
        }
        
        fileprivate func turn360(_ view : UIImageView){
            UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
            }, completion: { complete in
                self.turn180(view)
            })
        }
        
        fileprivate func addTextLabel(_ yPosition: CGFloat, text: String){
            textLabel = UILabel(frame: CGRect(x: 5, y: yPosition, width: activityWidth - 10, height: 40))
            textLabel.textColor = activityTextColor
            textLabel.font = activityTextFontName
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.minimumScaleFactor = 0.25
            textLabel.textAlignment = NSTextAlignment.center
            textLabel.text = text
        }
        
        fileprivate func showLoadingActivity() {
            addSubview(activityView)
            addSubview(textLabel)
            
            guard loadOverApplicationWindow else {
                topMostViewController!.view.addSubview(self)
                return
            }
            UIApplication.shared.windows.first?.addSubview(self)
        }
        
        fileprivate var fadeOutValue: CGFloat = 10.0
        
        fileprivate func hideActivity(){
            checkBackgoundWasClear()
            guard showFadeOutAnimation else {
                clearView()
                return
            }
            fadeOutAnimation()
        }
        
        fileprivate func fadeOutAnimation(){
            DispatchQueue.main.async {
                UIView.transition(with: self,
                                  duration: 0.3,
                                  options: .curveEaseOut,
                                  animations: {
                    self.transform = CGAffineTransform(scaleX: self.fadeOutValue, y: self.fadeOutValue)
                    self.alpha = 0.2
                }, completion: { (value: Bool) in
                    self.clearView()
                })
            }
        }
        
        fileprivate func checkBackgoundWasClear(){
            guard activityBackgroundColor != .clear else {
                fadeOutValue = 2
                return
            }
            textLabel.alpha = 0
            activityView.alpha = 0
        }
        
        fileprivate func clearView(){
          
            self.removeFromSuperview()
            instance = nil
            hidingInProgress = false
            
            if backgroundView != nil {
                UIView.animate(withDuration: 0.1, animations: {
                    backgroundView.backgroundColor = backgroundView.backgroundColor?.withAlphaComponent(0)
                }, completion: { _ in
                    backgroundView.removeFromSuperview()
                })
            }
            
            guard disableUIIntraction else {
                return
            }
            disableUIIntraction = false
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

private extension ANLoader{
    
    private func startLoadingActivity(_ text: String,with disableUI: Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            guard ANLoader.instance == nil else {
                debugPrint("\n ==============================* ANLoader *=====================================")
                debugPrint("Error: Loadering already active now, please stop that before creating a new one.")
                return
            }
            
            guard topMostViewController != nil else {
                debugPrint("\n ==============================* ANLoader *=====================================")
                debugPrint("Error: You don't have any views set. You may be calling in viewDidLoad or try inside main thread.")
                return
            }
            // Separate creation from showing
            ANLoader.instance = LoadingResource(text: text, disableUI: disableUI)
            DispatchQueue.main.async {
                if ANLoader.viewBackgroundDark {
                    if ANLoader.backgroundView == nil {
                        ANLoader.backgroundView = UIView(frame: UIApplication.shared.keyWindow!.frame)
                    }
                    ANLoader.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
                    topMostViewController?.view.addSubview(ANLoader.backgroundView)
                    UIView.animate(withDuration: 0.2, animations: {ANLoader.backgroundView.backgroundColor = ANLoader.backgroundView.backgroundColor?.withAlphaComponent(0.5)})
                }
                ANLoader.instance?.showLoadingActivity()
            }
        }
    }
}

private extension UIScreen {
    
    class var screenWidth: CGFloat {
        get {
            if UIInterfaceOrientation.portrait.isPortrait {
                return UIScreen.main.bounds.size.width
            } else {
                return UIScreen.main.bounds.size.height
            }
        }
    }
    
    class var screenHeight: CGFloat {
        get {
            if UIInterfaceOrientation.portrait.isPortrait {
                return UIScreen.main.bounds.size.height
            } else {
                return UIScreen.main.bounds.size.width
            }
        }
    }
}

private var topMostViewController: UIViewController? {
    var presentedVC = UIApplication.shared.keyWindow?.rootViewController
    while let controller = presentedVC?.presentedViewController {
        presentedVC = controller
    }
    return presentedVC
}
