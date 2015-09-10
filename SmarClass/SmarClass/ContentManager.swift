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
            (success, data, response) in
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
                    block?(success: successValue, courseList: courseList, message: successValue ? "Querying course list success" : response.message)
                }
            } else {
                // MARK: Retrieve from core data, network error
                dispatch_async(dispatch_get_main_queue()) {
                    let courseList = CoreDataManager.sharedInstance.courseList()
                    block?(success: false, courseList: courseList, message: "Cahced course list")
                }
            }
        }
    }
    
    func quizList(course_id: String, block: ((success: Bool, quizList: [Quiz], message: String) -> Void)?) {        
        NetworkManager.sharedInstance.quizList(ContentManager.User_id, token: ContentManager.Token, course_id: course_id) {
            (success, data, response) in
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
                    for answer in json["answers"].arrayValue {
                        var quiz_id = answer["quiz_id"].stringValue
                        var correct = answer["total"].intValue
                        for quiz in quizList {
                            if quiz.quiz_id == quiz_id {
                                quiz.correct = NSNumber(integer: correct)
                            }
                        }
                    }
                    block?(success: successValue, quizList: quizList, message: successValue ? "Querying quiz list success" : response.message)
                }
            } else {
                // MARK: Retrieve from core data, network error
                dispatch_async(dispatch_get_main_queue()) {
                    let quizList = CoreDataManager.sharedInstance.quizList()
                    block?(success: false, quizList: quizList, message: "Cahced quiz list")
                }
            }
        }
    }
    
    func quizContent(quiz_id: String, block: ((success: Bool, quizContent: [Question], message: String) -> Void)?) {
        NetworkManager.sharedInstance.quizContent(ContentManager.User_id, token: ContentManager.Token, quiz_id: quiz_id) {
            (success, data, response) in
            Log.debugLog()
            
            if success { // network success
                dispatch_async(dispatch_get_main_queue()) {
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    var quizContent: [Question] = {
                        if successValue {
                            DDLogInfo("Querying question list")
                            CoreDataManager.sharedInstance.deleteQuestions(quiz_id)
                            let quizContent = Question.objectFromJSONArray(json["questions"].arrayValue) as! [Question]
                            for question in quizContent {
                                question.quiz_id = quiz_id
                            }
                            return quizContent
                        }
                        return []
                    }()
                    block?(success: successValue, quizContent: quizContent, message: successValue ? "Querying question list success" : response.message)
                }
            } else {
                // MARK: Retrieve from core data, network error
                dispatch_async(dispatch_get_main_queue()) {
                    let quizContent = CoreDataManager.sharedInstance.quizContent(quiz_id)
                    block?(success: false, quizContent: quizContent, message: "Cahced question list")
                }
            }
        }
    }
    
    func signinInfo(course_id: String, block: ((success: Bool,
        uuid: String,
        enable: Bool,
        total: Int,
        user: Int,
        signin_id: String,
        message: String) -> Void)?) {
            NetworkManager.sharedInstance.signinInfo(ContentManager.User_id, token: ContentManager.Token, course_id: course_id) {
                (success, data, response) in
                Log.debugLog()
                
                if success { // network success
                    dispatch_async(dispatch_get_main_queue()) {
                        let json = JSON(data!)
                        let successValue = json["success"].boolValue
                        block?(success: successValue,
                            uuid: json["uuid"].string ?? "",
                            enable: json["enable"].bool ?? false,
                            total: json["total"].int ?? 0,
                            user: json["user"].int ?? 0,
                            signin_id: json["signin_id"].string ?? "",
                            message: successValue ? "Querying signin info success" : response.message)

                    }
                } else {
                    // MARK: Network error
                    dispatch_async(dispatch_get_main_queue()) {
                        block?(success: false,
                            uuid: "",
                            enable: false,
                            total: 0,
                            user: 0,
                            signin_id: "",
                            message: "Network error")
                    }
                }
            }
    }
    
    func originAnswer(quiz_id: String, block: ((success: Bool, answerList: [Answer], message: String) -> Void)?) {
        NetworkManager.sharedInstance.originAnswer(ContentManager.User_id, token: ContentManager.Token, quiz_id: quiz_id) {
            (success, data, response) in
            Log.debugLog()
            
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let json = JSON(data!)
                    let successValue = json["success"].boolValue
                    var answerList: [Answer] = {
                        if successValue {
                            DDLogInfo("Querying answer list")
                            CoreDataManager.sharedInstance.deleteAnswers(quiz_id)
                            let answerList = Answer.objectFromJSONArray(json["status"].arrayValue) as! [Answer]
                            for answer in answerList {
                                answer.quiz_id = quiz_id
                            }
                            return answerList
                        }
                        return []
                    }()
                    block?(success: successValue, answerList: answerList, message: successValue ? "Querying answer list success" : response.message)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let answerList = CoreDataManager.sharedInstance.answerList(quiz_id)
                    block?(success: false, answerList: answerList, message: "Cahced answer list")
                }
            }
        }
    }
    
    func cleanUpCoreData() {
        
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
}
