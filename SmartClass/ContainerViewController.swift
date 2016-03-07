//
//  ContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

enum SlideOutState : BooleanType, BooleanLiteralConvertible {
    
    case BothCollapsed
    case LeftPanelExpanded
    
    init(booleanLiteral value: Bool) {
        if value {
            self = .LeftPanelExpanded
        } else {
            self = .BothCollapsed
        }
    }

    var boolValue : Bool {
        get {
            switch self {
            case .LeftPanelExpanded:
                return true
            case .BothCollapsed:
                return false
            }
        }
    }
}

protocol CenteralViewDelegate: class {
    
    func toggleLeftPanel(animate: Bool)
    func collapseLeftPanel()
}

class ContainerViewController: UIViewController {
    
    var isAnimating = false
    var gestureDisabled = false
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var centerNavigationController: NavigationController!
    var mainHomeViewController: MainHomeViewController!
    var userSidebarViewController: SidePanelViewController!

    var targetPosition: CGFloat {
        get {
            return CGRectGetWidth(view.frame) * Constants.SidePanelOffsetRatio
        }
    }
    var scaleRatio: CGFloat {
        get {
            return UIDevice.currentDevice().orientation.isPortrait.boolValue ?
                Constants.PortraitScaleRatio :
                Constants.LandscapeScaleRatio
        }
    }
    
    // set this var to be true before sliding out the side panel,
    // and set this var to be false after sliding out the side panel.
    var currentState = SlideOutState.BothCollapsed {
        didSet {
            showShadowForMainHomeViewController(currentState.boolValue)
            if currentState {
                mainHomeViewController.disableTableView()
            } else {
                removeLeftPanelViewController()
                mainHomeViewController.enableTableView()
            }
        }
    }
    
    private struct Constants {
        static let NavigationControllerIdentifier  = "Course Navigation View Controller"
        static let SidebarViewControllerIdentifier = "User Siddebar View Controller"
        static let AboutUsSegueIdentifier          = "About Us Segue"
        static let UnwindToLoginSegueIdentifier    = "Unwind to Login Segue"
        static let SidePanelOffsetRatio: CGFloat   = 0.46
        static let PortraitScaleRatio: CGFloat     = 0.90
        static let LandscapeScaleRatio: CGFloat    = 0.85
        static let OriginAlpha: CGFloat            = 0.20
        static let OriginBackgroundColor: CGFloat  = 0.40
        
        static let AboutUsCellIndexPathRow         = 0
        static let LogoutCellIndexPathRow          = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerNavigationController = UIStoryboard.initViewControllerWithIdentifier(Constants.NavigationControllerIdentifier) as! NavigationController
        mainHomeViewController = centerNavigationController.viewControllers[0] as! MainHomeViewController
        mainHomeViewController.delegate = self
        
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collapseLeftPanel()
    }
    
    // Fix gesture recognition & autorotation bug.
    // See git commit message for more details.
    override func shouldAutorotate() -> Bool {
        return !isAnimating
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isAnimating {
            return UIInterfaceOrientationMask.Portrait
        }
        return UIInterfaceOrientationMask.All
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

// MARK: MainHomeViewController delegate
extension ContainerViewController: CenteralViewDelegate {
    
    func toggleLeftPanel(animate: Bool) {
        let notAlreadyExpanded = !(currentState)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded, animate: animate)
    }
    
    func collapseLeftPanel() {
        if currentState {
            toggleLeftPanel(false)
        }
        // animateLeftPanel(shouldExpand: false, animate: false)
    }
    
    func addLeftPanelViewController() {
        if userSidebarViewController == nil {
            userSidebarViewController = UIStoryboard.initViewControllerWithIdentifier(Constants.SidebarViewControllerIdentifier) as! SidePanelViewController
            userSidebarViewController.delegate = self
            
            userSidebarViewController.view.backgroundColor = UIColor.clearColor()
            view.insertSubview(userSidebarViewController!.view, atIndex: 0)
            addChildViewController(userSidebarViewController!)
            userSidebarViewController.didMoveToParentViewController(self)
            userSidebarViewController.view.alpha = Constants.OriginAlpha
            view.backgroundColor = UIColor(white: Constants.OriginBackgroundColor, alpha: 1.0)
        }
    }
    
    func removeLeftPanelViewController() {
        userSidebarViewController?.view.removeFromSuperview()
        userSidebarViewController = nil
    }
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool, animate: Bool, block: (() -> Void)? = nil) {
        isAnimating = true
        gestureDisabled = true
        if (shouldExpand) {
            currentState = true
        }
        animateCenterPanelXPosition(ratio: shouldExpand ? 1.0 : 0, animate: animate) {
            [weak self] in
            if $0 {
                if !shouldExpand {
                    self?.currentState = false
                }
                self?.isAnimating = false
                self?.gestureDisabled = false
                block?()
            }
        }
    }
    
    func animateCenterPanelXPosition(ratio ratio: CGFloat, animate: Bool, completion: ((Bool) -> Void)) {
        if animate {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                self.partialAnimation(ratio)
            }, completion: completion)
        } else {
            partialAnimation(ratio)
            completion(true)
        }
    }
    
    func showShadowForMainHomeViewController(shouldShowShadow: Bool) {
        centerNavigationController.view.layer.shadowOpacity = shouldShowShadow ? 0.8 : 0
    }
    
    func partialAnimation(ratio: CGFloat) {
        let viewScaleRatio = 1 + (scaleRatio - 1) * ratio
        let scaleTransform = CGAffineTransformMakeScale(viewScaleRatio, viewScaleRatio)
        let translationTransform = CGAffineTransformMakeTranslation(targetPosition * ratio, 0)
        centerNavigationController.view.transform = CGAffineTransformConcat(translationTransform, scaleTransform)
        userSidebarViewController.view.alpha = Constants.OriginAlpha + (1 - Constants.OriginAlpha) * ratio
        view.backgroundColor = UIColor(white: Constants.OriginBackgroundColor + (1 - Constants.OriginBackgroundColor) * ratio, alpha: 1.0)
    }
}

extension ContainerViewController: SidePanelDelegate {
    
    func sidePanelTappedAtRow(row: Int, sender: AnyObject) {
        animateLeftPanel(shouldExpand: false, animate: true) {
            if row == Constants.AboutUsCellIndexPathRow {
                self.mainHomeViewController.performSegueWithIdentifier(Constants.AboutUsSegueIdentifier, sender: sender)
            } else if row == Constants.LogoutCellIndexPathRow {
                ContentManager.sharedInstance.truncateData()
                self.mainHomeViewController.performSegueWithIdentifier(Constants.UnwindToLoginSegueIdentifier, sender: sender)
            }
        }
    }
}

// MARK: Gesture recognizer
extension ContainerViewController: UIGestureRecognizerDelegate {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let left2Right = recognizer.velocityInView(view).x > 0
        let x = centerNavigationController.view.frame.origin.x
        let ratio: CGFloat = {
            let moveX = recognizer.translationInView(view).x
            let offset = currentState ? -moveX : moveX
            let progress = max(min(offset, targetPosition), 0) / targetPosition
            return currentState ? 1 - progress : progress
        }()
        
        if (x >= targetPosition && left2Right && currentState)
            || (x <= 0 && !left2Right && !currentState)
            || gestureDisabled
            || (recognizer.state != .Began && !isAnimating){
            return
        }
        
        switch recognizer.state {
        case .Began:
            isAnimating = true
            if !currentState && left2Right {
                addLeftPanelViewController()
                showShadowForMainHomeViewController(true)
            }
        case .Changed:
            partialAnimation(ratio)
        case .Ended:
            if !currentState {
                if ratio > 0.5 {
                    proceedCenteralViewControllerOffset()
                } else {
                    restoreCenteralViewControllerState()
                }
            } else {
                if ratio <= 0.8 {
                    proceedCenteralViewControllerOffset()
                } else {
                    restoreCenteralViewControllerState()
                }
            }
        case .Failed: fallthrough
        case .Cancelled: restoreCenteralViewControllerState()
        default: break
        }
    }
    
    func proceedCenteralViewControllerOffset() {
        gestureDisabled = true
        let ratio : CGFloat = currentState ? 0 : 1.0
        let state = SlideOutState(booleanLiteral: !currentState)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.partialAnimation(ratio)
            }) { [weak self] in
                if $0 {
                    self?.currentState = state
                    self?.gestureDisabled = false
                    self?.isAnimating = false
                }
        }
    }

    func restoreCenteralViewControllerState() {
        gestureDisabled = true
        let ratio : CGFloat = currentState ? 1.0 : 0
        let state = SlideOutState(booleanLiteral: currentState.boolValue)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.partialAnimation(ratio)
            }) { [weak self] in
                if $0 {
                    self?.currentState = state
                    self?.gestureDisabled = false
                    self?.isAnimating = false
                }
        }    }
}