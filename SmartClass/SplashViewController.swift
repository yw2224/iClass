//
//  ViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol AnimationControl {
    
    optional func setupAnimation()
    optional func removeAnimation()
}

class SplashViewController: IndexViewController {
    
    private var topSpaceToTLG = [NSLayoutConstraint]()
    
    // Fixing top layout guide issue in UIPageViewControllers, see stackoverflow for details.
    // http://stackoverflow.com/questions/27793836/uiimageview-resizing-issue-in-uipageviewcontroller
    var parentTLGlength: CGFloat = 20
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for constraint in topSpaceToTLG {
            if topLayoutGuide.length == 0 {
                // Lengthen the autolayout constraint to where we know the
                // top layout guide will be when the transition completes
                constraint.constant = parentTLGlength
            } else {
                constraint.constant = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if index >= 0 && index < GlobalConstants.SplashPagesBackgroundColor.count {
            view.backgroundColor = GlobalConstants.SplashPagesBackgroundColor[index]
        }
    }
    
    func appendTopSpaceLayoutConstraint(constraint: NSLayoutConstraint) {
        topSpaceToTLG.append(constraint)
    }
}

extension SplashViewController: AnimationControl {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupAnimation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeAnimation()
    }
    
    func setupAnimation() {
        // Do nothing.
    }
    
    func removeAnimation() {
        // Do nothing.
    }
}
