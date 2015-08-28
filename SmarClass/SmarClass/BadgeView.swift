//
//  BadgeView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import ChameleonFramework

class BadgeView: UIView {
    
    private struct Constants {
        static let MaxBadgeNum = 99
        static let BadgeFontSize: CGFloat = 12.0
        static let CornerRadiusOffset: CGFloat = 4.0
    }
    
    var badgeNum: Int = 0 {
        didSet {
            if badgeNum == 0 {
                textLabel.hidden = true
                hidden = true
                return
            }
            
            textLabel.hidden = false
            hidden = false
            textLabel.text = String(min(badgeNum, Constants.MaxBadgeNum))
            textLabel.sizeToFit()
            let x = max(0, (CGRectGetWidth(frame) - CGRectGetWidth(textLabel.frame)) / 2.0)
            let y = max(0, (CGRectGetHeight(frame) - CGRectGetHeight(textLabel.frame)) / 2.0)
            textLabel.frame.origin = CGPointMake(x ,y)
            setNeedsDisplay()
        }
    }
    private var textLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textLabel = UILabel(frame: CGRectZero)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.font = UIFont.boldSystemFontOfSize(Constants.BadgeFontSize)
        textLabel.hidden = true
        
        layer.masksToBounds = true
        layer.cornerRadius = (CGRectGetWidth(frame) - Constants.CornerRadiusOffset) / 2.0
        layer.backgroundColor = GlobalConstants.FlatDarkRed.CGColor
        
        addSubview(textLabel)
    }
    
    deinit {
        textLabel.removeFromSuperview()
        textLabel = nil
    }
}