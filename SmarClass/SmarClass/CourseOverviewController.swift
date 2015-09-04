//
//  CourseOverviewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import UIKit

class CourseOverviewController: UIViewController {
    
	var locationManager: CLLocationManager!
	let uuid = NSUUID(UUIDString: "BCEAD00F-F457-4E69-B32E-681251AC2048")
	let identifier = "com.pku.cocoa.AirLocate"

	var course: Course!
    
	var courseSignId :Int? {
		didSet{
			println("courseSignId did set")
		}
	}
    
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
        
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		let region = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
		locationManager.startRangingBeaconsInRegion(region)
    }
    
	func getCourseSignId(){
//		if let course = self.course {
//			SCRequest.courseSignId(course.id.integerValue)
//				{ (_, _, JSON, _) -> Void in
//					if JSON?.valueForKey("result") as? Bool == true {
//						if let signId = JSON?.valueForKey("signId") as? Int{
//							self.courseSignId = signId
//						}
//				}
//			}
//		}
	}
    
	func signInToServer(cell:SignInTableViewCell){
//		if let signId = self.courseSignId {
//			SCRequest.signToServer(signId)
//				{ (_, _, JSON, _) -> Void in
//					println(JSON)
//					if JSON?.valueForKey("result") as? Bool == true
//					{
//						println(JSON)
//						self.showSignInSuccess()
//						///显示签到时间
//						let now = NSDate()
//						let timeformatter = NSDateFormatter()
//						timeformatter.locale = NSLocale(localeIdentifier: "zh_CN")
//						timeformatter.dateFormat = "MM-dd HH:mm"
//						
//						cell.signInLabel.text = "已签到：" + timeformatter.stringFromDate(now)
//					}//end if
//					else {
//						let code = JSON?.valueForKey("code") as? Int
////						self.showSignInFailed(code)
//					}
//			}
//		}
	}
    
	func showSignInSuccess(){
//		let hud = MBProgressHUD()
//		hud.mode = MBProgressHUDMode.Text
//		hud.labelText = "签到成功"
//		hud.showAnimated(true,
//			whileExecutingBlock: { () -> Void in
//			NSThread.sleepForTimeInterval(1.0)
//		}) { () -> Void in
//			//do nothing
//		}
	}
    
	func showSignInFailed(code:Int){
//		switch code {
//			case
//		}
	}
    
	func createLocationManager(startImmediately: Bool){
		let locationManager: CLLocationManager? = CLLocationManager()
		if let manager = locationManager{
			println("Successfully created the location manager")
			manager.delegate = self
			if startImmediately {
				manager.startUpdatingLocation()
			}
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

//MARK:ibeacon delegate
extension CourseOverviewController : CLLocationManagerDelegate{
	func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
		if beacons.count > 0 {
			
			print("Found a beacon with the proximity of = ")
		}
		
		for beacon in beacons as! [CLBeacon] {
			switch beacon.proximity {
			case .Far:
				println("Far")
			case .Immediate:
				println("Immediate")
			case .Near:
				println("Near")
			default:
				println("Unknown")
			}
		}
		
		
	}
	
	func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
		println(region.identifier)
		let controller = UIAlertController(title: "Enter", message: "ibeacon find", preferredStyle: .Alert)
		controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		presentViewController(controller, animated: true, completion: nil)
	}
	
	func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
		println(region.identifier)
		let controller = UIAlertController(title: "Exit", message: "ibeacon lost", preferredStyle: .Alert)
		controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		presentViewController(controller, animated: true, completion: nil)
	}

}

//MARK:sign in to server delegate
//extension CourseOverviewController : SignInDelegate{
//	func signInClicked(cell: SignInTableViewCell) {
//		println("signIn clicled")
//		self.signInToServer(cell)
//	}
//}

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
//	var delegate : SignInDelegate?
    func setup() {
        // Get SignIn times from the server
        signInLabel.text = "已签到： 0 / 0"
        signInButton.addTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
    }
    
    func signIn(sender: UIButton) {
//		delegate?.signInClicked(self)
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