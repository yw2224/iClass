//
//  Log.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CocoaLumberjack
import ChameleonFramework

class Log: NSObject {
    static func config() {
        DDLog.addLogger(DDASLLogger.sharedInstance())
        
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatRedColor(), backgroundColor: nil, forFlag: DDLogFlag.Error)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatOrangeColor(), backgroundColor: nil, forFlag: DDLogFlag.Warning)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatMintColor(), backgroundColor: nil, forFlag: DDLogFlag.Debug)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatPowderBlueColorDark(), backgroundColor: nil, forFlag: DDLogFlag.Verbose)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.flatLimeColor(), backgroundColor: nil, forFlag: DDLogFlag.Info)
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        DDLog.addLogger(fileLogger)
    }
    
    static func debogLog(message:String, filePath : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__){
        let fileName = filePath.lastPathComponent
        DDLogDebug("\(fileName) \(functionName) [Line \(line)]: \(message)")
    }
    
    static func debogLog(filePath : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__){
        let fileName = filePath.lastPathComponent
        DDLogDebug("\(fileName) \(functionName) [Line \(line)]")
    }

}