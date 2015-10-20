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
    static var FlatDarkRed = GlobalConstants.DarkRed.flatten()
    static var RefreshControlColor = UIColor(red: 247.0 / 255.0, green: 115.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    static var BarTintColor = UIColor(red: 246.0 / 255.0, green: 46.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
    static var SplashPagesBackgroundColor = [
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatSandColor(), UIColor.flatRedColor()]),
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatPowderBlueColor(), UIColor.flatWhiteColor()]),
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatOrangeColor(), UIColor.flatSandColor()]),
        UIColor.init(gradientStyle: .LeftToRight, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatWatermelonColor(), UIColor.flatPowderBlueColor()])
    ]
    static var EmptyTitleTintColor = UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 236.0 / 255.0, alpha: 1.0)
    static var QuestionCorrectTableViewTitleColor = UIColor(red: 228.0 / 255.0, green: 250.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    static var QuestionWrongTableViewTitleColor = UIColor(red: 246.0 / 255.0, green: 225.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    static let HomePageLinks = [
        "http://net.pku.edu.cn",
        "https://www.facebook.com/profile.php?id=100008570011089",
        "http://net.pku.edu.cn",
        "http://www.pixiv.net/member.php?id=4007606",
        "http://net.pku.edu.cn/mobile"
    ]
}

enum GroupStatus: Int {
    case Pending = 0
    case Accept  = 1
    case Decline = 2
}
