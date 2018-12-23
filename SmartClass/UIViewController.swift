//
//  UIViewController.swift
//  iBeaconToy
//
//  Created by PengZhao on 15/12/29.
//  Copyright © 2015年 pku. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
    
    func contentViewController(index: Int = 0) -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? self
        } else if let tabbarController = self as? UITabBarController {
            guard let viewControllers = tabbarController.viewControllers
                where index >= 0 && index < viewControllers.count
                else {return self}
            return viewControllers[index].contentViewController(index)
        }
        return self
    }
    
    func promptLoginViewController() {
        let loginViewController = UIStoryboard.initViewControllerWithIdentifier(GlobalConstants.LoginViewControllerIdentifier) as! LoginViewController
        loginViewController.isRuntimeInit = true
        presentViewController(loginViewController, animated: true) {
            SVProgressHUD.showErrorWithStatus(GlobalConstants.UserTokenExpiredErrorPrompt)
        }
    }
    
}

extension UIViewController {
    
    func errorHandler(error: NetworkErrorType?, serverErrorPrompt: String? = nil, forbiddenAccessPrompt: String? = nil) {
        if let error = error {
            switch error {
            case .NetworkUnreachable(_):
                SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
            case .NetworkUnauthenticated(_):
                promptLoginViewController()
            case .NetworkServerError(let message):
                SVProgressHUD.showErrorWithStatus(serverErrorPrompt ?? message)
            case .NetworkForbiddenAccess(let message):
                SVProgressHUD.showErrorWithStatus(forbiddenAccessPrompt ?? message)
            case .NetworkWrongParameter(let message):
                SVProgressHUD.showErrorWithStatus(message)
            }
        }
        
        (self as? RefreshControlAnimationDelegate)?.animationDidEnd()
    }
    
}
