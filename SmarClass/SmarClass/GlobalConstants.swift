//
//  GlobalConstants.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import ChameleonFramework

struct GlobalConstants {
    static var DarkRed = UIColor(red: 238.0 / 255.0, green: 37.0 / 255.0, blue: 44.0 / 255.0, alpha: 1.0)
    static var FlatDarkRed = UIColor(flatVersionOf: GlobalConstants.DarkRed)
    static var RefreshControlColor = UIColor(red: 247.0 / 255.0, green: 115.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    static var BarTintColor = UIColor(red: 246.0 / 255.0, green: 46.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
    static var SplashPagesBackgroundColor = [
        GradientColor(.TopToBottom, UIScreen.mainScreen().bounds, [FlatSand(), FlatRed()]),
        GradientColor(.TopToBottom, UIScreen.mainScreen().bounds, [FlatPowderBlue(), FlatWhite()]),
        GradientColor(.TopToBottom, UIScreen.mainScreen().bounds, [FlatOrange(), FlatSand()]),
        GradientColor(.LeftToRight, UIScreen.mainScreen().bounds, [FlatWatermelon(), FlatPowderBlue()]),
    ]
    static var EmptyTitleTintColor = UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 236.0 / 255.0, alpha: 1.0)
    static let HomePageLinks = [
        "http://net.pku.edu.cn",
        "http://net.pku.edu.cn",
        "http://net.pku.edu.cn",
        "http://www.pixiv.net/member.php?id=4007606",
        "http://net.pku.edu.cn"
    ]
}
