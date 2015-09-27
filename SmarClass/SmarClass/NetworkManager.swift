//
//  NetworkManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias NetworkCallbackBlock = (AnyObject?, NetworkErrorType?) -> Void

enum NetworkErrorType: ErrorType, CustomStringConvertible {
    case NetworkUnreachable(String) // Timeout or sth.
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
    
    // This is a singleton
    static let sharedInstance = NetworkManager()

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
        static let AllCourseKey    = "All Course"
    }
    
    private static let Manager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10.0
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }()
    private static var PendingOpDict = [String : (Request, NSDate)]()
    
    private class func executeRequestWithKey(key: String, request: Request, callback: NetworkCallbackBlock) {
        if PendingOpDict[key] != nil {
            return
        }
        
        PendingOpDict[key] = (request, NSDate())
        request.validate().responseJSON() {
            (_, res, result) in
            let statusCode = res?.statusCode ?? 404
            var data: AnyObject?
            var error: NetworkErrorType?
            PendingOpDict.removeValueForKey(key)
            
            if result.isSuccess && (statusCode >= 200 && statusCode < 300) {
                data = result.value
            } else {
                if result.isFailure {
                    error = NetworkErrorType.NetworkUnreachable("\(result.error)")
                } else if let value = result.value {
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
            callback(data, error)
        }
    }
}

extension NetworkManager {
    
    private enum Router: URLRequestConvertible {
        static let baseURLString = "http://localhost:3000/api"
        
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
        case AllCourse(String, String)
        
        var URLRequest: NSMutableURLRequest {
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
                case .QuizList(let id, let token, let courseId):
                    let params = ["_id": id, "token": token, "course_id": courseId]
                    return ("/quiz/list", Method.GET, params)
                case .QuizContent(let id, let token, let quizId):
                    let params = ["_id": id, "token": token, "quiz_id": quizId]
                    return ("/quiz/content", Method.GET, params)
                case .SigninInfo(let id, let token, let courseId):
                    let params = ["_id": id, "token": token, "course_id": courseId]
                    return ("/signin/info", Method.GET, params)
                case .OriginAnswer(let id, let token, let courseId, let quizId):
                    let params = ["_id": id, "token": token, "course_id": courseId, "quiz_id": quizId]
                    return ("/answer/quiz/info", Method.GET, params)
                case .SubmitAnswer(let id, let token, let courseId, let quizId, let status):
                    let params = ["_id": id, "token": token, "course_id": courseId, "quiz_id": quizId, "status": status]
                    return ("/answer/submit", Method.POST, params)
                case .SubmitSignIn(let id, let token, let courseId, let signinId, let uuid, let deviceId):
                    let params = ["_id": id, "token": token, "course_id": courseId, "signin_id": signinId, "uuid": uuid, "device_id": deviceId]
                    return ("/signin/submit", Method.POST, params)
                case .AttendCourse(let id, let token, let courseId):
                    let params = ["_id": id, "token": token, "course_id": courseId]
                    return ("/user/attend", Method.POST, params)
                case .AllCourse(let id, let token):
                    let params = ["_id": id, "token": token]
                    return ("/course/all", Method.GET, params)
                }
            }()
            
            let URLRequest: NSMutableURLRequest = {
                (inout parameters: [String: AnyObject]) in
                let URL = NSURL(string: Router.baseURLString)!
                let request = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
                
                // MARK: version number
                let buildVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
                request.setValue("\(buildVersion)", forHTTPHeaderField: "x-build-version")
                
                request.setValue(parameters["token"] as? String, forHTTPHeaderField: "x-access-token")
                parameters.removeValueForKey("token")
                
                request.HTTPMethod = method.rawValue
                return request
            }(&parameters)
            
            if method == Method.GET {
                return ParameterEncoding.URL.encode(URLRequest, parameters: parameters).0
            }
            return ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
        }
    }
    
    func login(name: String, password: String, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.Login(name, password))
        NetworkManager.executeRequestWithKey(Constants.LoginKey, request: request, callback: callback)
    }
    
    func register(name: String, realName: String, password: String, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.Register(name, realName, password))
        NetworkManager.executeRequestWithKey(Constants.RegisterKey, request: request, callback: callback)
    }
    
    func courseList(userID: String?, token: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.UserCourse(userID ?? "", token ?? ""))
        NetworkManager.executeRequestWithKey(Constants.UserCourseKey, request: request, callback: callback)
    }
    
    func quizList(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.QuizList(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuizListKey, request: request, callback: callback)
    }
    
    func quizContent(userID: String?, token: String?, quizID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.QuizContent(userID ?? "", token ?? "", quizID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuizContentKey, request: request, callback: callback)
    }
    
    func signinInfo(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.SigninInfo(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SigninInfoKey, request: request, callback: callback)
    }
    
    func originAnswer(userID: String?, token: String?, courseID: String?, quizID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.OriginAnswer(userID ?? "", token ?? "", courseID ?? "", quizID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.OriginAnswerKey, request: request, callback: callback)
    }
    
    func submitAnswer(userID: String?, token: String?, courseID: String?, quizID: String?, status: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.SubmitAnswer(userID ?? "", token ?? "", courseID ?? "", quizID ?? "", status ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SubmitAnswerKey, request: request, callback: callback)
    }
    
    func submitSignIn(userID: String?, token: String?, courseID: String?, signinID: String?, uuid: String?, deviceID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.SubmitSignIn(userID ?? "", token ?? "", courseID ?? "", signinID ?? "", uuid ?? "", deviceID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SubmitSignInKey, request: request, callback: callback)
    }
    
    func attendCourse(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.AttendCourse(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.AttendCourseKey, request: request, callback: callback)
    }
    
    func allCourse(userID: String?, token: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.AllCourse(userID ?? "", token ?? ""))
        NetworkManager.executeRequestWithKey(Constants.AllCourseKey, request: request, callback: callback)
    }
}