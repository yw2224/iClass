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

class NetworkManager: NSObject {
    
    // This is a singleton
    static let sharedInstance = NetworkManager()
    
    private static let Manager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10.0
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }()
    private static var PendingOpDict = [String : (Request, NSDate)]()
    
    private class func insertRequestWithKey(key: String, request: Request) {
        PendingOpDict[key] = (request, NSDate())
    }
    
    private class func isPendingRequestWithKey(key: String) -> Bool {
        return PendingOpDict[key] != nil
    }
    
    private class func removeRequestWithKey(key: String) {
        PendingOpDict.removeValueForKey(key)
    }
    
    private static let callback: ((String, NSHTTPURLResponse?, AnyObject?, NSError?, NetworkBlock) -> Void) = {
        (key, res, data, error, callback) in
        PendingOpDict.removeValueForKey(key)
        if let e = error {
            callback(false, nil,
                (statusCode: res == nil ? 404 : res!.statusCode,
                    message: data == nil ? e.description : JSON(data!)["message"].stringValue))
        } else {
            callback(true, data,
                (statusCode: res!.statusCode,
                    message: "Network success"))
        }
    }
}

extension NetworkManager {
    
    private struct Constants {
        static let LoginKey        = "Login"
        static let RegisterKey     = "Register"
        static let UserCourseKey   = "User's Course"
        static let QuizListKey     = "Quiz List"
        static let QuizContentKey  = "Quiz Content"
        static let SigninInfoKey   = "Signin Info"
        static let OriginAnswerKey = "Original Answer"
        static let SubmitAnswerKey = "Submit Answer"
        static let SubmitSignInKey = "Submit SignIn"
    }
    
    private enum Router: URLRequestConvertible {
        static let baseURLString = "http://162.105.146.224:3000/api"
        
        case Login(String, String)
        case Register(String, String, String)
        case UserCourse(String, String)
        case QuizList(String, String, String)
        case QuizContent(String, String, String)
        case SigninInfo(String, String, String)
        case OriginAnswer(String, String, String, String)
        case SubmitAnswer(String, String, String, String, String)
        case SubmitSignIn(String, String, String, String, String, String)
        
        var URLRequest: NSURLRequest {
            var (path: String, method: Alamofire.Method, parameters: [String: AnyObject]) = {
                switch self {
                case .Login(let name, let password):
                    let params = ["name": name, "password": password]
                    return ("/user/login", Method.POST, params)
                case .Register(let name, let realName, let password):
                    let params = ["name": name, "realName": realName, "password": password]
                    return ("/user/register", Method.POST, params)
                case .UserCourse(let _id, let token):
                    let params = ["_id": _id, "token": token]
                    return ("/user/courses", Method.GET, params)
                case .QuizList(let _id, let token, let course_id):
                    let params = ["_id": _id, "token": token, "course_id": course_id]
                    return ("/quiz/list", Method.GET, params)
                case .QuizContent(let _id, let token, let quiz_id):
                    let params = ["_id": _id, "token": token, "quiz_id": quiz_id]
                    return ("/quiz/content", Method.GET, params)
                case .SigninInfo(let _id, let token, let course_id):
                    let params = ["_id": _id, "token": token, "course_id": course_id]
                    return ("/signin/info", Method.GET, params)
                case .OriginAnswer(let _id, let token, let course_id, let quiz_id):
                    let params = ["_id": _id, "token": token, "course_id": course_id, "quiz_id": quiz_id]
                    return ("/answer/quiz/info", Method.GET, params)
                case .SubmitAnswer(let _id, let token, let course_id, let quiz_id, let status):
                    let params = ["_id": _id, "token": token, "course_id": course_id, "quiz_id": quiz_id, "status": status]
                    return ("/answer/submit", Method.POST, params)
                case .SubmitSignIn(let _id, let token, let course_id, let signin_id, let uuidString, let deviceId):
                    let params = ["_id": _id, "token": token, "course_id": course_id, "signin_id": signin_id, "uuid": uuidString, "device_id": deviceId]
                    return ("/signin/submit", Method.POST, params)
                }
            }()
            
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest: NSURLRequest = {
                (inout parameters: [String: AnyObject]) in
                let request = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
                // MARK: version number
                let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
                request.HTTPMethod = method.rawValue
                request.setValue(parameters["token"] as! String?, forHTTPHeaderField: "x-access-token")
                request.setValue("iOS \(version)", forHTTPHeaderField: "x-build-version")
                parameters.removeValueForKey("token")
                return request
            }(&parameters)
            
            if method == Method.GET {
                return ParameterEncoding.URL.encode(URLRequest, parameters: parameters).0
            }
            return ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
        }
    }
    
    func login(name: String, password: String, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.LoginKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.Login(name, password))
        NetworkManager.insertRequestWithKey(Constants.LoginKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.LoginKey)
            NetworkManager.callback(Constants.LoginKey, res, data, error, callback)
        }
    }
    
    func register(name: String, realName: String, password: String, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.RegisterKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.Register(name, realName, password))
        NetworkManager.insertRequestWithKey(Constants.RegisterKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.RegisterKey)
            NetworkManager.callback(Constants.RegisterKey, res, data, error, callback)
        }
    }
    
    func courseList(user_id: String?, token: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.UserCourseKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.UserCourse(user_id ?? "", token ?? ""))
        NetworkManager.insertRequestWithKey(Constants.UserCourseKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.UserCourseKey)
            NetworkManager.callback(Constants.UserCourseKey, res, data, error, callback)
        }
        
    }
    
    func quizList(user_id: String?, token: String?, course_id: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.QuizListKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.QuizList(user_id ?? "", token ?? "", course_id ?? ""))
        NetworkManager.insertRequestWithKey(Constants.QuizListKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.QuizListKey)
            NetworkManager.callback(Constants.QuizListKey, res, data, error, callback)
        }
    }
    
    func quizContent(user_id: String?, token: String?, quiz_id: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.QuizContentKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.QuizContent(user_id ?? "", token ?? "", quiz_id ?? ""))
        NetworkManager.insertRequestWithKey(Constants.QuizContentKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.QuizContentKey)
            NetworkManager.callback(Constants.QuizContentKey, res, data, error, callback)
        }
    }
    
    func signinInfo(user_id: String?, token: String?, course_id: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.SigninInfoKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.SigninInfo(user_id ?? "", token ?? "", course_id ?? ""))
        NetworkManager.insertRequestWithKey(Constants.SigninInfoKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.SigninInfoKey)
            NetworkManager.callback(Constants.SigninInfoKey, res, data, error, callback)
        }

    }
    
    func originAnswer(user_id: String?, token: String?, course_id: String?, quiz_id: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.OriginAnswerKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.OriginAnswer(user_id ?? "", token ?? "", course_id ?? "", quiz_id ?? ""))
        NetworkManager.insertRequestWithKey(Constants.OriginAnswerKey, request: request)
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.OriginAnswerKey)
            NetworkManager.callback(Constants.OriginAnswerKey, res, data, error, callback)
        }
    }
    
    func submitAnswer(user_id: String?, token: String?, course_id: String?, quiz_id: String?, status: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.SubmitAnswerKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.SubmitAnswer(user_id ?? "", token ?? "", course_id ?? "", quiz_id ?? "", status ?? ""))
        NetworkManager.insertRequestWithKey(Constants.SubmitAnswerKey, request: request)
        
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.SubmitAnswerKey)
            NetworkManager.callback(Constants.SubmitAnswerKey, res, data, error, callback)
        }
    }
    
    func submitSignIn(user_id: String?, token: String?, course_id: String?, signin_id: String?, uuidString: String?, deviceId: String?, callback: NetworkBlock) {
        if NetworkManager.isPendingRequestWithKey(Constants.SubmitSignInKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.SubmitSignIn(user_id ?? "", token ?? "", course_id ?? "", signin_id ?? "", uuidString ?? "", deviceId ?? ""))
        NetworkManager.insertRequestWithKey(Constants.SubmitSignInKey, request: request)
        
        
        request.validate().responseJSON(options: .allZeros) {
            (_, res, data, error) in
            NetworkManager.removeRequestWithKey(Constants.SubmitSignInKey)
            NetworkManager.callback(Constants.SubmitSignInKey, res, data, error, callback)
        }
    }
}