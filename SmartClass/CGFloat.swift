//
//  CGFloat.swift
//  iBeaconToy
//
//  Created by PengZhao on 15/12/29.
//  Copyright © 2015年 pku. All rights reserved.
//

import Foundation

extension CGFloat {
    
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
    
}