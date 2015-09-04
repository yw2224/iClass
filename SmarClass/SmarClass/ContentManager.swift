//
//  ContentManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import SwiftyJSON
import KeychainAccess
import CocoaLumberjack

typealias NetworkBlock = (Bool, AnyObject?, (message: String, statusCode: Int)) -> Void


class ContentManager: NSObject {
    static let sharedInstance = ContentManager()
    
    private static let keychain: Keychain = {
        let bundle = NSBundle.mainBundle()
        let bundleIdentifier = bundle.bundleIdentifier!
        return Keychain(service: bundleIdentifier)
    }()
    
    private static var User_id: String? {
        get {
            return keychain.get("_id")
        }
        set {
            if let user_id = newValue {
                setKeyChainItem(user_id, forKey: "_id")
            }
        }
    }
    
    private static var Token: String? {
        get {
            return keychain.get("token")
        }
        set {
            if let token = newValue {
                setKeyChainItem(token, forKey: "token")
            }
        }
    }
    
    private static var Password: String? {
        get {
            return keychain.get("password")
        }
        set {
            if let password = newValue {
                setKeyChainItem(password, forKey: "password")
            }
        }
    }
    
    private class func setKeyChainItem(item: String, forKey key: String) -> Bool {
        if let error = keychain.set(item, key: key) {
            DDLogError("Key chain save error: \(error)")
            return false
        }
        return true
    }
    
    func login(name: String, password: String, block: ((success: Bool, message: String) -> Void)?) {
        NetworkManager.sharedInstance.login(name, password: password) {
            (success, data, response) in
            Log.debugLog()
            
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if success { // network successes
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    if successValue {
                        DDLogInfo("Saving users")
                        self?.saveConfidential(json["_id"].stringValue, token: json["token"].stringValue, password: password)
                    }
                    block?(success: successValue, message: successValue ? "Login success" : json["message"].stringValue)
                } else {
                    block?(success: false, message: response.message)
                }
            }
        }
    }
    
    func register(name: String, realName: String, password: String, block: ((success: Bool, message: String) -> Void)?) {
        
        NetworkManager.sharedInstance.register(name, realName: realName, password: password) { (success, data, response) in
            Log.debugLog()
            
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if success { // network successes
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    if successValue {
                        DDLogInfo("Saving users")
                        self?.saveConfidential(json["_id"].stringValue, token: json["token"].stringValue, password: password)
                    }
                    block?(success: successValue, message: successValue ? "Register success" : json["message"].stringValue)
                } else {
                    block?(success: false, message: response.message)
                }
            }
        }
    }
    
    func courseList(block: ((success: Bool, courseList: [Course], message: String) -> Void)?) {
        NetworkManager.sharedInstance.courseList(ContentManager.User_id, token: ContentManager.Token) {
            (success, data, message) in
            Log.debugLog()
            
            if success { // network success
                dispatch_async(dispatch_get_main_queue()) {
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    var courseList: [Course] = {
                        if successValue {
                            DDLogInfo("Querying course list")
                            Course.MR_truncateAll()
                            return Course.objectFromJSONArray(json["courses"].arrayValue) as! [Course]
                        }
                        return []
                    }()
                    block?(success: successValue, courseList: courseList, message: successValue ? "Querying course list success" : json["message"].stringValue)
                }
            } else {
                // MARK: Retrieve from core data, network error
                dispatch_async(dispatch_get_main_queue()) {
                    let courseList = CoreDataManager.sharedInstance.courseList()
                    block?(success: true, courseList: courseList, message: "Cahced course list")
                }
            }
        }
    }
    
    func quizList(course_id: String, block: ((success: Bool, quizList: [Quiz], message: String) -> Void)?) {
        NetworkManager.sharedInstance.quizList(ContentManager.User_id, token: ContentManager.Token, course_id: course_id) {
            (success, data, message) in
            Log.debugLog()
            
            if success { // network success
                dispatch_async(dispatch_get_main_queue()) {
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    var quizList: [Quiz] = {
                        if successValue {
                            DDLogInfo("Querying quiz list")
                            Quiz.MR_truncateAll()
                            return Quiz.objectFromJSONArray(json["quizzes"].arrayValue) as! [Quiz]
                        }
                        return []
                    }()
                    block?(success: successValue, quizList: quizList, message: successValue ? "Querying quiz list success" : json["message"].stringValue)
                }
            } else {
                // MARK: Retrieve from core data, network error
                dispatch_async(dispatch_get_main_queue()) {
                    let quizList = CoreDataManager.sharedInstance.quizList()
                    block?(success: true, quizList: quizList, message: "Cahced quiz list")
                }
            }
        }
    }
    
    private func saveConfidential(user_id: String, token: String, password: String) {
        if let _id = ContentManager.User_id {
            if _id != user_id {
                cleanUpCoreData()
            }
        }
        ContentManager.User_id = user_id
        ContentManager.Token = token
        ContentManager.Password = password
    }
    
    func cleanUpCoreData() {
        
    }
}
