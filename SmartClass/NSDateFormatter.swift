//
//  NSDateFormatter.swift
//  iBeaconToy
//
//  Created by PengZhao on 16/1/19.
//  Copyright © 2016年 pku. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    class func yearFormatter() -> NSDateFormatter {
        return formatter("yyyy-MM-dd")
    }
    
    class func monthFormmatter() -> NSDateFormatter {
        return formatter("MM-dd")
    }
    
    private func formatter(format: String) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.locale = NSCalendar.currentCalendar().locale
        formatter.dateFormat = format
        return fommatter
    }
}