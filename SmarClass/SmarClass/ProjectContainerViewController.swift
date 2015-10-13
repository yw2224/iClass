//
//  ProjectContainerViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProjectContainerViewController: UIViewController {

    var switcherViewController: ProjectSwitcherViewController!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private struct Constants {
        static let GroupViewControllerSegueIdentifier = "Group View Controller Segue"
        static let ProblemViewControllerSegueIdentifier = "Problem View Controller Segue"
        
    }
    
    // MARK: Inited in the prepareForSegue()
    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        retrieveProjectList()
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
    
    func retrieveProjectList() {
        ContentManager.sharedInstance.projectList(courseID, block: nil)
    }
    
    @IBAction func switchChildViewController(sender: UISegmentedControl) {
        sender.userInteractionEnabled = false
        switcherViewController.switchChildViewControllerAtIndex(sender.selectedSegmentIndex)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let switcher = segue.destinationViewController as? ProjectSwitcherViewController else {return}
        switcherViewController = switcher
        switcherViewController.segueIdentifiers = [
            Constants.GroupViewControllerSegueIdentifier,
            Constants.ProblemViewControllerSegueIdentifier
        ]
        switcherViewController.delegate = self
        switcherViewController.courseID = courseID
    }
}

extension ProjectContainerViewController: SwitcherAnimationDelegate {
    func animationDidStop() {
        segmentControl.userInteractionEnabled = true
    }
}
