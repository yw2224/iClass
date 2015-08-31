//
//  ContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
}

protocol CenteralViewDelegate {
    func toggleLeftPanel(animate: Bool)
    func collapseLeftPanel()
}

class ContainerViewController: UIViewController {
    
    private struct Constants {
        static let NavigationControllerIdentifier = "Course Navigation View Controller"
        static let SidebarViewControllerIdentifier = "User Siddebar View Controller"
        static let SidePanelOffsetRatio: CGFloat = 0.46
        static let PortraitScaleRatio: CGFloat = 0.90
        static let LandscapeScaleRatio: CGFloat = 0.85
        static let OriginAlpha: CGFloat = 0.20
        static let OriginBackgroundColor: CGFloat = 0.40
    }
    
    var targetPosition: CGFloat!
    var isAnimating = false
    var scaleRatio: CGFloat {
        get {
            return UIDevice.currentDevice().orientation.isPortrait.boolValue ?
                Constants.PortraitScaleRatio :
                Constants.LandscapeScaleRatio
        }
    }
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            showShadowForMainHomeViewController(currentState != .BothCollapsed)
            if currentState == .BothCollapsed {
                removeLeftPanelViewController()
                mainHomeViewController.enableTableView()
            } else {
                mainHomeViewController.disableTableView()
            }
        }
    }
    var centerNavigationController: NavigationController!
    var mainHomeViewController: MainHomeViewController!
    var userSidebarViewController: SidePanelViewController!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var gestureDisabled = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetPosition = CGRectGetWidth(view.frame) * Constants.SidePanelOffsetRatio
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
    
    override func supportedInterfaceOrientations() -> Int {
        if isAnimating {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}

// MARK: MainHomeViewController delegate
extension ContainerViewController: CenteralViewDelegate {
    
    func toggleLeftPanel(animate: Bool) {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded, animate: animate)
    }
    
    func collapseLeftPanel() {
        if currentState == .LeftPanelExpanded {
            toggleLeftPanel(false)
        }
//        Safe Code
//        animateLeftPanel(shouldExpand: false, animate: false)
    }
    
    // Helpers
    func addLeftPanelViewController() {
        if userSidebarViewController == nil {
            userSidebarViewController = UIStoryboard.initViewControllerWithIdentifier(Constants.SidebarViewControllerIdentifier) as? SidePanelViewController
            userSidebarViewController!.delegate = self
            
            userSidebarViewController.view.backgroundColor = UIColor.clearColor()
            view.insertSubview(userSidebarViewController!.view, atIndex: 0)
            addChildViewController(userSidebarViewController!)
            userSidebarViewController!.didMoveToParentViewController(self)
            userSidebarViewController.view.alpha = Constants.OriginAlpha
            view.backgroundColor = UIColor(white: Constants.OriginBackgroundColor, alpha: 1.0)
        }
    }
    
    func removeLeftPanelViewController() {
        if userSidebarViewController != nil {
            userSidebarViewController!.view.removeFromSuperview()
            userSidebarViewController = nil;
        }
    }
    
    func animateLeftPanel(#shouldExpand: Bool, animate: Bool) {
        isAnimating = true
        gestureDisabled = true
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(ratio: 1.0, animate: animate) {
                [weak self] in
                if $0 {
                    self?.isAnimating = false
                    self?.gestureDisabled = false
                }
            }
        } else {
            animateCenterPanelXPosition(ratio: 0, animate: animate) {
                [weak self] in
                if $0 {
                    self?.currentState = .BothCollapsed
                    self?.isAnimating = false
                    self?.gestureDisabled = false
                }
            }
        }
    }
    
    func animateCenterPanelXPosition(#ratio: CGFloat, animate: Bool, completion: ((Bool) -> Void)) {
        if animate {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.partialAnimation(ratio)
            }, completion: completion)
        } else {
            partialAnimation(ratio)
            completion(true)
        }
    }
    
    func showShadowForMainHomeViewController(shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
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
    
}

// MARK: Gesture recognizer
extension ContainerViewController: UIGestureRecognizerDelegate {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let left2Right = (recognizer.velocityInView(view).x > 0)
        let x = centerNavigationController.view.frame.origin.x
        let ratio: CGFloat = {
            let moveX = recognizer.translationInView(self.view).x
            let offset = self.currentState == .BothCollapsed ? moveX : -moveX
            let progress = max(min(offset, self.targetPosition), 0) / self.targetPosition
            return self.currentState == .BothCollapsed ? progress : 1 - progress
        }()

        if (x >= targetPosition && left2Right && currentState == .LeftPanelExpanded)
            || (x <= 0 && !left2Right && currentState == .BothCollapsed)
            || gestureDisabled {
            return
        }
        
        switch recognizer.state {
        case .Began:
            isAnimating = true
            if currentState == .BothCollapsed && left2Right {
                addLeftPanelViewController()
                showShadowForMainHomeViewController(true)
            }
        case .Changed:
            partialAnimation(ratio)
        case .Ended:
            if currentState == .BothCollapsed {
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
        if currentState == .BothCollapsed {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.partialAnimation(1.0)
                }) { [weak self] in
                    if $0 {
                        self?.currentState = .LeftPanelExpanded
                        self?.gestureDisabled = false
                        self?.isAnimating = false
                    }
            }
        } else {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.partialAnimation(0)
                }) { [weak self] in
                    if $0 {
                        self?.currentState = .BothCollapsed
                        self?.gestureDisabled = false
                        self?.isAnimating = false
                    }
            }
        }
    }

    func restoreCenteralViewControllerState() {
        gestureDisabled = true
        if currentState == .BothCollapsed {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.partialAnimation(0)
            }) { [weak self] in
                if $0 {
                    self?.currentState = .BothCollapsed
                    self?.gestureDisabled = false
                    self?.isAnimating = false
                }
            }
        } else {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8,initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.partialAnimation(1.0)
            }) { [weak self] in
                if $0 {
                    self?.currentState = .LeftPanelExpanded
                    self?.gestureDisabled = false
                    self?.isAnimating = false
                }
            }
        }
    }
}