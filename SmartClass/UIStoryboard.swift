//
//  UIStoryboard.swift
//  iBeaconToy
//
//  Created by PengZhao on 15/12/29.
//  Copyright © 2015年 pku. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func initViewControllerWithIdentifier(identifier: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(identifier)
    }
    
}

