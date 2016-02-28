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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard
            let dest = segue.destinationViewController as? LoginViewController,
            let button = sender as? UIButton else { return }
        
        dest.status = LoginStatus(booleanLiteral: button.tag != 0)
    }

}
