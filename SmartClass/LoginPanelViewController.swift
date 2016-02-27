//
//  LoginPanelViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class LoginPanelViewController: UIViewController {    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard
            let dest = segue.destinationViewController as? LoginViewController,
            let button = sender as? UIButton else {return}
        
        dest.status = LoginStatus(booleanLiteral: button.tag != 0)
    }

}
