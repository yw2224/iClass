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
    
    @IBOutlet weak var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = Constants.NumOfPages
            pageControl.currentPage = 0
        }
    }
    
    private struct Constants {
        static let NumOfPages = 4
        static let SplashViewControllerIdentifier = "Splash View Controller"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSplashViewController()
    }
    
    func setupSplashViewController() {
        splashPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        splashPageViewController.dataSource = self
        splashPageViewController.delegate = self
        splashPageViewController.view.frame = view.frame
        
        splashPageViewController.setViewControllers([splashChildViewControllerAtIndex(0)!], direction: .Forward, animated: true, completion: nil)
        
        addChildViewController(splashPageViewController)
        view.insertSubview(splashPageViewController.view, atIndex: 0)
        splashPageViewController.didMoveToParentViewController(self)

    }
    
    func splashChildViewControllerAtIndex(index: Int) -> SplashViewController? {
        guard (index >= 0 && index < Constants.NumOfPages),
            let svc = UIStoryboard.initViewControllerWithIdentifier("\(Constants.SplashViewControllerIdentifier) \(index)") as? SplashViewController else {
            return nil
        }
        svc.index = index
        return svc
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension LoginContainerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let svc = viewController as? IndexObject else { return nil }
        return splashChildViewControllerAtIndex(svc.index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let svc = viewController as? IndexObject else { return nil }
        return splashChildViewControllerAtIndex(svc.index + 1)
    }
}

extension LoginContainerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
            let current = pageViewController.viewControllers?.first as? SplashViewController
        else { return }
        pageControl.currentPage = current.index
    }
}
