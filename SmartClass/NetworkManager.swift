//
//  NetworkManager.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// NetworkCallbackBlock consists the data and an optional network error type for block execution
typealias NetworkCallbackBlock = (AnyObject?, NetworkErrorType?) -> Void

enum NetworkErrorType: ErrorType, CustomStringConvertible {
    
    case NetworkUnreachable(String) // Timeout or Unreachable
    case NetworkUnauthenticated(String) // 401 or 403
    case NetworkServerError(String) // 5XX
    case NetworkForbiddenAccess(String) // 400 or 404
    case NetworkWrongParameter(String) // 422
    
    var description: String {
        get {
            switch self {
            case .NetworkUnreachable(let message):
                return "NetworkUnreachable - \(message)"
            case .NetworkUnauthenticated(let message):
                return "NetworkUnauthenticated - \(message)"
            case .NetworkServerError(let message):
                return "NetworkServerError - \(message)"
            case .NetworkForbiddenAccess(let message):
                return "NetworkForbiddenAccess - \(message)"
            case .NetworkWrongParameter(let message):
                return "NetworkWrongParameter - \(message)"
            }
        }
    }
}

class NetworkManager: NSObject {
    
    // MARK: Singleton
    static let sharedInstance = NetworkManager()

    /**
     *  Unique key for each network request for caching each request
     */
    private struct Constants {
        static let BadRequestStatusCode = 400
        static let UnauthorizedStatusCode = 401
        static let ForbiddenStatusCode = 403
        static let NotFoundStatusCode = 404
        
        static let LoginKey        = "Login"
        static let RegisterKey     = "Register"
        static let UserCourseKey   = "User's Course"
        static let QuizListKey     = "Quiz List"
        static let QuizContentKey  = "Quiz Content"
        static let SigninInfoKey   = "Signin Info"
        static let OriginAnswerKey = "Original Answer"
        static let SubmitAnswerKey = "Submit Answer"
        static let SubmitSignInKey = "Submit SignIn"
        static let AttendCourseKey = "Attend Course"
        static let QuitCourseKey   = "Quit Course"
        static let AllCourseKey    = "All Course"
        static let ProjectListKey  = "Project List"
        static let GroupListKey    = "Group List"
        static let ProblemListKey  = "Problem List"
        static let TeammateListKey = "Teammate List"
        static let GroupInviteKey  = "Group Invite"
        static let GroupAcceptKey  = "Group Accept"
        static let GroupDeclineKey = "Group Decline"
    }
    
    // Default network manager, timeout set to 10s
    private static let Manager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10.0
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }()
    
    /**
     Caching dictionary
     Each network request is served as a key-value pair in the dictionary. No duplicate request would be executed until the previosus one (sharing with the same key) finished.
     */
    private static var PendingOpDict = [String : (Request, NSDate)]()
    
    /**
     Execute the network request
     
     - parameter key:      unique string in caching dictionary
     - parameter request:  request (or value) in caching dictionary
     - parameter callback: a block executed when network request finished
     */
    private class func executeRequestWithKey(key: String, request: Request, callback: NetworkCallbackBlock) {
        // Add a new item in the caching dictionary
        PendingOpDict[key] = (request, NSDate())
        // Executing request
        request.responseJSON { (_, res, result) -> Void in
            let statusCode = res?.statusCode ?? 404
            var data: AnyObject?
            var error: NetworkErrorType?
            
            // Remove the item the caching dictionary
            PendingOpDict.removeValueForKey(key)
            
            // Deal with statusCode and JSON from server
            if result.isSuccess && (statusCode >= 200 && statusCode < 300) {
                data = result.value
            } else {
                if result.isFailure {
                    error = NetworkErrorType.NetworkUnreachable("\(result.error)")
                } else if let value = result.value {
                    // Retrieve error message, pls refer to 'API.md' for details
                    let message = JSON(value)["message"].string
                    
                    if statusCode == Constants.ForbiddenStatusCode || statusCode == Constants.UnauthorizedStatusCode {
                        error = NetworkErrorType.NetworkUnauthenticated(message ?? "Unauthenticated access")
                    } else if statusCode == Constants.BadRequestStatusCode || statusCode == Constants.NotFoundStatusCode {
                        error = NetworkErrorType.NetworkForbiddenAccess(message ?? "Bad request")
                    } else if case(400..<500) = statusCode {
                        error = NetworkErrorType.NetworkWrongParameter(message ?? "Wrong parameters")
                    } else if case(500...505) = statusCode {
                        error = NetworkErrorType.NetworkServerError(message ?? "Server error")
                    }
                }
            }
            // execute the block
            callback(data, error)
        }
    }
    
    class func existPendingOperation(key: String) -> Bool {
        return PendingOpDict[key] != nil
    }
}

extension NetworkManager {
    
    // Router is a factory for producing network request
    private enum Router: URLRequestConvertible {
        
        // Server URL
        static let baseURLString = ""
        
        // Different types of network request
        case Login(String, String)
        case Register(String, String, String)
        case UserCourse(String, String)
        case QuizList(String, String, String)
        case QuizContent(String, String, String)
        case SigninInfo(String, String, String)
        case OriginAnswer(String, String, String, String)
        case SubmitAnswer(String, String, String, String, String)
        case SubmitSignIn(String, String, String, String, String, String)
        case AttendCourse(String, String, String)
        case QuitCourse(String, String, String)
        case AllCourse(String, String)
        case ProjectList(String, String, String)
        case GroupList(String, String, String)
        case ProlemList(String, String, String)
        case TeammateList(String, String, String, String)
        case GroupInvite(String, String, String, String, String)
        case GroupAccept(String, String, String, String)
        case GroupDecline(String, String, String, String)
        
        
        var URLRequest: NSMutableURLRequest {
            
            // 1. Set the properties for the request, including URL, HTTP Method, and its parameters
            var (path, method, parameters): (String, Alamofire.Method, [String: AnyObject]) = {
                switch self {
                case .Login(let name, let password):
                    let params = ["name": name, "password": password]
                    return ("/user/login", Method.POST, params)
                case .Register(let name, let realName, let password):
                    let params = ["name": name, "realName": realName, "password": password]
                    return ("/user/register", Method.POST, params)
                case .UserCourse(let id, let token):
                    let params = ["_id": id, "token": token]
                    return ("/user/courses", Method.GET, params)
                case .QuizList(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/quiz/list", Method.GET, params)
                case .QuizContent(let id, let token, let quizID):
                    let params = ["_id": id, "token": token, "quiz_id": quizID]
                    return ("/quiz/content", Method.GET, params)
                case .SigninInfo(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/signin/info", Method.GET, params)
                case .OriginAnswer(let id, let token, let courseID, let quizID):
                    let params = ["_id": id, "token": token, "course_id": courseID, "quiz_id": quizID]
                    return ("/answer/quiz/info", Method.GET, params)
                case .SubmitAnswer(let id, let token, let courseID, let quizID, let status):
                    let params = ["_id": id, "token": token, "course_id": courseID, "quiz_id": quizID, "status": status]
                    return ("/answer/submit", Method.POST, params)
                case .SubmitSignIn(let id, let token, let courseID, let signinID, let uuid, let deviceID):
                    let params = ["_id": id, "token": token, "course_id": courseID, "signin_id": signinID, "uuid": uuid, "device_id": deviceID]
                    return ("/signin/submit", Method.POST, params)
                case .AttendCourse(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/user/attend", Method.POST, params)
                case .QuitCourse(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/user/quit", Method.PUT, params)
                case .AllCourse(let id, let token):
                    let params = ["_id": id, "token": token]
                    return ("/course/all", Method.GET, params)
                case .ProjectList(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/project/info", Method.GET, params)
                case .GroupList(let id, let token, let projectID):
                    let params = ["_id": id, "token": token, "project_id": projectID]
                    return ("/project/group/info", Method.GET, params)
                case .ProlemList(let id, let token, let projectID):
                    let params = ["_id": id, "token": token, "project_id": projectID]
                    return ("/project/problem/info", Method.GET, params)
                case .TeammateList(let id, let token, let courseID, let projectID):
                    let params = ["_id": id, "token": token, "course_id": courseID, "project_id": projectID]
                    return ("/project/students", Method.GET, params)
                case .GroupInvite(let id, let token, let projectID, let problemID, let members):
                    let params = ["_id": id, "token": token, "project_id": projectID, "problem_id": problemID, "members": members]
                    return ("/project/group/invite", Method.POST, params)
                case .GroupAccept(let id, let token, let projectID, let groupID):
                    let params = ["_id": id, "token": token, "project_id": projectID, "group_id": groupID]
                    return ("/project/group/accept", Method.PUT, params)
                case .GroupDecline(let id, let token, let projectID, let groupID):
                    let params = ["_id": id, "token": token, "project_id": projectID, "group_id": groupID]
                    return ("/project/group/decline", Method.PUT, params)
                }
            }()
            
            // 2. Add HTTP headers
            let URLRequest: NSMutableURLRequest = {
                (inout parameters: [String: AnyObject]) in
                let URL = NSURL(string: Router.baseURLString)!
                let request = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
                
                let buildVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
                request.setValue("\(buildVersion)", forHTTPHeaderField: "x-build-version")
                
                request.setValue(parameters["token"] as? String, forHTTPHeaderField: "x-access-token")
                parameters.removeValueForKey("token")
                
                request.HTTPMethod = method.rawValue
                return request
            }(&parameters)
            
            // 3. Encode the network request
            if method == Method.GET {
                return ParameterEncoding.URL.encode(URLRequest, parameters: parameters).0
            }
            return ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
        }
    }
    
    /** 4. From now on, each network access only require two lines of code
        *   4.0 Make sure there is no pending network operations
        *   4.1 Retrieve the network request
        *   4.2 Execute the request
        *   Note: each method recieve similar parameters, that is, the nessesary parameter mentioned in 'API.md' and a block executing when network request finished.
    */

    func login(name: String, password: String, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.LoginKey) else {return}
        let request = NetworkManager.Manager.request(Router.Login(name, password))
        NetworkManager.executeRequestWithKey(Constants.LoginKey, request: request, callback: callback)
    }
    
    func register(name: String, realName: String, password: String, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.RegisterKey) else {return}
        let request = NetworkManager.Manager.request(Router.Register(name, realName, password))
        NetworkManager.executeRequestWithKey(Constants.RegisterKey, request: request, callback: callback)
    }
    
    func courseList(userID: String?, token: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.UserCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.UserCourse(userID ?? "", token ?? ""))
        NetworkManager.executeRequestWithKey(Constants.UserCourseKey, request: request, callback: callback)
    }
    
    func quizList(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.QuizListKey) else {return}
        let request = NetworkManager.Manager.request(Router.QuizList(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuizListKey, request: request, callback: callback)
    }
    
    func quizContent(userID: String?, token: String?, quizID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.QuizContentKey) else {return}
        let request = NetworkManager.Manager.request(Router.QuizContent(userID ?? "", token ?? "", quizID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuizContentKey, request: request, callback: callback)
    }
    
    func signinInfo(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SigninInfoKey) else {return}
        let request = NetworkManager.Manager.request(Router.SigninInfo(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SigninInfoKey, request: request, callback: callback)
    }
    
    func originAnswer(userID: String?, token: String?, courseID: String?, quizID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.OriginAnswerKey) else {return}
        let request = NetworkManager.Manager.request(Router.OriginAnswer(userID ?? "", token ?? "", courseID ?? "", quizID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.OriginAnswerKey, request: request, callback: callback)
    }
    
    func submitAnswer(userID: String?, token: String?, courseID: String?, quizID: String?, status: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SubmitAnswerKey) else {return}
        let request = NetworkManager.Manager.request(Router.SubmitAnswer(userID ?? "", token ?? "", courseID ?? "", quizID ?? "", status ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SubmitAnswerKey, request: request, callback: callback)
    }
    
    func submitSignIn(userID: String?, token: String?, courseID: String?, signinID: String?, uuid: String?, deviceID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SubmitSignInKey) else {return}
        let request = NetworkManager.Manager.request(Router.SubmitSignIn(userID ?? "", token ?? "", courseID ?? "", signinID ?? "", uuid ?? "", deviceID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SubmitSignInKey, request: request, callback: callback)
    }
    
    func attendCourse(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.AttendCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.AttendCourse(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.AttendCourseKey, request: request, callback: callback)
    }
    
    func quitCourse(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.QuitCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.QuitCourse(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuitCourseKey, request: request, callback: callback)
    }
    
    func allCourse(userID: String?, token: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.AllCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.AllCourse(userID ?? "", token ?? ""))
        NetworkManager.executeRequestWithKey(Constants.AllCourseKey, request: request, callback: callback)
    }
    
    func projectList(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.ProjectListKey) else {return}
        let request = NetworkManager.Manager.request(Router.ProjectList(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ProjectListKey, request: request, callback: callback)
    }
    
    func groupList(userID: String?, token: String?, projectID: String, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupListKey) else {return}
        let request = NetworkManager.Manager.request(Router.GroupList(userID ?? "", token ?? "", projectID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupListKey, request: request, callback: callback)
    }
    
    func problemList(userID: String?, token: String?, projectID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.ProblemListKey) else {return}
        let request = NetworkManager.Manager.request(Router.ProlemList(userID ?? "", token ?? "", projectID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ProblemListKey, request: request, callback: callback)
    }
    
    func teammateList(userID: String?, token: String?, courseID: String?, projectID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.TeammateListKey) else {return}
        let request = NetworkManager.Manager.request(Router.TeammateList(userID ?? "", token ?? "", courseID ?? "", projectID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.TeammateListKey, request: request, callback: callback)
    }
    
    func groupInvite(userID: String?, token: String?, projectID: String?, problemID: String?, members: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupInviteKey) else {return}
        let request  = NetworkManager.Manager.request(Router.GroupInvite(userID ?? "", token ?? "", projectID ?? "", problemID ?? "", members ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupInviteKey, request: request, callback: callback)
    }
    
    func groupAccept(userID: String?, token: String?, projectID: String?, groupID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupAcceptKey) else {return}
        let request = NetworkManager.Manager.request(Router.GroupAccept(userID ?? "", token ?? "", projectID ?? "", groupID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupAcceptKey, request: request, callback: callback)
    }
    
    func groupDecline(userID: String?, token: String?, projectID: String?, groupID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupDeclineKey) else {return}
        let request = NetworkManager.Manager.request(Router.GroupDecline(userID ?? "", token ?? "", projectID ?? "", groupID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupDeclineKey, request: request, callback: callback)
    }
}