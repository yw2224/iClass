//
//  InvitationContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import SVProgressHUD
import UIKit

class InvitationContainerViewController: UIViewController {
    
    private struct Constants {
        static let ViewControllerIdentifers = [
            "Preference View Controller",
            "Teammate View Controller",
            "Confirmation View Controller"
        ]
        static let Titles = [
            "题目",
            "队员",
            "确认"
        ]
        static let unwindToProjectContainerViewControllerSegueIdentifer = "Unwind to Project Container View Controller"
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentStage = 0 {
        didSet {
            invitationPageViewController.setViewControllers([pageViewControllerAtIndex(currentStage)!],
                direction: .Forward, animated: true, completion: nil)
        }
    }
    
    // MARK: Inited in the prepareForSegue()
    var projectID: String!

    // MARK: Set as delegate placeholders
    var problemID: String?
    var groupSize: Int?
    var teammates = [(name: String, realName: String, encryptID: String)]()
    var problemName: String?
    
    var invitationPageViewController: InvitationPageViewController!
    
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
        navigationItem.title = Constants.Titles[0]
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
            invitationPageViewController = dest
            invitationPageViewController.dataSource = self
            invitationPageViewController.delegate = self
            invitationPageViewController.setViewControllers([pageViewControllerAtIndex(currentStage)!], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    func pageViewControllerAtIndex(index: Int) -> UIViewController? {
        if index < 0 || index >= Constants.ViewControllerIdentifers.count || index > currentStage {
            return nil
        }
        guard let viewController = UIStoryboard.initViewControllerWithIdentifier(Constants.ViewControllerIdentifers[index]) else {return nil}
        (viewController as? IndexObject)?.index = index
        if let preferenceVC = viewController as? PreferenceViewController {
            preferenceVC.projectID = projectID
            preferenceVC.icvc = self
        } else if let teammateVC = viewController as? TeammateViewController {
            teammateVC.projectID = projectID
            teammateVC.icvc = self
            // MARK: THIS MAY BE A PROTENTIAL BUG FOR FUTURE WORK!!!
            teammateVC.groupSize = groupSize ?? 0
        } else if let confirmVC = viewController as? ConfirmationViewController {
            confirmVC.icvc = self
        }
        navigationItem.title = Constants.Titles[index]
        pageControl.currentPage = index
        
        if index == Constants.Titles.count - 1 {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "inviteGroup")
            barButtonItem.tintColor = UIColor.whiteColor()
            navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
        } else {
            navigationItem.setRightBarButtonItem(nil, animated: true)
        }
        return viewController
    }
    
    func inviteGroup() {
        SVProgressHUD.showWithStatus(GlobalConstants.InvitingGroupPropmt)
        
        guard let problemID = problemID else {return}
        let members = teammates.map {return $0.encryptID}
        ContentManager.sharedInstance.groupInvite(projectID, problemID: problemID, members: members) {
            error in
            SVProgressHUD.popActivity()
            
            if error == nil {
                self.performSegueWithIdentifier(Constants.unwindToProjectContainerViewControllerSegueIdentifer, sender: self)
            } else {
                if case .NetworkUnauthenticated = error! {
                    self.promptLoginViewController()
                } else if case .NetworkForbiddenAccess = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.GroupInvitionErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
    }
}

extension InvitationContainerViewController: UIPageViewControllerDataSource {
    
    // MARK: THIS SHOULD BE IMPROVED FOR BETTER INTERACTION
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
}

extension InvitationContainerViewController: UIPageViewControllerDelegate {
    
//    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        guard completed,
//            let index = (pageViewController.viewControllers?.first as? IndexObject)?.index where index >= 0 && index < Constants.Titles.count else {return}
//        navigationItem.title = Constants.Titles[index]
//        pageControl.currentPage = index
//        
//        if index == Constants.Titles.count - 1 {
//            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "inviteGroup")
//            barButtonItem.tintColor = UIColor.whiteColor()
//            navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
//        } else {
//            navigationItem.setRightBarButtonItem(nil, animated: true)
//        }
//    }
}