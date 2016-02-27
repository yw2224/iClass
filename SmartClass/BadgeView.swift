//
//  BadgeView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit


class BadgeView: UIButton {
    
    private struct Constants {
        static let MaxBadgeNum = 99
    }
    
    var badgeNum: Int = 0 {
        didSet {
            hidden = badgeNum == 0
            setTitle("\(min(badgeNum, Constants.MaxBadgeNum))", forState: .Normal)
            sizeToFit()
            setNeedsDisplay()
        }
    }
}