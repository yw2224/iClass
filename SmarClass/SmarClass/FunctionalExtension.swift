//
//  Extensions.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func initViewControllerWithIdentifier(identifier: String!) -> UIViewController? {
        if let theIdentifier = identifier {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier(theIdentifier) as? UIViewController
        }
        return nil
    }
}

extension UIViewController {
    func contentViewController(index: Int?) -> UIViewController {
        if self is UINavigationController {
            return (self as! UINavigationController).visibleViewController
        } else if self is UITabBarController {
            let viewControllers = (self as! UITabBarController).viewControllers as! [UIViewController]
            return viewControllers[index!].contentViewController(index)
        }
        return self
    }
}

extension UIView {
    private struct Constants {
        static let HUGE_VAL: Float = 1e7
        static let AnimationKeyName = "pulse"
    }
    
    func startGlow(shadowColor: UIColor) {
        var transfrom = CGAffineTransformMakeScale(1.1, 1.1)
        let circle = CGPathCreateWithEllipseInRect(bounds, &transfrom)
        let shadowLayer = CALayer(layer: layer)
        layer.shadowColor = shadowColor.CGColor
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.3
        layer.shadowPath = circle
        
        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0;
        animation.toValue = 0.85;
        animation.repeatCount = Constants.HUGE_VAL
        animation.duration = 1.0;
        animation.autoreverses = true;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        layer.addAnimation(animation, forKey: Constants.AnimationKeyName)
    }
    
    func stopGlow() {
        layer.shadowOpacity = 0.0
        layer.removeAnimationForKey(Constants.AnimationKeyName)
    }
}