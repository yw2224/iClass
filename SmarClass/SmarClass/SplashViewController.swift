//
//  ViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

@objc protocol AnimationControl {
    optional func setupAnimation()
    optional func removeAnimation()
}

class SplashViewController: IndexViewController {
    
    var imageView: UIImageView!
    var topSpaceToTLG: NSLayoutConstraint!
    var bottomSpaceToBLG: NSLayoutConstraint!
    var leftSpaceToLeading: NSLayoutConstraint!
    var rightSpaceToTrailing: NSLayoutConstraint!
    
    // Fixing top layout guide issue in UIPageViewControllers, see stackoverflow for details.
    // http://stackoverflow.com/questions/27793836/uiimageview-resizing-issue-in-uipageviewcontroller
    var parentTLGlength: CGFloat = 20
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if topLayoutGuide.length == 0 {
            // Lengthen the autolayout constraint to where we know the
            // top layout guide will be when the transition completes
            topSpaceToTLG.constant = parentTLGlength
        } else {
            topSpaceToTLG.constant = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(imageView)
        
        topSpaceToTLG = NSLayoutConstraint(
            item: imageView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)
        bottomSpaceToBLG = NSLayoutConstraint(
            item: imageView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: bottomLayoutGuide,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0)
        leftSpaceToLeading = NSLayoutConstraint(
            item: imageView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: imageView.superview,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0)
        rightSpaceToTrailing = NSLayoutConstraint(
            item: imageView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: imageView.superview,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0)
        
        view.addConstraints([
            topSpaceToTLG,
            bottomSpaceToBLG,
            leftSpaceToLeading,
            rightSpaceToTrailing
            ])
        
        if index >= 0 && index < GlobalConstants.SplashPagesBackgroundColor.count {
            view.backgroundColor = GlobalConstants.SplashPagesBackgroundColor[index]
        }
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
