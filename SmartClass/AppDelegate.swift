//
//  AppDelegate.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/15.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import PDTSimpleCalendar
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        CocoaLumberjack.config()
        CoreDataManager.config()
        SVProgressHUD.config()
        PDTSimpleCalendarViewCell.config()
        UITabBarItem.config()
        
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(
                forTypes: [.Alert, .Sound],
                categories: nil
            )
        )
        
        // MARK: This for Core-Data-Editor Debug use, pls. feel free to comment it out.
        print((NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)).first)
        
        if  let userName = ContentManager.UserName where !userName.isEmpty,
            let password = ContentManager.Password where !password.isEmpty {
            let viewController = UIStoryboard.initViewControllerWithIdentifier(GlobalConstants.LoginViewControllerIdentifier) as! LoginViewController
            viewController.shouldAutoLogin = true
            window?.rootViewController = viewController
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        CoreDataManager.sharedInstance.saveInBackground()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.cleanup()
    }
}

