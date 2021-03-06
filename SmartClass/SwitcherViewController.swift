//
//  SwitcherViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

protocol Switcher {
    var childViewControllerSegueIdentifier: [String] {get set}
    var currentViewController: UIViewController? {get}
    func switchChildViewControllerAtIndex(index: Int)
}

protocol SwitcherAnimationDelegate: class {
    func animationDidEnd()
}

class SwitcherViewController: UIViewController {

    var childViewControllerSegueIdentifier = [String]()
    var currentIndex = 0
    weak var delegate: SwitcherAnimationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let identifier = childViewControllerSegueIdentifier.first else { return }
        performSegueWithIdentifier(identifier, sender: self)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard
            let id = segue.identifier,
            let index = childViewControllerSegueIdentifier.indexOf(id)
        else { return }
        
        let dest = segue.destinationViewController
        if let first = childViewControllers.first {
            swapFromViewController(first, toViewController: dest, atIndex: index)
        } else {
            addChildViewController(dest)
            dest.view.frame = view.frame
            view.addSubview(dest.view)
            dest.didMoveToParentViewController(self)
        }
    }
    
    func swapFromViewController(fromViewController: UIViewController, toViewController: UIViewController, atIndex index: Int) {
        toViewController.view.frame = view.frame
        fromViewController.willMoveToParentViewController(nil)
        addChildViewController(toViewController)
        transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.7, options:
            currentIndex < index ? .TransitionFlipFromRight : .TransitionFlipFromLeft,
            animations: nil) {
            [weak self] in
            if $0 {
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
                self?.delegate?.animationDidEnd()
            }
        }
    }

}

extension SwitcherViewController: Switcher {
    
    var currentViewController: UIViewController? {
        get {
            return childViewControllers.first
        }
    }
    
    func switchChildViewControllerAtIndex(index: Int) {
        guard index >= 0
            && index < childViewControllerSegueIdentifier.count
            && currentIndex != index else { return }
        performSegueWithIdentifier(childViewControllerSegueIdentifier[index], sender: self)
        currentIndex = index
    }
}
