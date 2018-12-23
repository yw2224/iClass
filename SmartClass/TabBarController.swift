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
    
    override func awakeFromNib() {
        delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let dest = viewController.contentViewController()
        
        if let qvc = dest as? QuizViewController {
            qvc.courseID = courseID
        }
        return true
    }
    
}