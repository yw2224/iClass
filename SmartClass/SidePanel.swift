//
//  SidePanel.swift
//  SmartClass
//
//  Created by PengZhao on 16/2/28.
//  Copyright © 2016年 PKU. All rights reserved.
//

import Foundation

struct SidePanel {
    
    let texts = [
        //            "个人中心", "清理缓存", "夜间模式", "意见反馈",
        "关于", "注销账户"
    ]
    let icons = [
        //            "PersonalCenter", "CleanCache", "NightMode", "Feedback",
        "About", "Logout"
    ]
    let cellID = "SettingsCell"
    
    func count() -> Int {
        assert(texts.count == icons.count)
        return texts.count
    }
    
    func text(x: Int) -> String {
        return texts[x]
    }
    
    func iconName(x: Int) -> String {
        return icons[x]
    }
}