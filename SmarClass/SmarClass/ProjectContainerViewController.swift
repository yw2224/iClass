//
//  ProjectContainerViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProjectContainerViewController: UIViewController {

    var switcherViewController: SwitcherViewController!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private struct Constants {
        static let GroupViewControllerSegueIdentifier = "Group View Controller Segue"
        static let ProblemViewControllerSegueIdentifier = "Problem View Controller Segue"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        guard let switcher = segue.destinationViewController as? SwitcherViewController else {return}
        switcherViewController = switcher
        switcherViewController.segueIdentifiers = [
            Constants.GroupViewControllerSegueIdentifier,
            Constants.ProblemViewControllerSegueIdentifier
        ]
        switcherViewController.delegate = self
    }
}

extension ProjectContainerViewController: SwitcherAnimationDelegate {
    func animationDidStop() {
        segmentControl.userInteractionEnabled = true
    }
}
