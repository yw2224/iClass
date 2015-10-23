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
    
    // MARK: Singleton
    static let sharedInstance = ContentManager()
    
    // MARK: Key chain
    private static let keychain: Keychain = {
        let bundle = NSBundle.mainBundle()
        let bundleIdentifier = bundle.bundleIdentifier!
        return Keychain(service: bundleIdentifier)
    }()
    
    // UserID, Token, and Password can identify an unique user
    private static var UserID: String? {
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
            try keychain.remove(key)
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
        NetworkManager.sharedInstance.courseList(ContentManager.UserID, token: ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying course list success")
                    CoreDataManager.sharedInstance.deleteAllCourses()
                    
                    let json = JSON(data)
                    let courseList = Course.objectFromJSONArray(json["courses"].arrayValue) as! [Course]
                    block?(courseList: courseList.sort{return $0.name < $1.name},
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
        NetworkManager.sharedInstance.quizList(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying quiz list success")
                    let json = JSON(data)
                    let predicate = NSPredicate(format: "course_id = %@", courseID)
                    CoreDataManager.sharedInstance.deleteQuizWithinPredicate(predicate)

                    let quizList = Quiz.objectFromJSONArray(json["quizzes"].arrayValue) as! [Quiz]
                    for answer in json["answers"].arrayValue {
                        let quizID = answer["quiz_id"].stringValue
                        let correct = answer["total"].intValue
                        // the quiz_id should be unique, so search can be stopped when finding one candidate
                        for quiz in quizList where quiz.quiz_id == quizID {
                            quiz.correct = NSNumber(integer: correct)
                            break
                        }
                    }
                    block?(quizList: quizList.sort {return $0.to.compare($1.to) == .OrderedDescending}, error: error)
                } else {
                    DDLogInfo("Querying quiz list failed: \(error)")
                    block?(quizList: CoreDataManager.sharedInstance.quizList(courseID),
                        error: error)
                }
            }
        }
    }
    
    func quizContent(quizID: String, block: ((quizContent: [Question], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quizContent(ContentManager.UserID, token: ContentManager.Token, quizID: quizID) {
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
        user: Int, signinID: String?, error: NetworkErrorType?) -> Void)?) {
            NetworkManager.sharedInstance.signinInfo(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
                (data, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if error == nil, let data = data where JSON(data)["success"].boolValue {
                        DDLogInfo("Querying sign info success")
                        let json = JSON(data)
                        block?(uuid: json["uuid"].stringValue, enable: json["enable"].boolValue,
                            total: json["total"].intValue, user: json["user"].intValue,
                            signinID: json["signin_id"].string, error: error)
                    } else {
                        DDLogInfo("Querying sign info failed: \(error)")
                        block?(uuid: "", enable: false, total: 0, user: 0, signinID: nil, error: error)
                    }
                }
            }
    }
    
    func originAnswer(courseID: String, quizID: String, block: ((answerList: [Answer], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.originAnswer(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, quizID: quizID) {
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
        let array: [String] = status.map {
            let element = JSON([
                "question_id": $0.question_id,
                "originAnswer": JSON($0.originAnswer).description
            ])
            return element.description
        }
        
        NetworkManager.sharedInstance.submitAnswer(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, quizID: quizID, status: JSON(array).description) {
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
                DDLogInfo("Submit answer failed: \(error)")
                block?(answerList: CoreDataManager.sharedInstance.answerList(quizID),
                    error: error)
            }
        }
    }
    
    func submitSignIn(courseID: String, signinID: String, uuid: String, deviceID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.submitSignIn(ContentManager.UserID, token: ContentManager.Token,
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
        NetworkManager.sharedInstance.attendCourse(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
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
    
    func quitCourse(courseID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.quitCourse(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Quit course success")
                } else {
                    DDLogInfo("Quit course failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func allCourse(block: ((courseList: [Course], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.allCourse(ContentManager.UserID, token: ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying all course success")
                    CoreDataManager.sharedInstance.deleteAllCourses()
                    
                    let json = JSON(data)
                    let courseList = Course.objectFromJSONArray(json["courses"].arrayValue) as! [Course]
                    block?(courseList: courseList.sort{return $0.name < $1.name},
                        error: error)
                } else {
                    DDLogInfo("Querying all course failed: \(error)")
                    block?(courseList: [], error: error)
                }
            }
        }
    }
    
    func projectList(courseID: String, block: ((projectList: [Project], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.projectList(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying project list success")
                    
                    CoreDataManager.sharedInstance.deleteProjectList(courseID)
                    
                    let json = JSON(data)
                    let projectList = Project.objectFromJSONArray(json["projects"].arrayValue) as! [Project]
                    projectList.forEach {
                        $0.course_id = courseID
                    }
                    block?(projectList: projectList.sort{return $0.to.compare($1.to) == .OrderedDescending}, error: error)
                } else {
                    DDLogInfo("Querying project list failed: \(error)")
                    block?(projectList: CoreDataManager.sharedInstance.projectList(courseID), error: error)
                }
            }
        }
    }
   
    func groupList(projectID: String, block: ((groupID: String?, creatorList: [Group], memberList: [Group], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.groupList(ContentManager.UserID, token: ContentManager.Token, projectID: projectID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying group list success")
                    CoreDataManager.sharedInstance.deleteGroupList(projectID)
                    
                    let json = JSON(data)
                    let groupID = json["group_id"].string
                    let creator = Group.objectFromJSONArray(json["creator"].arrayValue) as! [Group]
                    creator.forEach() {
                        $0.project_id = projectID
                        $0.created = true
                    }
                    let members = Group.objectFromJSONArray(json["member"].arrayValue) as! [Group]
                    members.forEach() {
                        $0.project_id = projectID
                        $0.created = false
                    }
                    
                    block?(groupID: groupID, creatorList: creator.sort{return $0.name < $1.name}, memberList: members.sort{return $0.name < $1.name}, error: error)
                } else {
                    DDLogInfo("Querying project list failed: \(error)")
                    block?(groupID: nil,
                        creatorList: CoreDataManager.sharedInstance.creatorList(projectID),
                        memberList: CoreDataManager.sharedInstance.memberList(projectID),
                        error: error)
                }
            }
        }
    }
    
    func problemList(projectID: String, block: ((problemList: [Problem], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.problemList(ContentManager.UserID, token: ContentManager.Token, projectID: projectID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying problem list success")
                    CoreDataManager.sharedInstance.deleteProblemList(projectID)
                    
                    let json = JSON(data)
                    let problemList = Problem.objectFromJSONArray(json["problems"].arrayValue) as! [Problem]
                    problemList.forEach {
                        $0.project_id = projectID
                    }
                    block?(problemList: problemList.sort{return $0.name < $1.name}, error: error)
                } else {
                    DDLogInfo("Querying probem list failed: \(error)")
                    block?(problemList: CoreDataManager.sharedInstance.problemList(projectID), error: error)
                }
            }
        }
    }
    
    func teammateList(courseID: String, projectID: String, block: ((teammateList: [Teammate], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.teammateList(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, projectID: projectID){
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying teammate list success")
                    CoreDataManager.sharedInstance.deleteTeammateList(courseID)
                    
                    let json = JSON(data)
                    let teammateList = Teammate.objectFromJSONArray(json["students"].arrayValue) as! [Teammate]
                    teammateList.forEach {
                        $0.course_id = courseID
                    }
                    block?(teammateList: teammateList.sort{return $0.name < $1.name}, error: error)
                } else {
                    DDLogInfo("Querying teammate list failed: \(error)")
                    block?(teammateList: CoreDataManager.sharedInstance.teammateList(courseID), error: error)
                }
            }
        }
    }
    
    func groupInvite(projectID: String, problemID: String, members: [String], block: ((error: NetworkErrorType?) -> Void)?) {
        let json = JSON(members)
        
        NetworkManager.sharedInstance.groupInvite(ContentManager.UserID, token: ContentManager.Token, projectID: projectID, problemID: problemID, members: json.description) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Group invite success")
                } else {
                    DDLogInfo("Group invite failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func groupAccept(projectID: String, groupID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.groupAccept(ContentManager.UserID, token: ContentManager.Token, projectID: projectID, groupID: groupID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Group accept success")
                } else {
                    DDLogInfo("Group accept failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func groupDecline(projectID: String, groupID: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.groupDecline(ContentManager.UserID, token: ContentManager.Token, projectID: projectID, groupID: groupID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Group decline success")
                } else {
                    DDLogInfo("Group decline failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    func truncateData() {
        CoreDataManager.sharedInstance.truncateData()
    }
    
    private func saveConfidential(userID: String, token: String, password: String) {
        if let id = ContentManager.UserID where id != userID {
            truncateData()
        }
        ContentManager.UserID = userID
        ContentManager.Token = token
        ContentManager.Password = password
    }
}
