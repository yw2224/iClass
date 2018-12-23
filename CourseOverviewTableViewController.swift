//
//  CourseOverviewTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/11/23.
//  Copyright © 2016年 PKU. All rights reserved.
//

import CocoaLumberjack
import CoreBluetooth
import CoreLocation
import SVProgressHUD
import UIKit

class CourseOverviewTableViewController: UITableViewController {

    private struct Constants {
        static let CourseCellHeight: CGFloat           = 88.0
        static let Header = (0, "Header Cell")
        static let SignIn = (1, "SignInCell Identifier")
        //tableView.dequeueReusableCellWithIdentifier("SignInCell Identifier", forIndexPath: indexPath)
        static let Overview = (2, "Overview Cell")
        static let ImportantDate = (3, "Examination Cell")
        static let Error = (-1, "Error Cell")
        static let CellHeights: [CGFloat] = [100, 42, 88, 88]
        static let SpaceInterval: CGFloat = 40.0
        static let AnimationTime: CGFloat = 0.5
        static let CourseDescriptionSegueIdentifier = "Course Description Segue"
        static let ImportantDateSegueIdentifier = "Important Date Segue"
        static let SignInCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        static let RefreshTag = 0
    }

    var courseFunction: [String] = [
        "通知", "测试", "内容", "论坛", "小组"
    ]
    var imageFunction: [String] = [
        "Ironman","Shield","Spider","Wolverine","loki"
    ]

    var courseID: String!
    var courseName: String!
    var currentCourse: Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        retrieveSigninInfo()
        //tableView.estimatedRowHeight = Constants.CourseCellHeight
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section
        {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 5
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("CourseIntroductionCell Identifier", forIndexPath: indexPath) as! CourseIntroductionCell
            print("courseID = \(courseID)\n")
            cell.setupCourseName(currentCourse)
            return cell;
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SignInCell Identifier", forIndexPath: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
          
            return cell;
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("CourseFunctionCell Identifier", forIndexPath: indexPath) as! CourseFunctionCell
            cell.setupCourseFunction(imageFunction[indexPath.row],courseFunctionString: courseFunction[indexPath.row])
            

            return cell;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section
        {
        case 0:
            return 125
        case 1:
            return 100
        default:
            return 70
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.section
        {
        case 0:
            break
        case 1:
            break
        default:
            if indexPath.row == 0
            {
                performSegueWithIdentifier("ShowNotificationSegue", sender: self)
            }
            if indexPath.row == 1
            {
                performSegueWithIdentifier("ShowQuizSegue", sender: self)
            }
            if indexPath.row == 2
            {
                performSegueWithIdentifier("ShowLessonSegue", sender: self)
            }
            if indexPath.row == 3
            {
                performSegueWithIdentifier("showForumSegue", sender: self)
            }
            if indexPath.row == 4
            {
                //groupQuery()
                performSegueWithIdentifier("ShowProjectSegue", sender: self)
            }
            break
        }
    }

 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowQuizSegue"
        {
            if let qvc = segue.destinationViewController as? QuizViewController
            {
                qvc.courseID = courseID
            }
        }
        if segue.identifier == "ShowLessonSegue"
        {
            if let ltbc = segue.destinationViewController as? LessonTableViewController
            {
                ltbc.courseID = courseID
            }
        }
        if segue.identifier == "ShowNotificationSegue"
        {
            if let ntvc = segue.destinationViewController as? NotificationTableViewController
            {
                ntvc.courseID = courseID
            }
        }
        if segue.identifier == "showForumSegue"
        {
            if let ftvc = segue.destinationViewController as? ForumTableViewController
            {
                ftvc.courseID = courseID
            }
        }
        if segue.identifier == "ShowProjectSegue"
        {
            if let ftvc = segue.destinationViewController as? ProjectTableViewController
            {
                //groupQuery()
                //ftvc.joinedaGroup = self.joinedaGroup
                ftvc.courseID = courseID
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToCourseOverviewPage(segue: UIStoryboardSegue)
    {
        
    }
    
    var joinedaGroup: String = ""
    
    func groupQuery() {
        ContentManager.sharedInstance.groupQuery(self.courseID) {
            (myGroup, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            self.joinedaGroup = myGroup["status"].string ?? ""
        }
        //SVProgressHUD.showInfoWithStatus("创建小组成功！")
        //self.joinedaGroup =
        print(self.joinedaGroup)
        //retrieveProjectList()
    }
  
    //origin:
    let beaconIdentifier = "yinhang"
    var lastProximity: CLProximity?
    var locationManager: CLLocationManager!
    var uuid: String!  // "BCEAD00F-F457-4E69-B32E-681251AC2048"
    var deviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var signinID: String!
    var isSigninEnabled = false
    var isBeaconFound = false
    
    // MARK: Inited in the prepare for segue
    //var courseID: String!
    /*
    @IBOutlet weak var courseOverviewTableview: UITableView! {
        didSet {
            courseOverviewTableview.tableFooterView = UIView(frame: CGRectZero)
        }
    }*/

    // MARK: Navigation
   /* override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController
        let course = CoreDataManager.sharedInstance.course(courseID)
        if let cdvc = dest as? CourseDescriptionViewController {
            cdvc.text = course.introduction
        } else if let cccvc = dest as? CourseCalendarContainerViewController {
            cccvc.courseID = course.course_id
        }
    }*/
    
    func retrieveSigninInfo() {
        
        ContentManager.sharedInstance.signinInfo(courseID) {
            (uuid, enable, total, user, signinID, error) in
            if let error = error {
                print("error")
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.SignInRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            print(uuid)
            print(signinID)
            print("reach success!!!1")
            print(user)
            guard let cell = self.tableView.cellForRowAtIndexPath(Constants.SignInCellIndexPath) as? SignInCell else {print("???")
                return}
            
            guard error == nil && enable ,let signinID = signinID else {print("false??");cell.failWithText("已签到： \(user) / \(total)"); return}
            //guard error == nil && enable else {print(error);cell.failWithText("已签到： \(user) / \(total)"); return}
            //let uuid = NSUUID(UUIDString: uuid)?.UUIDString
            let uuid = uuid
            //let signinID = signinID
            print("reach success!!!2 user = " )
            print(user)
            self.uuid = uuid
            self.signinID = signinID
            self.isSigninEnabled = true
            
            print("reach success!!!3")
            cell.successWithText("已签到： \(user) / \(total)")
            self.setupLocationManager()
        }
    }
    
    func submitSigninInfo() {
        guard isSigninEnabled && isBeaconFound && signinID != nil && uuid != nil else
        {print(isSigninEnabled)
            print(isBeaconFound)
            //print(signinID!)
            // print(uuid!)
            SVProgressHUD.showErrorWithStatus(GlobalConstants.SignInRetrieveErrorPrompt); return;}
        print(courseID)
        print(signinID)
        print(deviceID)
        print(uuid)
        ContentManager.sharedInstance.submitSignIn(courseID, signinID: signinID,uuid:uuid ,deviceID: deviceID) {
            error in
            if error == nil {
                self.retrieveSigninInfo()
            } else {
                if case .NetworkUnauthenticated = error! {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ServerErrorPrompt)
                } else if case NetworkErrorType.NetworkForbiddenAccess = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.SubmitSigninErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
    }
    
    
   /* @IBAction func signIn(sender: UIButton) {
    }*/
    @IBAction func signIn(sender: UIButton) {
        guard let cell = self.tableView.cellForRowAtIndexPath(Constants.SignInCellIndexPath) as? SignInCell else {return}
        cell.activityIndicator.startAnimating()
        cell.signInButton.enabled = false
        
        if cell.tag == Constants.RefreshTag {
            retrieveSigninInfo()
        } else {
            submitSigninInfo()
        }
    }
}

extension CourseOverviewTableViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        guard isSigninEnabled, let _ = signinID, uuid = uuid else {return}
        print("reach1")
        let beaconUUID   = NSUUID(UUIDString: uuid)!
        print(beaconUUID)
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
                                          identifier: beaconIdentifier)
        print(beaconRegion)
        beaconRegion.notifyEntryStateOnDisplay = true
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startUpdatingLocation()
    }
    
    func sendLocalNotificationWithMessage(message: String, playSound: Bool) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        
        if(playSound) {
            // classic star trek communicator beep
            //	http://www.trekcore.com/audio/
            //
            // note: convert mp3 and wav formats into caf using:
            //	"afconvert -f caff -d LEI16@44100 -c 1 in.wav out.caf"
            // http://stackoverflow.com/a/10388263
            
            notification.soundName = "tos_beep.caf";
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                                         inRegion region: CLBeaconRegion) {
        //isBeaconFound = true
        //DDLogInfo("Beacon found")
        print("beacons=")
        print(beacons)
        guard let beacon = beacons.first where
            (beacon.proximity != .Unknown && beacon.proximity != lastProximity)
            else {lastProximity = .Unknown; return;}
        DDLogInfo("Beacon found")
        isBeaconFound = true
        lastProximity = beacon.proximity
    }
    
    func locationManager(manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        DDLogInfo("Enter region")
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.startUpdatingLocation()
        sendLocalNotificationWithMessage("发现iBeacon，快打开App签到吧~", playSound: false)
    }
    
    func locationManager(manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        DDLogInfo("Exit region")
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
    }
}

class CourseIntroductionCell : UITableViewCell {
    
    //@IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseIntroduction: UILabel!
    func setupCourseName(course: Course)
    {
        courseName.text = course.name
        //teacherName.text = "yw"
        courseIntroduction.text = course.introduction
    }
    /*
    func setupWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        courseName.text = course
        teacherLabel.text = teacher
        badgeView.badgeNum = badge
    }
    
    func setBadgeNum(badgeNum: Int) {
        badgeView.badgeNum = badgeNum
    }*/
}

class SignInCell : UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
   
    func setup() {
        signInLabel.text = "已签到： 0 / 0"
        signInButton.setTitle("刷新", forState: .Normal)
    }
    
    func successWithText(text: String) {
        signInLabel.text = text
        signInButton.enabled = true
        signInButton.setTitle("签到", forState: .Normal)
        activityIndicator.stopAnimating()
        tag = 1
    }
    
    func failWithText(text: String) {
        signInLabel.text = text
        signInButton.enabled = true
        signInButton.setTitle("刷新", forState: .Normal)
        activityIndicator.stopAnimating()
        tag = 0
    }
}

class CourseFunctionCell : UITableViewCell {
 
    @IBOutlet weak var courseFunction: UILabel!

    @IBOutlet weak var imageFunction: UIImageView!
    func setupCourseFunction(imageName: String,courseFunctionString: String) {
        courseFunction.text = courseFunctionString
        imageFunction.image = UIImage(named: imageName ?? "exam2")
    }

    /*
    func setupWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        courseName.text = course
        teacherLabel.text = teacher
        badgeView.badgeNum = badge
    }*/
   
}


