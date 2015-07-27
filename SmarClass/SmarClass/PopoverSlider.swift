//
//  PopupSlider.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PopoverSlider: UISlider {
    
    var popoverView: PopoverView!
    var thumbRect: CGRect {
        get {
            let trackRect = trackRectForBounds(bounds)
            return thumbRectForBounds(bounds, trackRect: trackRect, value: value)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructSlider()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructSlider()
    }
    
    func constructSlider() {
        popoverView = PopoverView(frame: CGRectZero)
        popoverView.backgroundColor = UIColor.clearColor()
        popoverView.alpha = 0.0
        addSubview(popoverView)
        
//        addTarget(self, action: "handleValueChanged:", forControlEvents: .ValueChanged)
    }
    
    func fadePopupViewInAndOut(fadeIn: Bool, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.8, animations: {
            if fadeIn {
                self.popoverView.alpha = 1.0
            } else {
                self.popoverView.alpha = 0.0
            }
        }, completion: completion)
    }
    
    func positionAndUpdatePopupView() {
        var theThumbRect = thumbRect
//        println(theThumbRect)
        theThumbRect.origin.x -= (CGRectGetWidth(theThumbRect) - theThumbRect.width) / 2
        theThumbRect.origin.y -= 1.1 * theThumbRect.height
        popoverView.frame = theThumbRect
        popoverView.value = Int(roundf(value))
    }
    
//    func handleValueChanged(sender: UISlider) {
//        if shouldAlignValue {
//            setValue(roundf(value), animated: true)
//            shouldAlignValue = false
//        }
//    }

    
}

extension PopoverSlider {
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        positionAndUpdatePopupView()
        fadePopupViewInAndOut(true)
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        positionAndUpdatePopupView()
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        fadePopupViewInAndOut(false)
        super.endTrackingWithTouch(touch, withEvent: event)
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
    }
}

