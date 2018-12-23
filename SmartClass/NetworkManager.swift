//
//  NetworkManager.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

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
        static let UserInfo        = "User's Information" //??
        static let StudentInfoKey  = "Student Info"
        static let LessonInfoKey   = "Lesson Info"
        static let LessonFileInfoKey = "Lesson File Info"
        static let NotificationKey = "Notification"
        static let EXListKey       = "EX List"
        static let PostKey         = "Post Key"
        static let NewPostKey      = "New Post Key"
        static let CreateGroupKey  = "Create Group Key"
        static let GroupQueryKey   = "Group Query"
        static let GroupApplyKey   = "Group Apply Key"
        static let ShowGroupKey    = "Show Group Key"
        static let ShowRequestKey  = "Show Request Key"
        static let GetNoGroupKey   = "Get No Group Key"
        static let ReplyPostingKey = "Reply Posting Key"
        static let ShowMyLoveKey = "Show My Love Key"
        static let DealGroupKey    = "Deal Group Key"
        static let SaveWishKey     = "Save Wish Key"

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
        print(request)
        request.responseJSON { (_, res, result) in
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
        //static let baseURLString = "http://smartclass.zakelly.com:3000"
        static let baseURLString = "http://222.29.98.104:3000"
        
        // Different types of network request
        case Login(String, String)
        case Register(String, String, String)
        case UserCourse(String, String)
        case QuizList(String, String, String)
        case QuizContent(String, String, String)
        case SigninInfo(String, String, String)
        case OriginAnswer(String, String, String, String)
        case SubmitAnswer(String, String, String, String, [[String: AnyObject]])
        case SubmitSignIn(String, String, String, String, String, String)
        case AttendCourse(String, String, String,String)
        case QuitCourse(String, String, String)
        case AllCourse(String, String)
        case ProjectList(String, String, String)
        case GroupList(String, String, String)
        case ProblemList(String, String, String)
        case TeammateList(String, String, String, String)
        case GroupInvite(String, String, String, String, String)
        case GroupAccept(String, String, String, String)
        case GroupDecline(String, String, String, String)
        case UserInfo(String, String, String, String)//?? id, token, name, password
        case StudentInfo(String, String)
        case LessonInfo(String, String, String)
        case LessonFileInfo(String, String, String, String, String)
        case NotificationList(String, String, NSNumber, String)
        case EXList(String, String, String, String, NSNumber)
        case PostDetail(String, String, String)
        case NewPost(String, String, String, String, String, String, String,String)
        case CreateGroup(String, String, String, String, String)
        case GroupQuery(String, String, String)
        case GroupApply(String, String, String, String)
        case ShowGroup(String, String, String)
        case ShowRequest(String, String, String)
        case GetNoGroup(String, String, String)
        case ReplyPosting(String, String, String, String)
        case ShowMyLove(String, String, String, String, String, String)
        case DealGroup(String, String, String, String, String, String, String)
        case SaveWish(String, String, String, String, [[String: AnyObject]])
        
        var URLRequest: NSMutableURLRequest {
            
            // 1. Set the properties for the request, including URL, HTTP Method, and its parameters
            var (path, method, parameters): (String, Alamofire.Method, [String: AnyObject]) = {
                switch self {
                case .Login(let name, let password):
                    let params = ["name": name, "password": password]
                    return ("/api/user/login", Method.POST, params)
                case .Register(let name, let realName, let password):
                    let params = ["name": name, "realName": realName, "password": password]
                    return ("/api/user/register", Method.POST, params)
                    
                case .StudentInfo(let id,let token):
                    let params = ["_id": id,"token":token]
                    return ("/api/user/info", Method.GET, params)
                    
                case .UserCourse(let id, let token):
                    let params = ["_id": id, "token": token]
                    return ("/api/user/courses", Method.GET, params)
                //user/courses
                case .QuizList(let id, let token, let courseID):
                    let params = ["_id": id, "course_id": courseID, "token": token]
                    print("\(params)")
                    return ("/api/quiz/list", Method.GET, params)
                case .QuizContent(let id, let token, let quizID):
                    let params = ["_id": id, "token": token, "quiz_id": quizID]
                    return ("/api/quiz/content", Method.GET, params)
                case .SigninInfo(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/api/signin/info", Method.GET, params)
                case .OriginAnswer(let id, let token, let courseID, let quizID):
                    let params = ["_id": id, "token": token, "course_id": courseID, "quiz_id": quizID]
                    return ("/api/answer/quiz/info", Method.GET, params)
                case .SubmitAnswer(let id, let token, let courseID, let quizID, let status):
                    let data = try? NSJSONSerialization.dataWithJSONObject(status, options: NSJSONWritingOptions.PrettyPrinted)
                    let strJson : NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    //let statusJson = JSON(data:data!)
                    print(strJson)
                    let params:[String:AnyObject] = ["_id": id, "token": token, "course_id": courseID, "quiz_id": quizID, "status": strJson ]
                    print("\(params)")
                    return ("/api/answer/submit", Method.POST, params as! [String : AnyObject])
                case .SubmitSignIn(let id, let token, let courseID, let signinID,  let deviceID, let uuid):
                    let params = ["_id": id, "token": token, "course_id": courseID, "device_id": deviceID,"signin_id": signinID, "uuid":uuid]
                    return ("/api/signin/submit", Method.POST, params)
                case .AttendCourse(let id, let token, let courseID, let userName):
                    let params = ["_id": id, "token": token, "course_id": courseID,"user_name":userName]
                    return ("/api/user/attend", Method.PUT, params)
                case .QuitCourse(let id, let token, let courseID):
                    let params = ["_id": id, "token": token]
                    return ("/api/course/\(courseID)/quit", Method.PUT, params)
                case .AllCourse(let id, let token):
                    let params = ["_id": id, "token": token]
                    return ("/api/user/elect_courses", Method.GET, params)///api/course/all elect_courses
                case .ProjectList(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return ("/api/group/givegroup", Method.GET, params)
                case .GroupList(let id, let token, let projectID):
                    let params = ["_id": id, "token": token]
                    return ("/api/project/\(projectID)/group", Method.GET, params)
                case .ProblemList(let id, let token, let projectID):
                    let params = ["_id": id, "token": token]
                    return ("/api/project/\(projectID)/problem", Method.GET, params)
                case .TeammateList(let id, let token, _, let projectID):
                    let params = ["_id": id, "token": token]
                    return ("/api/project/\(projectID)/students", Method.GET, params)
                case .GroupInvite(let id, let token, let projectID, let problemID, let members):
                    let params = ["_id": id, "token": token, "members": members]
                    return ("/api/project/\(projectID)/problem/\(problemID)/group", Method.POST, params)
                case .GroupAccept(let id, let token, let projectID, let groupID):
                    let params = ["_id": id, "token": token]
                    return ("/api/project/\(projectID)/group/\(groupID)/accept", Method.POST, params)
                case .GroupDecline(let id, let token, let projectID, let groupID):
                    let params = ["_id": id, "token": token]
                    return ("/api/project/\(projectID)/group/\(groupID)/decline", Method.POST, params)
                case .UserInfo(let id, let token, let name, let password)://??
                    let params = ["_id": id, "token": token, "realName": name, "password": password]
                    return("/api/user/info", Method.POST, params)
                case .LessonInfo(let id, let token, let courseID)://??
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return("/api/lesson/info", Method.GET, params)
                case .LessonFileInfo(let id, let token, let courseID, let lessonID, let lessonName):
                    let params = ["_id": id, "token": token]
                    return("/api/fileinfo/\(courseID)/\(lessonID)", Method.GET, params)
                case .NotificationList(let id, let token, let page, let courseID):
                    let params = ["_id": id, "token": token, "page": page, "course_id": courseID]
                    print("params!!")
                    print(params)
                    return("/api/notification/getList", Method.GET, params)
                case .EXList(let id, let token, let courseID, let type, let page):
                    let params = ["_id": id, "token": token, "course_id": courseID, "type": type, "page": page]
                    return("/api/forum/getList", Method.GET, params)
                case .PostDetail(let id, let token, let postID):
                    let params = ["_id": id, "token": token, "posting_id": postID]
                    return("/api/forum/getDetail", Method.GET, params)
                case .NewPost(let id, let token, let name, let courseID, let title, let content, let postType,let img):
                    
                    let params = ["_id": id, "token": token,  "user_id": id, "name": name, "course_id": courseID, "title": title, "content": content, "post_type": postType, "img": img]
                    print(params)
                    return("/api/forum/post", Method.POST, params)
                case .CreateGroup(let id, let token, let leaderName, let courseID, let groupName):
                    let params = ["_id": id, "token": token,  "leader_name": leaderName, "course_id": courseID, "group_name": groupName]
                    print(params)
                    return("/api/group/create", Method.POST, params)
                case .GroupQuery(let id, let token, let courseID):
                    let params = ["_id": id, "token": token,  "course_id": courseID]
                    return("/api/group/query", Method.GET, params)
                case .GroupApply(let id, let token, let groupID, let memberName):
                    let params = ["_id": id, "token": token, "group_id": groupID, "member_name": memberName, "member_id": id]
                    return("/api/group/apply", Method.POST, params)
                case .ShowGroup(let id, let token, let groupID):
                    let params = ["_id": id, "token": token, "group_id": groupID]
                    return("/api/group/show", Method.GET, params)
                case .ShowRequest(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return("/api/group/showwaiting", Method.GET, params)
                case .GetNoGroup(let id, let token, let courseID):
                    let params = ["_id": id, "token": token, "course_id": courseID]
                    return("/api/group/getnogroup", Method.GET, params)
                    
                case .ReplyPosting(let id, let token, let postingID, let content):
                    let params = ["_id":id, "token":token, "posting_id":postingID, "content":content]
                    return("/api/forum/reply", Method.POST, params)
                    
                case .ShowMyLove(let id, let token, let postuser, let courseID, let postingID, let type):
                    let params = ["_id":id, "token":token, "user_id":postuser, "course_id":courseID, "like_id":postingID, "type":type]
                    return("/api/forum/like", Method.POST,params)
                case .DealGroup(let id, let token, let groupID, let courseID, let type, let memberID, let memberName):
                    let params = ["_id": id, "token": token, "group_id": groupID, "course_id": courseID, "type": type, "member_id": memberID, "member_name": memberName]
                    print("params:")
                    print(params)
                    return("/api/group/deal", Method.POST, params)
                case .SaveWish(let id, let token, let courseID, let name, let target):
                    
                    let data = try? NSJSONSerialization.dataWithJSONObject(target, options: NSJSONWritingOptions.PrettyPrinted)
                    let strJson : NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    let params = ["_id": id, "token": token, "require_id": id, "course_id": courseID, "require_name": name, "target": strJson]
                    print(strJson)
                    return("/api/group/savewish", Method.POST, params)
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
    
    func studentInfo(userID: String?,token: String? , callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.StudentInfoKey)else {return}
        let request = NetworkManager.Manager.request(Router.StudentInfo(userID ?? "",token ?? ""))
        NetworkManager.executeRequestWithKey(Constants.StudentInfoKey, request: request, callback: callback)
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
    
    func submitAnswer(userID: String?, token: String?, courseID: String?, quizID: String?, status: [[String: AnyObject]]?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SubmitAnswerKey) else {return}
        let request = NetworkManager.Manager.request(Router.SubmitAnswer(userID ?? "", token ?? "", courseID ?? "", quizID ?? "", status ?? []))
        
        NetworkManager.executeRequestWithKey(Constants.SubmitAnswerKey, request: request, callback: callback)
    }
    
    func submitSignIn(userID: String?, token: String?, courseID: String?, signinID: String?, uuid: String?, deviceID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SubmitSignInKey) else {return}
        let request = NetworkManager.Manager.request(Router.SubmitSignIn(userID ?? "", token ?? "", courseID ?? "", signinID ?? "", uuid ?? "", deviceID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.SubmitSignInKey, request: request, callback: callback)
    }
    
    func attendCourse(userID: String?, token: String?, courseID: String?, userName: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.AttendCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.AttendCourse(userID ?? "", token ?? "", courseID ?? "", userName ?? ""))
        NetworkManager.executeRequestWithKey(Constants.AttendCourseKey, request: request, callback: callback)
    }
    
    func quitCourse(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.QuitCourseKey) else {return}
        let request = NetworkManager.Manager.request(Router.QuitCourse(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.QuitCourseKey, request: request, callback: callback)
    }
    /*
    func userInfo(userID: String?, token: String?) {
        Constants.
    }*/
    
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
        let request = NetworkManager.Manager.request(Router.ProblemList(userID ?? "", token ?? "", projectID ?? ""))
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
    
    func userInfo(userID: String?, token: String?, name: String?, password: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.UserInfo) else {return}
        let request = NetworkManager.Manager.request(Router.UserInfo(userID ?? "", token ?? "", name ?? "", password ?? ""))
        NetworkManager.executeRequestWithKey(Constants.UserInfo, request: request, callback: callback)
    } //??
    
    func lessonInfo(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.LessonInfoKey) else {return}
        let request = NetworkManager.Manager.request(Router.LessonInfo(userID ??
            "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.LessonInfoKey, request: request, callback: callback)
    }
    func lessonFileInfo(userID: String?, token: String?, courseID: String?, lessonID: String?, lessonName: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.LessonFileInfoKey) else {return}
        let request = NetworkManager.Manager.request(Router.LessonFileInfo(userID ??
            "", token ?? "", courseID ?? "", lessonID ?? "", lessonName ?? ""))
        NetworkManager.executeRequestWithKey(Constants.LessonFileInfoKey, request: request, callback: callback)
    }
    func notificationList(userID: String?, token: String?, page: NSNumber?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.NotificationKey) else {return}
        let request = NetworkManager.Manager.request(Router.NotificationList(userID ??
            "", token ?? "", page ?? 0, courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.NotificationKey, request: request, callback: callback)
    }
    func exList(userID: String?, token: String?, courseID: String?,  type: String?, page: NSNumber?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.EXListKey) else {return}
        let request = NetworkManager.Manager.request(Router.EXList(userID ?? "", token ?? "", courseID ?? "", type ?? "",  page ?? 0))
        NetworkManager.executeRequestWithKey(Constants.EXListKey, request: request, callback: callback)
    }
    func postDetail(userID: String?, token: String?, postID: String?, callback: NetworkCallbackBlock) {
        let request = NetworkManager.Manager.request(Router.PostDetail(userID ?? "", token ?? "", postID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.PostKey, request: request, callback: callback)
    }
    func newPost(userID: String?, token: String?, name: String?, courseID: String?, title: String?, content: String?, postType: String?, img:String? ,callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.NewPostKey) else {return}
        let request = NetworkManager.Manager.request(Router.NewPost(userID ?? "", token ?? "", name ?? "", courseID ?? "", title ?? "",  content ?? "", postType ?? "",img ?? ""))
        NetworkManager.executeRequestWithKey(Constants.NewPostKey, request: request, callback: callback)
    }
    func createGroup(userID: String?, token: String?, courseID: String?, leaderName: String?, groupName: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.CreateGroupKey) else {return}
        let request = NetworkManager.Manager.request(Router.CreateGroup(userID ?? "", token ?? "", leaderName ?? "", courseID ?? "", groupName ?? ""))
        NetworkManager.executeRequestWithKey(Constants.CreateGroupKey, request: request, callback: callback)
    }
    func queryGroup(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupQueryKey) else {return}
        let request = NetworkManager.Manager.request(Router.GroupQuery(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupQueryKey, request: request, callback: callback)
    }
    func applyGroup(userID: String?, token: String?, groupID: String?, memberName: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.GroupApplyKey) else {return}
        let request = NetworkManager.Manager.request(Router.GroupApply(userID ?? "", token ?? "", groupID ?? "", memberName ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GroupApplyKey, request: request, callback: callback)
    }
    func showGroup(userID: String?, token: String?, groupID: String?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.ShowGroupKey) else {return}
        let request = NetworkManager.Manager.request(Router.ShowGroup(userID ?? "", token ?? "", groupID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ShowGroupKey, request: request, callback: callback)
    }
    func showRequest(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock){
        guard !NetworkManager.existPendingOperation(Constants.ShowRequestKey) else {return}
        let request = NetworkManager.Manager.request(Router.ShowRequest(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ShowGroupKey, request: request, callback: callback)
    }
    func getNoGroup(userID: String?, token: String?, courseID: String?, callback: NetworkCallbackBlock){
        guard !NetworkManager.existPendingOperation(Constants.GetNoGroupKey) else {return}
        let request = NetworkManager.Manager.request(Router.GetNoGroup(userID ?? "", token ?? "", courseID ?? ""))
        NetworkManager.executeRequestWithKey(Constants.GetNoGroupKey, request: request, callback: callback)
    }
    func ReplyPosting(userID: String?, token: String?, postingID: String?, content: String?, callback:NetworkCallbackBlock){
        guard !NetworkManager.existPendingOperation(Constants.ReplyPostingKey) else {return}
        let request = NetworkManager.Manager.request(Router.ReplyPosting(userID ?? "", token ?? "", postingID ?? "", content ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ReplyPostingKey, request: request, callback: callback)
    }
    
    func ShowMyLove(userID: String?, token: String?, postuser: String? ,courseID: String?, postingID: String?, type: String?, callback:NetworkCallbackBlock){
        guard !NetworkManager.existPendingOperation(Constants.ShowMyLoveKey) else {return}
        let request = NetworkManager.Manager.request(Router.ShowMyLove(userID ?? "", token ?? "",postuser ?? "", courseID ?? "",postingID ?? "", type ?? ""))
        NetworkManager.executeRequestWithKey(Constants.ShowMyLoveKey, request: request, callback: callback)
    }
    func dealGroup(userID: String?, token: String?, groupID: String?, courseID: String?, type: String?, memberID: String?, memberName:String?, callback: NetworkCallbackBlock){
        guard !NetworkManager.existPendingOperation(Constants.DealGroupKey) else {return}
        let request = NetworkManager.Manager.request(Router.DealGroup(userID ?? "", token ?? "", groupID ?? "", courseID ?? "", type ?? "", memberID ?? "", memberName ?? ""))
        //let id, let token, let groupID, let courseID, let type, let memberID, let memberName
        NetworkManager.executeRequestWithKey(Constants.DealGroupKey, request: request, callback: callback)
    }
    func saveWish(userID: String?, token: String?, courseID: String?, name: String?, target: [[String: AnyObject]]?, callback: NetworkCallbackBlock) {
        guard !NetworkManager.existPendingOperation(Constants.SaveWishKey) else {return}
        let request = NetworkManager.Manager.request(Router.SaveWish(userID ?? "", token ?? "", courseID ?? "", name ?? "", target ?? []))
        //let id, let token, let groupID, let courseID, let type, let memberID, let memberName
        NetworkManager.executeRequestWithKey(Constants.SaveWishKey, request: request, callback: callback)
    }
}