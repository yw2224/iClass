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
        static let LoginKey = "Login"
        static let RegisterKey = "Register"
        static let UserCourseKey = "User's Course"
        static let QuizListKey = "Quiz List"
    }
    
    private enum Router: URLRequestConvertible {
        static let baseURLString = "http://192.168.1.102:3000/api"
        
        case Login(String, String)
        case Register(String, String, String)
        case UserCourse(String, String)
        case QuizList(String, String, String)
        
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
        if NetworkManager.isPendingRequestWithKey(Constants.LoginKey) {
            return
        }
        
        let request = NetworkManager.Manager.request(Router.Register(name, realName, password))
        NetworkManager.insertRequestWithKey(Constants.LoginKey, request: request)
        
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
    
}