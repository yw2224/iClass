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

class ContentManager: NSObject {
    
    static let sharedInstance = ContentManager()
    
    private static let keychain: Keychain = {
        let bundle = NSBundle.mainBundle()
        let bundleIdentifier = bundle.bundleIdentifier!
        return Keychain(service: bundleIdentifier)
    }()
    
    private static var UserId: String? {
        get {
            return try? keychain.getString("_id") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "_id")
        }
    }
    
    private static var Token: String? {
        get {
            return try? keychain.getString("token") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "token")
        }
    }
    
    private static var Password: String? {
        get {
            return try? keychain.getString("token") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "password")
        }
    }
    
    private class func setKeyChainItem(item: String?, forKey key: String) {
        guard let string = item else { return }
        do {
            try keychain.set(string, key: key)
        } catch let error {
            DDLogError("Key chain save error: \(error)")
        }
    }
    
    func login(name: String, password: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.login(name, password: password) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Login success")
                    let json = JSON(data)
                    self?.saveConfidential(json["_id"].stringValue, token: json["token"].stringValue, password: password)
                } else {
                    DDLogInfo("Login failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func register(name: String, realName: String, password: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.register(name, realName: realName, password: password) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Register success")
                    let json = JSON(data)
                    self?.saveConfidential(json["_id"].stringValue, token: json["token"].stringValue, password: password)
                } else {
                    DDLogInfo("Register failed: \(error)")
                }
                block?(error: error)
            }
        }
    }

    func courseList(block: ((courseList: [Course], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.courseList(ContentManager.UserId, token: ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying course list success")
                    Course.MR_truncateAll()
                    
                    let json = JSON(data)
                    block?(courseList:
                        Course.objectFromJSONArray(json["courses"].arrayValue) as! [Course],
                        error: error)
                } else {
                    DDLogInfo("Querying course list failed: \(error)")
                    block?(courseList: CoreDataManager.sharedInstance.courseList(),
                        error: error)
                }
            }
        }
    }

    func quizList(courseId: String, block: ((quizList: [Quiz], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quizList(ContentManager.UserId, token: ContentManager.Token, courseId: courseId) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying quiz list success")
                    Quiz.MR_truncateAll()
                    
                    let json = JSON(data)
                    let quizList = Quiz.objectFromJSONArray(json["quizzes"].arrayValue) as! [Quiz]
                    for answer in json["answers"].arrayValue {
                        let quizId = answer["quiz_id"].stringValue
                        let correct = answer["total"].intValue
                        // the quiz_id should be unique, so search can be stopped when finding one candidate
                        for quiz in quizList where quiz.quiz_id == quizId {
                            quiz.correct = NSNumber(integer: correct)
                            break
                        }
                    }
                    block?(quizList: quizList, error: error)
                } else {
                    DDLogInfo("Querying quiz list failed: \(error)")
                    block?(quizList: CoreDataManager.sharedInstance.quizList(),
                        error: error)
                }
            }
        }
    }
    
    func quizContent(quizId: String, block: ((quizContent: [Question], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quizContent(ContentManager.UserId, token: ContentManager.Token, quizId: quizId) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying question content success")
                    CoreDataManager.sharedInstance.deleteQuestions(quizId)
                    
                    let json = JSON(data)
                    let quizContent = Question.objectFromJSONArray(json["questions"].arrayValue) as! [Question]
                    for question in quizContent {
                        question.quiz_id = quizId
                    }
                    block?(quizContent: quizContent, error: error)
                } else {
                    DDLogInfo("Querying question content failed: \(error)")
                    block?(quizContent: CoreDataManager.sharedInstance.quizContent(quizId),
                        error: error)
                }
            }
        }
    }

    func signinInfo(courseId: String, block: ((uuid: String, enable: Bool, total: Int,
        user: Int, signinId: String, error: NetworkErrorType?) -> Void)?) {
            NetworkManager.sharedInstance.signinInfo(ContentManager.UserId, token: ContentManager.Token, courseId: courseId) {
                (data, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil, let data = data where JSON(data)["success"].boolValue {
                        DDLogInfo("Querying sign info success")
                        let json = JSON(data)
                        block?(uuid: json["uuid"].stringValue, enable: json["enable"].boolValue,
                            total: json["total"].intValue, user: json["user"].intValue,
                            signinId: json["signin_id"].stringValue, error: error)
                    } else {
                        DDLogInfo("Querying sign info failed: \(error)")
                        block?(uuid: "", enable: false, total: 0, user: 0, signinId: "", error: error)
                    }
                }
            }
    }
    
    func originAnswer(courseId: String, quizId: String, block: ((answerList: [Answer], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.originAnswer(ContentManager.UserId, token: ContentManager.Token, courseId: courseId, quizId: quizId) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying answer list success")
                    CoreDataManager.sharedInstance.deleteAnswers(quizId)
                    
                    let json = JSON(data)
                    let answerList = Answer.objectFromJSONArray(json["status"].arrayValue) as! [Answer]
                    for answer in answerList {
                        answer.quiz_id = quizId
                    }
                    block?(answerList: answerList, error: error)
                } else {
                    DDLogInfo("Querying answer list failed: \(error)")
                    block?(answerList: CoreDataManager.sharedInstance.answerList(quizId),
                        error: error)
                }
            }
        }
    }
    
    func submitAnswer(courseId: String, quizId: String, status: [AnswerJSON], block: ((answerList: [Answer], error: NetworkErrorType?) -> Void)?) {
        var array = [String]()
        for answerJSON in status {
            let element = JSON([
                "question_id": answerJSON.question_id,
                "originAnswer": JSON(answerJSON.originAnswer).description
            ])
            array.append(element.description)
        }
        
        NetworkManager.sharedInstance.submitAnswer(ContentManager.UserId, token: ContentManager.Token, courseId: courseId, quizId: quizId, status: JSON(array).description) {
            (data, error) in
            if error == nil, let data = data where JSON(data)["success"].boolValue {
                DDLogInfo("Submit answer success")
                let json = JSON(data)
                let answerList = Answer.objectFromJSONArray(json["status"].arrayValue) as! [Answer]
                for answer in answerList {
                    answer.quiz_id = quizId
                }
                CoreDataManager.sharedInstance.deleteAnswers(quizId)
                block?(answerList: answerList, error: error)
            } else {
                DDLogInfo("Submit answer failed")
                block?(answerList: CoreDataManager.sharedInstance.answerList(quizId),
                    error: error)
            }
        }
    }
    
    func submitSignIn(courseId: String, signinId: String, uuid: String, deviceId: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.submitSignIn(ContentManager.UserId, token: ContentManager.Token,
            courseId: courseId, signinId: signinId, uuid: uuid, deviceId: deviceId) {
                (data, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil, let data = data where JSON(data)["success"].boolValue {
                        DDLogInfo("Submit sign in success")
                    } else {
                        DDLogInfo("Submit sign in failed: \(error)")
                    }
                    block?(error: error)
                }
        }
    }
    
    func attendCourse(courseId: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.attendCourse(ContentManager.UserId, token: ContentManager.Token, courseId: courseId) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Attend course success")
                } else {
                    DDLogInfo("Attend course failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func allCourse(courseId: String, block: ((courseList: [Course], error: NetworkErrorType?) -> Void)?) {
//        NetworkManager.sharedInstance.allCourse
    }
    
    func cleanUpCoreData() {
        
    }
    
    private func saveConfidential(userId: String, token: String, password: String) {
        if let id = ContentManager.UserId where id != userId {
            cleanUpCoreData()
        }
        ContentManager.UserId = userId
        ContentManager.Token = token
        ContentManager.Password = password
    }
}
