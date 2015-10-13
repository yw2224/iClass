//
//  MainUITabBarController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/6.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var courseID: String!
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        guard let dest = viewController as? NavigationController else {return}
    
        if let qvc = dest.childViewControllers.first as? QuizViewController {
            qvc.courseID = courseID
        } else if let pcvc = dest.childViewControllers.first as? ProjectContainerViewController {
            pcvc.courseID = courseID
        }
    }
    
}