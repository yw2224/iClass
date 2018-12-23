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
    
    static var realName: String? {
        get {
            return try? keychain.getString("realName") ?? ""
        }
        set {
            setKeyChainItem(newValue, forKey: "realName")
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
                    self?.saveConfidential(name, userID: json["_id"].stringValue, token: json["token"].stringValue, password: password,realName: ContentManager.realName!)
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
                    self?.saveConfidential(name, userID: json["_id"].stringValue, token: json["token"].stringValue, password: password,realName: realName)
                } else {
                    DDLogInfo("Register failed: \(error)")
                }
                block?(error: error)
            }
        }
    }
    
    
    func studentinfo(userID: String?,block:((userInfoList: [User],error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.studentInfo(ContentManager.UserID,token:ContentManager.Token) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("student info list success:\(data)")
                    let json = JSON(data)
                    self.saveConfidential(json["name"].stringValue, userID: json["_id"].stringValue, token: ContentManager.Token!, password:ContentManager.Password!,realName: json["realName"].stringValue)
                    
                } else {
                    DDLogInfo("student info list failed: \(error)")
                    
                }
                
            }
        }
    }
    /*
    func showGroup(groupID: String?, block:((myGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.showGroup(ContentManager.UserID, token: ContentManager.Token, groupID: groupID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("show group success:\(data)")
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(myGroup: json, error: error)
                    
                } else {
                    DDLogInfo("show group failed: \(error)")
                    
                    block?(myGroup: "", error: error)
                }
            }
        }
    }*/
    
    
    func showRequest(courseID: String?, block:((myGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.showRequest(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data //where JSON(data)["success"].boolValue
                {
                    DDLogInfo("show request success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(myGroup: json, error: error)
                    
                } else {
                    DDLogInfo("show request failed: \(error)")
                    block?(myGroup: "", error: error)
                }
            }
        }
    }
    
    func showGroup(userID: String?, token: String?, groupID: String?, block:((myGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.showGroup(ContentManager.UserID, token: ContentManager.Token, groupID: groupID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data //where JSON(data)["success"].boolValue
                {
                    DDLogInfo("show group success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(myGroup: json, error: error)
                    
                } else {
                    DDLogInfo("show group failed: \(error)")
                    block?(myGroup: "", error: error)
                }
            }
        }
    }

    
    func applyGroup(groupID: String?, block:((newGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.applyGroup(ContentManager.UserID, token: ContentManager.Token, groupID: groupID, memberName: ContentManager.UserName) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data// where JSON(data)["success"].boolValue
                {
                    DDLogInfo("apply group success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(newGroup: json, error: error)
                    
                } else {
                    DDLogInfo("apply group failed: \(error)")
                    
                    block?(newGroup: "", error: error)
                }
            }
        }
    }

    
    func createGroup(userID: String?, token: String?, courseID: String?, leaderName: String?, groupName: String?, block:((newGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.createGroup(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, leaderName: leaderName, groupName: groupName) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("create group success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(newGroup: json, error: error)
                    
                } else {
                    DDLogInfo("create group failed: \(error)")
                    block?(newGroup: "", error: error)
                }
            }
        }
    }
    
    func newPost(userID: String?, token: String?, name: String?, courseID: String?, title: String?, content: String?, postType: String?, img:String?, block:((newPost: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.newPost(ContentManager.UserID, token: ContentManager.Token, name: name, courseID: courseID, title: title, content: content, postType: postType,img:img) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("post detail success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(newPost: json, error: error)
                    
                } else {
                    DDLogInfo("post detail failed: \(error)")
                    block?(newPost: "", error: error)
                }
            }
        }
    }
    
    func postDetail(userID: String?, token: String?, postID: String?, block:((postDetail: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.postDetail(userID, token: token, postID: postID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("post detail success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(postDetail: json, error: error)
                    
                } else {
                    DDLogInfo("post detail failed: \(error)")
                    block?(postDetail: "", error: error)
                }
            }
        }
    }
    
    func exList(userID: String?, token: String?, courseID: String?, type: String?, page: NSNumber?, block:((exList: [EX], error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.exList(userID, token: token, courseID: courseID, type: type, page: page) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("forum-ex list success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    
                    let exList = EX.convertWithJSON(json["postings"].arrayValue) as! [EX]
                    //print("lessonList:")
                    //print(lessonList)
                    exList.forEach {
                        $0.courseID = courseID
                    }
                    print(CoreDataManager.sharedInstance.exList(courseID!))
                    block?(exList: exList, error: error)
                    
                } else {
                    DDLogInfo("forum-ex list failed: \(error)")
                    block?(exList: CoreDataManager.sharedInstance.exList(courseID!), error: error)
                }
            }
        }
        
    }

    
    func notificationList(userID: String?, token: String?, page: NSNumber?, courseID: String?, block:((notificationList: [Notification], error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.notificationList(userID, token: token, page: page, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("lesson info list success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    
                    let notificationList = Notification.convertWithJSON(json["notifications"].arrayValue) as! [Notification]
                    //print("lessonList:")
                    //print(lessonList)
                    notificationList.forEach {
                        $0.courseID = courseID
                    }
                    print(CoreDataManager.sharedInstance.notificationList(courseID!))
                    block?(notificationList: notificationList, error: error)
                    
                } else {
                    DDLogInfo("lesson info list failed: \(error)")
                    block?(notificationList: CoreDataManager.sharedInstance.notificationList(courseID!), error: error)
                }
            }
        }

    }
    
    func lessonInfo(userID: String?, token: String?, courseID: String?,block:((lessonList: [Lesson], error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.lessonInfo(userID, token: token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("lesson info list success:\(data)")
                    CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    //print("lesson: ")
                    //print(json)
                    let lessonList = Lesson.convertWithJSON(json["lessons"].arrayValue) as! [Lesson]
                    //print("lessonList:")
                    //print(lessonList)
                    lessonList.forEach {
                        $0.courseID = courseID
                    }
                    //print(CoreDataManager.sharedInstance.lessonList(courseID!))
                    block?(lessonList: lessonList.sort{return $0.lessonID?.intValue < $1.lessonID?.intValue}, error: error)
                    print("here:")
                    print(lessonList)
                   // block?(error: error)
                    //self.saveConfidential(json["name"].stringValue, userID: json["_id"].stringValue, token: ContentManager.Token!, password:ContentManager.Password!,realName: json["realName"].stringValue)
                    
                } else {
                    DDLogInfo("lesson info list failed: \(error)")
                    block?(lessonList: CoreDataManager.sharedInstance.lessonList(courseID!), error: error)
                }
            }
        }
    }
    
    func lessonFileInfo(userID: String?, token: String?, courseID: String?, lessonID: String?, lessonName: String?, block:((lessonFileList: [File], error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.lessonFileInfo(userID, token: token, courseID: courseID, lessonID: lessonID, lessonName: lessonName) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("lesson file info list success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonFileList(lessonName!)
                    
                    let json = JSON(data)
                    //print("lessonFile: ")
                    //print(json)
                    let lessonFileList = File.convertWithJSON(json["files"].arrayValue) as! [File]
                    print("lessonFileList:")
                    print(lessonFileList)
                    lessonFileList.forEach {
                        $0.lessonName = lessonName
                    }
                    print("coredata:")
                    print(CoreDataManager.sharedInstance.lessonFileList(lessonName!))
                    block?(lessonFileList: lessonFileList, error: error)
                    
                } else {
                    DDLogInfo("lesson file info list failed: \(error)")
                    //block?(lessonFileList: CoreDataManager.sharedInstance.lessonFileList(lessonName!), error: error)
                }
            }
        }
    }
    
    func userInfo(name: String, password: String, block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.userInfo(ContentManager.UserID, token: ContentManager.Token, name: name, password: password) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Change information success")
                    let json = JSON(data)
                    print(json["name"].stringValue)
                    self?.saveConfidential(json["name"].stringValue, userID: json["_id"].stringValue, token: ContentManager.Token!, password: password,realName: name)
                    
                } else {
                    DDLogInfo("Change information failed: \(error)")
                }
                block?(error: error)
            }
        }
    }//??

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
                    DDLogInfo("Querying quiz list success\(data)")
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
                    let quizContent = Question.convertWithJSONArray(json["questions"].arrayValue) as! [Question]
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
                        DDLogInfo("Querying sign info success\(data)")
                        let json = JSON(data)
                        let total = json["total"].intValue
                        let user = json["user"].intValue
                        let enable = json["enable"].boolValue
                        
                        let uuid = json["uuid"].string ?? ""
                        let signinID = json["signin_id"].string ?? ""
                        
                        block?(uuid: uuid, enable: enable,
                            total: total, user: user,
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
                    DDLogInfo("Querying answer list success:\(data)")
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
            element["question_id"] = $0.question_id
            element["originAnswer"] = $0.originAnswer
            element["score"] = $0.score//??
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
                    if error == nil, let data = data where JSON(data)["success"].boolValue
                    {
                        DDLogInfo("Submit sign in success\(data)")
                    } else {
                        DDLogInfo("Submit sign in failed: \(error)")
                    }
                    block?(error: error)
                }
        }
    }
    
    func attendCourse(courseID: String, userName: String,  block: ((error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.attendCourse(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, userName: userName) {
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
    
    func dealGroup(groupID: String?, courseID: String?, type: String?, memberID: String?, memberName: String?, block:((error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.dealGroup(ContentManager.UserID, token: ContentManager.Token, groupID: groupID, courseID: courseID, type: type, memberID: memberID, memberName: memberName) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data //where JSON(data)["success"].boolValue
                {
                    DDLogInfo("deal group success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(error: error)
                    
                } else {
                    DDLogInfo("deal group failed: \(error)")
                    block?(error: error)
                }
            }
        }
    }
    
    //这个记得改！
    func saveWish(courseID: String, target: [GroupMember], block: ((error: NetworkErrorType?) -> Void)?) {
        let array: [[String: AnyObject]] = target.map {
            var element = [String: AnyObject]()
            element["member_id"] = $0.memberID
            element["member_name"] = $0.memberName
            return element
        }
        
        NetworkManager.sharedInstance.saveWish(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, name: ContentManager.UserName, target: array) {
            (data, error) in
            
            if error == nil, let data = data //where JSON(data)["success"].boolValue
            {
                DDLogInfo("save wish success")
                
                let json = JSON(data)
                
                block?(error: error)
            } else {
                DDLogInfo("save wish failed: \(error)")
                block?(error: error)
            }
        }
    }

    
    //这个记得改！
    func getNoGroup(courseID: String?, block:((noGroup: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.getNoGroup(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data //where JSON(data)["success"].boolValue
                {
                    DDLogInfo("get no group success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(noGroup: json, error: error)
                    
                } else {
                    DDLogInfo("get no group failed: \(error)")
                    block?(noGroup: "", error: error)
                }
            }
        }
    }

    
    func groupQuery(courseID: String, block: ((group: JSON, error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.queryGroup(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying group success")
                    let json = JSON(data)
                    
                    print(json)
                    block?(group: json, error: error)
                    
                } else {
                    DDLogInfo("Querying project list failed: \(error)")
                    block?(group: "", error: error)
                }
            }
        }
    }
    
    func projectList(courseID: String, block: ((groups: JSON, error: NetworkErrorType?) -> Void)?) {
        NetworkManager.sharedInstance.projectList(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("Querying project list success")
                    
                    //CoreDataManager.sharedInstance.deleteProjectList(courseID)
                    
                    let json = JSON(data)
                   /* let projectList = Project.convertWithJSON(json["group"].arrayValue) as! [Project]
                    projectList.forEach {
                        $0.course_id = courseID
                    }*/
                    print(json)
                    block?(groups: json, error: error)
                    //block?(projectList: projectList.sort{return $0.to.compare($1.to) == .OrderedDescending}, error: error)
                } else {
                    DDLogInfo("Querying project list failed: \(error)")
                    block?(groups: "", error: error)
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
    
    
    
    func Replyposting(userID: String?, token: String?, postingID: String?, content: String? ,block:((newReply: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.ReplyPosting(ContentManager.UserID, token: ContentManager.Token, postingID: postingID, content: content) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("reply success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(newReply: json, error: error)
                    
                } else {
                    DDLogInfo("post detail failed: \(error)")
                    block?(newReply: "", error: error)
                }
            }
        }
    }
    
    
    
    func ShowMyLove(userID: String?, token: String?, postuser: String? , courseID: String?, postingID: String?, type: String? ,block:((like: JSON, error: NetworkErrorType?)->Void)?) {
        NetworkManager.sharedInstance.ShowMyLove(ContentManager.UserID, token: ContentManager.Token, postuser:postuser, courseID: courseID, postingID: postingID, type: type) {
            (data, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil, let data = data where JSON(data)["success"].boolValue {
                    DDLogInfo("like success:\(data)")
                    //CoreDataManager.sharedInstance.deleteLessonList(courseID!)
                    
                    let json = JSON(data)
                    print("json here:")
                    print(json)
                    block?(like: json, error: error)
                    
                } else {
                    DDLogInfo("post like failed: \(error)")
                    block?(like: "", error: error)
                }
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
    
    private func saveConfidential(name: String, userID: String, token: String, password: String,realName:String) {
        if let id = ContentManager.UserID where id != userID {
            truncateData()
        }
        ContentManager.UserName = name
        ContentManager.UserID = userID
        ContentManager.Token = token
        ContentManager.Password = password
        ContentManager.realName = realName
    }
    
    private func clearConfidential() {
        ContentManager.UserName = nil
        ContentManager.UserID = nil
        ContentManager.Token = nil
        ContentManager.Password = nil
        ContentManager.realName = nil
    }
}
