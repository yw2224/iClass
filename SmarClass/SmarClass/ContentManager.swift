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
                    let json = JSON(data)
                    let courseIDForDelete : [String] = (json["courses"].arrayValue).map() {
                        return $0["course_id"].stringValue
                    }
                    
                    let predicate = NSPredicate(format: "course_id IN %@", courseIDForDelete)
                    Course.MR_deleteAllMatchingPredicate(predicate)
                    
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

    func quizList(courseID: String, block: ((quizList: [Quiz], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quizList(ContentManager.UserId, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying quiz list success")
                    let json = JSON(data)

                    let predicate = NSPredicate(format: "course_id = %@", courseID)
                    Course.MR_deleteAllMatchingPredicate(predicate)

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
    
    func quizContent(quizID: String, block: ((quizContent: [Question], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quizContent(ContentManager.UserId, token: ContentManager.Token, quizID: quizID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying question content success")
                    CoreDataManager.sharedInstance.deleteQuestions(quizID)
                    
                    let json = JSON(data)
                    let quizContent = Question.objectFromJSONArray(json["questions"].arrayValue) as! [Question]
                    for question in quizContent {
                        question.quiz_id = quizID
                    }
                    block?(quizContent: quizContent, error: error)
                } else {
                    DDLogInfo("Querying question content failed: \(error)")
                    block?(quizContent: CoreDataManager.sharedInstance.quizContent(quizID),
                        error: error)
                }
            }
        }
    }

    func signinInfo(courseID: String, block: ((uuid: String, enable: Bool, total: Int,
        user: Int, signinID: String, error: NetworkErrorType?) -> Void)?) {
            NetworkManager.sharedInstance.signinInfo(ContentManager.UserId, token: ContentManager.Token, courseID: courseID) {
                (data, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil, let data = data where JSON(data)["success"].boolValue {
                        DDLogInfo("Querying sign info success")
                        let json = JSON(data)
                        block?(uuid: json["uuid"].stringValue, enable: json["enable"].boolValue,
                            total: json["total"].intValue, user: json["user"].intValue,
                            signinID: json["signin_id"].stringValue, error: error)
                    } else {
                        DDLogInfo("Querying sign info failed: \(error)")
                        block?(uuid: "", enable: false, total: 0, user: 0, signinID: "", error: error)
                    }
                }
            }
    }
    
    func originAnswer(courseID: String, quizID: String, block: ((answerList: [Answer], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.originAnswer(ContentManager.UserId, token: ContentManager.Token, courseID: courseID, quizID: quizID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying answer list success")
                    CoreDataManager.sharedInstance.deleteAnswers(quizID)
                    
                    let json = JSON(data)
                    let answerList = Answer.objectFromJSONArray(json["status"].arrayValue) as! [Answer]
                    for answer in answerList {
                        answer.quiz_id = quizID
                    }
                    block?(answerList: answerList, error: error)
                } else {
                    DDLogInfo("Querying answer list failed: \(error)")
                    block?(answerList: CoreDataManager.sharedInstance.answerList(quizID),
                        error: error)
                }
            }
        }
    }
    
    func submitAnswer(courseID: String, quizID: String, status: [AnswerJSON], block: ((answerList: [Answer], error: NetworkErrorType?) -> Void)?) {
        let array: [String] = status.map() {
            let element = JSON([
                "question_id": $0.question_id,
                "originAnswer": JSON($0.originAnswer).description
            ])
            return element.description
        }
        
        NetworkManager.sharedInstance.submitAnswer(ContentManager.UserId, token: ContentManager.Token, courseID: courseID, quizID: quizID, status: JSON(array).description) {
            (data, error) in
            if error == nil, let data = data where JSON(data)["success"].boolValue {
                DDLogInfo("Submit answer success")
                CoreDataManager.sharedInstance.deleteAnswers(quizID)
                
                let json = JSON(data)
                let answerList = Answer.objectFromJSONArray(json["status"].arrayValue) as! [Answer]
                for answer in answerList {
                    answer.quiz_id = quizID
                }
                block?(answerList: answerList, error: error)
            } else {
                DDLogInfo("Submit answer failed")
                block?(answerList: CoreDataManager.sharedInstance.answerList(quizID),
                    error: error)
            }
        }
    }
    
    func submitSignIn(courseID: String, signinID: String, uuid: String, deviceID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.submitSignIn(ContentManager.UserId, token: ContentManager.Token,
            courseID: courseID, signinID: signinID, uuid: uuid, deviceID: deviceID) {
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
    
    func attendCourse(courseID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.attendCourse(ContentManager.UserId, token: ContentManager.Token, courseID: courseID) {
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
    
    func allCourse(block: ((courseList: [Course], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.allCourse(ContentManager.UserId, token: ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying all course success")
                    Course.MR_truncateAll()
                    
                    let json = JSON(data)
                    block?(courseList:
                        Course.objectFromJSONArray(json["courses"].arrayValue) as! [Course],
                        error: error)
                } else {
                    DDLogInfo("Querying all course failed: \(error)")
                    block?(courseList: CoreDataManager.sharedInstance.courseList(),
                        error: error)
                }
            }
        }
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
