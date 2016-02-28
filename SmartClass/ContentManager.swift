//
//  ContentManager.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

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
    
    // UserName, UserID, Token, and Password can identify an unique user
    static var UserName: String? {
        get {
            return try? keychain.getString("name") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "name")
        }
    }
    
    static var UserID: String? {
        get {
            return try? keychain.getString("_id") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "_id")
        }
    }
    
    static var Token: String? {
        get {
            return try? keychain.getString("token") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "token")
        }
    }
    
    static var Password: String? {
        get {
            return try? keychain.getString("password") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "password")
        }
    }
    
    /**
     Note: iOS 9 Security.framework bug! We need to first remove and then set the item instead of 
     update the existing item in the key chain.
     */
    private class func setKeyChainItem(item: String?, forKey key: String) {
        do {
            try keychain.remove(key) // Dealing with iOS 9 Security.framework bug!
            if let string = item {
                try keychain.set(string, key: key)
            }
        } catch let error {
            DDLogError("Key chain save error: \(error)")
        }
    }
    
    /**
     Each method correspond to some kinds of data retrieval operation.
     Basically, we first ask NetworkManager to require data from network, however it fails, we 
     will query the local database, and the callback block will be executed.
     */
    func login(name: String, password: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.login(name, password: password) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Login success")
                    let json = JSON(data)
                    self?.saveConfidential(name, userID: json["_id"].stringValue, token: json["token"].stringValue, password: password)
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
                    self?.saveConfidential(name, userID: json["_id"].stringValue, token: json["token"].stringValue, password: password)
                } else {
                    DDLogInfo("Register failed: \(error)")
                }
                block?(error: error)
            }
        }
    }

    /**
     Retrieve course list
     
     - parameter block: executing after retrieving the data
     - parameter courseList: the course list either from network or core data
     - parameter error: network error
     */
    func courseList(block: ((courseList: [Course], error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.courseList(ContentManager.UserID, token: ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    // network success
                    DDLogInfo("Querying course list success")
                    // 0. update local database
                    CoreDataManager.sharedInstance.deleteAllCourses() // 1. delete the existing ones
                    
                    // 2. parse the json from server, and insert them into local database
                    let json = JSON(data)
                    let courseList = Course.convertWithJSONArray(json["courses"].arrayValue) as! [Course]
                    // 3. execute the block after sorting
                    block?(courseList: courseList.sort{return $0.name < $1.name},
                        error: error)
                } else {
                    // network failed
                    DDLogInfo("Querying course list failed: \(error)")
                    // fetch from core data and execute the block
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

                    let quizList = Quiz.convertWithJSONArray(json["quizzes"].arrayValue) as! [Quiz]
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
                        let json = JSON(data)["signIn"]
                        let enable = json["enable"].boolValue
                        let uuid = json["last", "uuid"].string ?? ""
                        let signinID = json["last", "_id"].string ?? ""
                        let total = json["total"].intValue
                        
                        block?(uuid: uuid, enable: enable,
                            total: total, user: 0,
                            signinID: signinID, error: error)
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
                if error == nil, let   data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying answer list success")
                    CoreDataManager.sharedInstance.deleteAnswers(quizID)
                    
                    let json = JSON(data)
                    let answerList = Answer.convertWithJSONArray(json["details"].arrayValue) as! [Answer]
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
        let array: [[String: AnyObject]] = status.map {
            var element = [String: AnyObject]()
            element["question"] = $0.question_id
            element["originAnswer"] = $0.originAnswer
            return element
        }
        
        NetworkManager.sharedInstance.submitAnswer(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, quizID: quizID, status: array) {
            (data, error) in
            if error == nil, let data = data where JSON(data)["success"].boolValue {
                DDLogInfo("Submit answer success")
                CoreDataManager.sharedInstance.deleteAnswers(quizID)
                
                let json = JSON(data)
                let answerList = Answer.convertWithJSONArray(json["status"].arrayValue) as! [Answer]
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
                    let courseList = Course.convertWithJSONArray(json["courses"].arrayValue) as! [Course]
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
                    let projectList = Project.convertWithJSONArray(json["projects"].arrayValue) as! [Project]
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
                    let creator = Group.convertWithJSONArray(json["creator"].arrayValue) as! [Group]
                    creator.forEach() {
                        $0.project_id = projectID
                        $0.created = true
                    }
                    let members = Group.convertWithJSONArray(json["member"].arrayValue) as! [Group]
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
                    let problemList = Problem.convertWithJSONArray(json["problems"].arrayValue) as! [Problem]
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
                    let teammateList = Teammate.convertWithJSONArray(json["students"].arrayValue) as! [Teammate]
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
        clearConfidential()
        CoreDataManager.sharedInstance.truncateData()
    }
    
    private func saveConfidential(name: String, userID: String, token: String, password: String) {
        if let id = ContentManager.UserID where id != userID {
            truncateData()
        }
        ContentManager.UserName = name
        ContentManager.UserID = userID
        ContentManager.Token = token
        ContentManager.Password = password
    }
    
    private func clearConfidential() {
        ContentManager.UserName = nil
        ContentManager.UserID = nil
        ContentManager.Token = nil
        ContentManager.Password = nil
    }
}
