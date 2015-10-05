//
//  CourseOverviewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import CocoaLumberjack
import CoreBluetooth
import CoreLocation
import UIKit

class CourseOverviewController: UIViewController {
    
    let beaconIdentifier = "edu.pku.netlab.SmartClass-Teacher"
    var lastProximity: CLProximity?
    var locationManager: CLLocationManager!
    var uuid: String? // "BCEAD00F-F457-4E69-B32E-681251AC2048"
    var deviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var signinID: String?
    var isSigninEnabled = false
    var isBeaconFound = false

    // MARK: Inited in the prepare for segue
	var courseID: String!
    var course: Course!
    
    @IBOutlet weak var courseOverviewTableview: UITableView! {
        didSet {
            courseOverviewTableview.tableFooterView = UIView(frame: CGRectZero)
        }
    }
	
    private struct Constants {
        static let Header = (0, "Header Cell")
        static let SignIn = (1, "SignIn Cell")
        static let Overview = (2, "Overview Cell")
        static let ImportantDate = (3, "Examination Cell")
        static let Error = (-1, "Error Cell")
        static let CellHeights: [CGFloat] = [100, 42, 88, 88]
        static let SpaceInterval: CGFloat = 40.0
        static let AnimationTime: CGFloat = 0.5
        static let CourseDescriptionSegueIdentifier = "Course Description Segue"
        static let ImportantDateSegueIdentifier = "Important Date Segue"
        static let SignInCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        static let RefreshTag = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        course = CoreDataManager.sharedInstance.course(courseID)
        retrieveSigninInfo()
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController 
        if let cdvc = dest as? CourseDescriptionViewController {
            cdvc.text = course.introduction
        } else if let cccvc = dest as? CourseCalendarContainerViewController {
            cccvc.courseID = course.course_id
        }
    }
    
    func retrieveSigninInfo() {
        ContentManager.sharedInstance.signinInfo(course.course_id) {
            (uuid, enable, total, user, signinID, error) in
            // MARK if error present HUD and return
            guard let cell = self.courseOverviewTableview.cellForRowAtIndexPath(Constants.SignInCellIndexPath) as? SignInTableViewCell else {return}
            
            if error != nil {
                cell.fail()
            } else {
                cell.successWithText("已签到： \(user) / \(total)")
            }
            
            self.uuid = NSUUID(UUIDString: uuid)?.UUIDString
            self.signinID = signinID
            self.isSigninEnabled = enable
            self.setupLocationManager()
        }
    }
    
    func submitSigninInfo() {
        ContentManager.sharedInstance.submitSignIn(course.course_id, signinID: signinID!, uuid: uuid!, deviceID: deviceID) {
            if $0 == nil {
                self.retrieveSigninInfo()
            } else {
                // present HUD
            }
        }
    }
    
    @IBAction func signIn(sender: UIButton) {
        guard let cell = courseOverviewTableview.cellForRowAtIndexPath(Constants.SignInCellIndexPath) as? SignInTableViewCell else {return}
        cell.activityIndicator.startAnimating()
        cell.signInButton.enabled = false
            
        if cell.tag == Constants.RefreshTag {
            retrieveSigninInfo()
        } else {
            submitSigninInfo()
        }
    }
}

extension CourseOverviewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // MARK: Data for the current course.
        switch indexPath.row {
        case Constants.Header.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Header.1) as! HeaderTableViewCell
            cell.setupWithImage(
                "Computer Networks",
                title: course.name,
                teacherNames: course.teacherNameString,
                term: course.term)
            return cell
        case Constants.SignIn.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SignIn.1) as! SignInTableViewCell
            cell.setup()
            return cell
        case Constants.Overview.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Overview.1) as! OverviewTableViewCell
            cell.setupWithText(course.introduction)
            return cell
        case Constants.ImportantDate.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ImportantDate.1) as! ExaminationTableViewCell
            cell.setupCell(course.midterm, finalExam: course.finalExam)
            return cell
        default:
            fatalError()
        }
    }
    
}

extension CourseOverviewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let spaceX = CGRectGetWidth(cell.frame) + CGFloat(indexPath.row) * Constants.SpaceInterval
        let cellFrame: CGRect = {
            var frame = cell.frame
            frame.origin.x = spaceX
            return frame
        }()
        let animationTime = fabs(spaceX / CGRectGetWidth(cellFrame) * Constants.AnimationTime)
        UIView.animateWithDuration(Double(animationTime)) {
            cell.frame.origin.x = 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CellHeights[indexPath.row]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.row == Constants.Overview.0 {
            performSegueWithIdentifier(Constants.CourseDescriptionSegueIdentifier, sender: cell)
        } else if indexPath.row == Constants.ImportantDate.0 {
            performSegueWithIdentifier(Constants.ImportantDateSegueIdentifier, sender: cell)
        }
    }
    
}

extension CourseOverviewController : CLLocationManagerDelegate {
    
    func setupLocationManager() {
        guard !isSigninEnabled && signinID != nil, let uuid = uuid else {
            return
        }
        
        let beaconUUID   = NSUUID(UUIDString: uuid)!
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
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

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    
    func setupWithImage(imageName: String? = "DefaultBookCover",
        title: String,
        teacherNames: String,
        term: String) {
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        titleLabel.text = title
        teacherNameLabel.text = teacherNames
        termLabel.text = term
    }
}

class SignInTableViewCell: UITableViewCell {
    
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
    
    func fail() {
        signInLabel.text = "已签到： 0 / 0"
        signInButton.enabled = true
        signInButton.setTitle("刷新", forState: .Normal)
        activityIndicator.stopAnimating()
        tag = 0
    }
}

class OverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var overviewLabel: UILabel!
    
    func setupWithText(text: String) {
        overviewLabel.text = text
    }
}

class ExaminationTableViewCell: UITableViewCell {
    
	@IBOutlet weak var midTermLabel: UILabel!
    @IBOutlet weak var finalExamLabel: UILabel!
    
	func setupCell(midterm: NSDate, finalExam: NSDate){
        let timeFormatter: NSDateFormatter = {
            let f = NSDateFormatter()
            f.locale = NSLocale(localeIdentifier: "zh_CN")
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()

		midTermLabel.text = "期中考试： " + timeFormatter.stringFromDate(midterm)
		finalExamLabel.text = "期末考试： " + timeFormatter.stringFromDate(finalExam)
	}
}