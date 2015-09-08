//
//  MainUITabBarController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/6.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var course_id: String!
    
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let dest = viewController as? NavigationController {
            if let qvc = dest.childViewControllers.first as? QuizViewController {
                qvc.course_id = course_id
            }
        }
    }
    
}