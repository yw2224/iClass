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
    var locationManager: CLLocationManager!
    var uuidString: String! // "BCEAD00F-F457-4E69-B32E-681251AC2048"
    var signin_id: String!
    var isBeaconFound = false

	var course: Course!
    
    @IBOutlet weak var courseOverviewTableview: UITableView! {
        didSet {
            courseOverviewTableview.tableFooterView = UIView(frame: CGRectZero)
        }
    }
	
    private struct Constants {
        static let Header = (0, "HeaderCell")
        static let SignIn = (1, "SignInCell")
        static let Overview = (2, "OverviewCell")
        static let ImportantDate = (3, "ExaminationCell")
        static let Error = (-1, "ErrorCell")
        static let CellHeights: [CGFloat] = [100, 42, 88, 88]
        static let SpaceInterval = 40.0
        static let AnimationTime = 0.5
        static let CourseDescriptionSegueIdentifier = "Course Description Segue"
        static let ImportantDateSegueIdentifier = "Important Date Segue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContentManager.sharedInstance.signinInfo(course.course_id) {
            (success, uuid, enable, total, user, signin_id, message) in
            println("\(success) \(uuid) \(enable) \(total) \(user) \(signin_id) \(message)")
//            setupLocationManager()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! UIViewController
        if let cdvc = dest as? CourseDescriptionViewController {
            cdvc.text = course.introduction
        } else if let cccvc = dest as? CourseCalendarContainerViewController {
            cccvc.startDate = course.startDate
            cccvc.endDate = course.endDate
            cccvc.midTerm = course.midterm
            cccvc.finalExam = course.finalExam
            cccvc.lectureTime = course.lectureTime.allObjects as! [LectureTime]
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
                imageName: "Computer Networks",
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
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Error.1) as! UITableViewCell
            return cell
        }
    }
    
}

extension CourseOverviewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var cellFrame = cell.frame
        let spaceX = Double(CGRectGetWidth(cellFrame)) + Double(indexPath.row) * Constants.SpaceInterval
        cellFrame.origin.x = CGFloat(spaceX)
        cell.frame = cellFrame
        let animationTime = fabs(spaceX / Double(CGRectGetWidth(cellFrame)) * Constants.AnimationTime)
        
        UIView.animateWithDuration(Constants.AnimationTime, animations: {
            cellFrame.origin.x = 0
            cell.frame = cellFrame
        })
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
        let beaconUUID   = NSUUID(UUIDString: uuidString!)!
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
        
        locationManager = CLLocationManager()
        
        if(locationManager.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager.requestAlwaysAuthorization()
        }
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
        
    func locationManager(manager: CLLocationManager!,
            didRangeBeacons beacons: [AnyObject]!,
            inRegion region: CLBeaconRegion!) {
                if beacons.count > 0 {
                    let nearestBeacon = beacons[0] as! CLBeacon
                    if nearestBeacon.proximity == .Unknown {
                        return
                    }
                    DDLogInfo("Ranging beacons")
                    isBeaconFound = true
                    manager.stopRangingBeaconsInRegion(region)
                    manager.stopUpdatingLocation()
                }
    }
        
    func locationManager(manager: CLLocationManager!,
        didEnterRegion region: CLRegion!) {
            DDLogInfo("Enter region")
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            sendLocalNotificationWithMessage("发现iBeacon，快打开App签到吧~", playSound: true)
    }
        
    func locationManager(manager: CLLocationManager!,
            didExitRegion region: CLRegion!) {
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
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover") ?? UIImage(named: "DefaultBookCover")
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
        signInButton.addTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
        activityIndicator.startAnimating()
    }
    
    func signIn(sender: UIButton) {
        activityIndicator.startAnimating()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            [weak self] in
            self?.activityIndicator.stopAnimating()
        }
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