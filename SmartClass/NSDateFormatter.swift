//
//  NSDateFormatter.swift
//  iBeaconToy
//
//  Created by PengZhao on 16/1/19.
//  Copyright © 2016年 pku. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    func yearFormatter() -> NSDateFormatter {
        return defaultFormatter("yyyy-MM-dd")
    }
    
    func monthFormmatter() -> NSDateFormatter {
        return defaultFormatter("MM-dd")
    }
    
    private func defaultFormatter(format: String) -> NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = NSCalendar.currentCalendar().locale
        f.dateFormat = format
        return f
    }
}