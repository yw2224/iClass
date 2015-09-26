//
//  RedBarViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import ChameleonFramework
import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.barTintColor = GlobalConstants.BarTintColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if #available(iOS 9.0, *) {
            (topViewController ?? self).unwindForSegue(unwindSegue, towardsViewController: subsequentVC)
        } else {
            // Fallback on earlier versions
            (topViewController ?? self).segueForUnwindingToViewController(subsequentVC, fromViewController: self, identifier: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let navBarTintColor = navigationBar.barTintColor {
            return StatusBarContrastColorOf(navBarTintColor)
        } else {
            return .Default
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
