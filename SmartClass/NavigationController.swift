//
//  RedBarViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var tabbarNormalStateImage: UIImage?
    var tabbarSelectedStateImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let image = tabbarNormalStateImage {
            tabBarItem.image = image.imageWithRenderingMode(.AlwaysOriginal)
        }
        if let image = tabbarSelectedStateImage {
            tabBarItem.selectedImage = image.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        navigationBar.barTintColor = GlobalConstants.BarTintColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
