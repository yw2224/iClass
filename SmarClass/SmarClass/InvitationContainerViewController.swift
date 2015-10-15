//
//  InvitationContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class InvitationContainerViewController: UIViewController {
    
    private struct Constants {
        static let ViewControllerIdentifers = [
            "Teammate View Controller",
            "Preference View Controller",
            "Confirmation View Controller"
        ]
        static let Titles = [
            "队员",
            "题目",
            "确认"
        ]
    }
    
    // MARK: Inited in the prepareForSegue()
    var projectID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let superView = navigationController?.view {
            let vibrancyView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            let topToTLG = NSLayoutConstraint(item: vibrancyView, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1.0, constant: 0.0)
            let bottomToBLG = NSLayoutConstraint(item: vibrancyView, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
            let leftToLeading = NSLayoutConstraint(item: vibrancyView, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
            let rightToTrailing = NSLayoutConstraint(item: vibrancyView, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            vibrancyView.translatesAutoresizingMaskIntoConstraints = false
            superView.insertSubview(vibrancyView, atIndex: 0)
            superView.addConstraints([topToTLG, bottomToBLG, leftToLeading, rightToTrailing])
        }
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dest = segue.destinationViewController as? InvitationPageViewController {
            dest.dataSource = self
            dest.delegate = self
            dest.setViewControllers([pageViewControllerAtIndex(0)!], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    func pageViewControllerAtIndex(index: Int) -> UIViewController? {
        if index < 0 || index >= Constants.ViewControllerIdentifers.count {
            return nil
        }
        guard let viewController = UIStoryboard.initViewControllerWithIdentifier(Constants.ViewControllerIdentifers[index]) else {return nil}
        (viewController as? IndexObject)?.index = index
        if let preferenceVC = viewController as? PreferenceViewController {
            preferenceVC.projectID = projectID
        } else if let teammateVC = viewController as? TeammateViewController {
            teammateVC.projectID = projectID
        }
        return viewController
    }
}

extension InvitationContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? IndexObject)?.index else {return nil}
        return pageViewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? IndexObject)?.index else {return nil}
        return pageViewControllerAtIndex(index + 1)
    }
}

extension InvitationContainerViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
            let index = (pageViewController.viewControllers?.first as? IndexObject)?.index where index >= 0 && index < Constants.Titles.count else {return}
        navigationController?.title = Constants.Titles[index]
    }
}