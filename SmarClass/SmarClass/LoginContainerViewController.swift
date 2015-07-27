//
//  ViewController.swift
//  SmartClass
//
//  Created by ZhaoPeng on 15-3-16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class LoginContainerViewController: UIViewController {
    
    var splashPageViewController: UIPageViewController!
    
	var loginPanelViewController :LoginPanelViewController!

    private struct Constants {
        static let NumOfPages = 4
        static let SplashViewControllerIdentifier = "Splash View Controller"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up page view controller
        setupSplashViewController()
    }
    
    // MARK: Addtional UI elements & helpers
    func setupSplashViewController() {
        splashPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        splashPageViewController.dataSource = self
        splashPageViewController.delegate = self
        splashPageViewController.view.frame = view.frame
        
        let firshSplashViewController = splashChildViewControllerAtIndex(0);
        splashPageViewController.setViewControllers([firshSplashViewController!], direction: .Forward, animated: true, completion: nil)
        
        addChildViewController(splashPageViewController)
        view.insertSubview(splashPageViewController.view, atIndex: 0)
        splashPageViewController.didMoveToParentViewController(self)
    }
    
    func splashChildViewControllerAtIndex(index: Int) -> SplashViewController? {
        if (index < 0 || index >= Constants.NumOfPages) {
            return nil
        }
        
        return {
            let svc = UIStoryboard.initViewControllerWithIdentifier(Constants.SplashViewControllerIdentifier) as! SplashViewController
            svc.index = index
            return svc
        }()
    }
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

extension LoginContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let svc = viewController as? SplashViewController {
            return splashChildViewControllerAtIndex(svc.index - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let svc = viewController as? SplashViewController {
            return splashChildViewControllerAtIndex(svc.index + 1)
        }
        return nil
    }
}

extension LoginContainerViewController: UIPageViewControllerDelegate {
    
}
