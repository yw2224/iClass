//
//  Log.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CocoaLumberjack

class Log: NSObject {
    static func config() {
        DDLog.addLogger(DDASLLogger.sharedInstance())
        
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatRedColor(), backgroundColor: nil, forFlag: .Error)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatOrangeColor(), backgroundColor: nil, forFlag: .Warning)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatMintColor(), backgroundColor: nil, forFlag: .Debug)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatPowderBlueColorDark(), backgroundColor: nil, forFlag: .Verbose)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatLimeColor(), backgroundColor: nil, forFlag: .Info)
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        DDLog.addLogger(fileLogger)
    }
    
//    static func debugLog(message: String, filePath : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__){
//        DDLogDebug(message)
//    }
//    
    static func debugLog(filePath : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__){
        let fileName = filePath.lastPathComponent
        DDLogDebug("\(fileName) \(functionName) [Line \(line)]")
    }

}