//
//  Extensions.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord
import SwiftyJSON

extension UIStoryboard {
    
    class func initViewControllerWithIdentifier(identifier: String!) -> UIViewController? {
        guard let identifier = identifier else {return nil}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(identifier)
    }
    
}

extension UIViewController {
    
    func contentViewController(index: Int = 0) -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController!
        } else if let tabbarController = self as? UITabBarController {
            guard let viewControllers = tabbarController.viewControllers else {return self}
            return viewControllers[index].contentViewController(index)
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
        layer.shadowColor = shadowColor.CGColor
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.3
        
        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.7
        animation.repeatCount = Constants.HUGE_VAL
        animation.duration = 1.0
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        layer.addAnimation(animation, forKey: Constants.AnimationKeyName)
    }
    
    func stopGlow() {
        layer.shadowOpacity = 0.0
        layer.removeAnimationForKey(Constants.AnimationKeyName)
    }
}

extension Character {
    
    func unicodeScalarCodePoint() -> Int {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        return Int(scalars[scalars.startIndex].value)
    }
    
}

protocol JSONConvertible: class {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject?
    
}

extension JSONConvertible {
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        return jsonArray.map {
            return objectFromJSONObject($0)!
        }
    }
    
}