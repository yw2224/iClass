//
//  MainUITabBarController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/6.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var course: Course!
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let dest = viewController as? NavigationController {
            
//            if let testVC = dest.childViewControllers[0] as? TestViewController {
//                testVC.course = course
//            }
            if let covc = dest.childViewControllers[0] as? CourseOverviewController{
                covc.course = course
            }
        }
    }
}