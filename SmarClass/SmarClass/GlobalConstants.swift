//
//  GlobalConstants.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import ChameleonFramework

/**
 *  Global constants
 *  Note: We may need to extend it for night mode supporting.
 */
struct GlobalConstants {
    
    /// Navigation bar's foreground color
    static var BarTintColor = UIColor(red: 246.0 / 255.0, green: 46.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
    
    /// Splash screens' background gradient color
    static var SplashPagesBackgroundColor = [
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatSandColor(), UIColor.flatRedColor()]),
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatPowderBlueColor(), UIColor.flatWhiteColor()]),
        UIColor.init(gradientStyle: .TopToBottom, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatOrangeColor(), UIColor.flatSandColor()]),
        UIColor.init(gradientStyle: .LeftToRight, withFrame: UIScreen.mainScreen().bounds, andColors: [UIColor.flatWatermelonColor(), UIColor.flatPowderBlueColor()])
    ]
    
    /// DZNEmptyDataSet title's foreground color
    static var EmptyTitleTintColor = UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 236.0 / 255.0, alpha: 1.0)
    
    /// Colors indicating whether the question is answered correctly/wrongly
    static var QuestionCorrectTableViewTitleColor = UIColor(red: 228.0 / 255.0, green: 250.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    static var QuestionWrongTableViewTitleColor = UIColor(red: 246.0 / 255.0, green: 225.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    
    /// Developers' homepage links in 'About us'
    static let HomePageLinks = [
        "http://net.pku.edu.cn",
        "https://www.facebook.com/profile.php?id=100008570011089", // zp
        "http://net.pku.edu.cn",
        "http://www.pixiv.net/member.php?id=4007606",  // cx
        "http://net.pku.edu.cn/mobile"
    ]
    
    /// Error propmts for each case
    /// Note: We may refer to it later as localization
    static let InputFormatErrorPrompt         = "格式有误，请检查您的输入"
    static let PasswordWrongPrompt            = "您的用户名或密码有误"
    static let DuplicateUserName              = "此用户名已被注册，请重新输入"
    static let UserTokenExpiredErrorPrompt    = "会话过期，请重新登录"
    static let AnswerInconsistencyErrorPrompt = "提交失败，您尚未完成任何题目"
    static let AttendingCoursePrompt          = "选课中，请稍候"
    static let SubmittingAnswerPrompt         = "提交中，请稍候"
    static let InvitingGroupPropmt            = "组队中，请稍候"
    static let LoginPrompt                    = "登录中，请稍候"
    static let LoginOrRegisterErrorPrompt        = GlobalConstants.NetworkErrorPrompt("登录/注册失败")
    static let DataInconsistentErrorPrompt       = GlobalConstants.NetworkErrorPrompt("请刷新重试")
    static let CourseListRetrieveErrorPrompt     = GlobalConstants.NetworkErrorPrompt("获取课程列表失败")
    static let SignInRetrieveErrorPrompt         = GlobalConstants.NetworkErrorPrompt("获取签到信息失败")
    static let QuizListRetrieveErrorPrompt       = GlobalConstants.NetworkErrorPrompt("获取测试列表失败")
    static let QuizContentRetrieveErrorPrompt    = GlobalConstants.NetworkErrorPrompt("获取题目失败")
    static let OriginAnswerRetrieveErrorPrompt   = GlobalConstants.NetworkErrorPrompt("获取原始答案失败")
    static let SubmitAnswerErrorPrompt           = GlobalConstants.NetworkErrorPrompt("提交答案失败")
    static let SubmitSigninErrorPrompt           = GlobalConstants.NetworkErrorPrompt("签到失败")
    static let AttendCourseErrorPrompt           = GlobalConstants.NetworkErrorPrompt("选课失败")
    static let ProjectListRetrieveErrorPrompt    = GlobalConstants.NetworkErrorPrompt("获取项目列表失败")
    static let GroupListRetrieveErrorPrompt      = GlobalConstants.NetworkErrorPrompt("获取小组邀请失败")
    static let ProblemListRetrieveErrorPrompt    = GlobalConstants.NetworkErrorPrompt("获取题目失败")
    static let GroupInvitionRetrieveErrorPrompt  = GlobalConstants.NetworkErrorPrompt("小组邀请失败")
    static let GroupOperationRetrieveErrorPrompt = GlobalConstants.NetworkErrorPrompt("小组操作失败")
    static let ServerErrorPrompt                 = GlobalConstants.NetworkErrorPrompt("请稍后重试")
    static let RetrieveErrorPrompt               = GlobalConstants.NetworkErrorPrompt("请检查您的网络设置")
    static func NetworkErrorPrompt(prompt: String) -> String {
        return "网络错误，\(prompt)"
    }
}