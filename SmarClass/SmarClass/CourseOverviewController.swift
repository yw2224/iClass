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

//import MBProgressHUD

protocol SignInDelegate{
	func signInClicked(cell:SignInTableViewCell)
}
class CourseOverviewController: UIViewController {
	//MARK:location manager
	var locationManager: CLLocationManager!
	
	let uuid = NSUUID(UUIDString: "BCEAD00F-F457-4E69-B32E-681251AC2048")
//	NSUUID(UUIDString: "BCEAD00F-F457-4E69-B32E-681251AC2048")
	let identifier = "com.pku.cocoa.AirLocate"
//	"net.pku.cocoa.cookbook"

    //MARK:data definition
	var course : Course? {
		didSet{
			println("course overview course did set")
			getCourseTeacher()
			getCourseSignId()
			if let title = course?.name {
				self.navigationItem.title = title
				self.view.reloadInputViews()
				
			}
		}
	}
	var teacher : User?{
		didSet{
			println("course teacher did set")
			if self.isViewLoaded() && self.view.window != nil{
				self.courseOverviewTableview.reloadData()
			}
		}
	}
	var courseSignId :Int?{
		didSet{
			println("courseSignId did set")
		}
	}
    let courseIntroduction = "A computer network or data network is a telecommunications network which allows computers to exchange data. In computer networks, networked computing devices pass data to each other along data connections (network links). Data is transferred in the form of packets. The connections between nodes are established using either cable media or wireless media. The best-known computer network is the Internet."
    
    @IBOutlet weak var courseOverviewTableview: UITableView! {
        didSet {
            courseOverviewTableview.dataSource = self
            courseOverviewTableview.delegate = self
            courseOverviewTableview.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    private var viewFirstAppeared = false
	
    private struct Constants {
        static let Header = (0, "HeaderCell")
        static let SignIn = (1, "SignInCell")
        static let Overview = (2, "OverviewCell")
        static let Examination = (3, "ExaminationCell")
        static let Error = (-1, "ErrorCell")
        static let CellHeights: [CGFloat] = [136, 42, 88, 88]
        static let SpaceInterval = 30.0
        static let AnimationTime = 0.5
//		enum ErrorCode{
//			case AlreadySignIn = 1001
//			case
//		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		let region = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
		locationManager.startRangingBeaconsInRegion(region)

    }
	
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        viewFirstAppeared = true
        courseOverviewTableview.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
	func getCourseTeacher(){
//		if let course = self.course {
//			let teacherId = course.teacher.integerValue
//			SCRequest.courseTeacher(teacherId)
//				{ (_, _, JSON, _) -> Void in
//					if JSON?.valueForKey("result") as? Bool == true{
//						let teacherList = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.User) as? [User]
//						if teacherList?.count > 0 {
//							self.teacher = teacherList![0]
//							self.courseOverviewTableview.reloadData()
//						}
//					}
//			}
//		}
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
			if startImmediately{
				manager.startUpdatingLocation()
			}
		}
	}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

extension CourseOverviewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !viewFirstAppeared {
            return 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewFirstAppeared {
            return 0
        }
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // MARK: Data for the current course.
        switch indexPath.row {
        case Constants.Header.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Header.1) as! HeaderTableViewCell
//            cell.setupWithImage("Computer Networks", title: "Computer Networks", detailedText: "PKU Fall 2015", description: "Wei Yan")
//			if let course = self.course {
//				if let teacher = self.teacher {
//					var desc = teacher.username
//					if count( teacher.firstname ) > 0 {
//						desc = teacher.firstname
//					}
//					cell.setupWithImage("Computer Networks", title: course.name , detailedText: course.term, description: desc)
//				}else{
//					cell.setupWithImage("Computer Networks", title: course.name , detailedText: course.term, description: course.teacher.stringValue)
//				}
//			}
            return cell
        case Constants.SignIn.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SignIn.1) as! SignInTableViewCell
			cell.delegate = self
            cell.setup()
            return cell
        case Constants.Overview.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Overview.1) as! OverviewTableViewCell
			if let course = self.course {
				cell.setupWithText("123123123123123")
			}
            return cell
        case Constants.Examination.0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Examination.1) as! ExaminationTableViewCell
			if let course = self.course{
				
					println(course)
					let midtermString :NSString = "123123"
					let finaltermString :NSString = "123123123"
					let midterm = NSDate(timeIntervalSince1970: midtermString.doubleValue)
					let finalterm = NSDate(timeIntervalSince1970: finaltermString.doubleValue)
					cell.configureCell(midterm, finalterm: finalterm)
			
			}
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Error.1) as! UITableViewCell
            return cell
        }
    }
}

extension CourseOverviewController: UITableViewDelegate {
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        var cellFrame = cell.frame
//        let spaceX = Double(CGRectGetWidth(cellFrame)) + Double(indexPath.row) * Constants.SpaceInterval
//        cellFrame.origin.x = CGFloat(spaceX)
//        cell.frame = cellFrame
//        let animationTime = fabs(spaceX / Double(CGRectGetWidth(cellFrame)) * Constants.AnimationTime)
//        
//        UIView.animateWithDuration(Constants.AnimationTime, delay: 0, options: .CurveEaseOut, animations: {
//            cellFrame.origin.x = 0
//            cell.frame = cellFrame
//        }, completion: nil)
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CellHeights[indexPath.row]
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
extension CourseOverviewController : SignInDelegate{
	func signInClicked(cell: SignInTableViewCell) {
		println("signIn clicled")
		self.signInToServer(cell)
	}
}

class HeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailedTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setupWithImage(image: String, title: String, detailedText: String, description des: String) {
        if let theImage = UIImage(named: image) {
            bookCover.image = theImage
        } else {
            bookCover.image = UIImage(named: "Unknown")!
        }
        
        titleLabel.text = title
        detailedTextLabel.text = detailedText
        descriptionLabel.text = des
    }
    
}

class SignInTableViewCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
	var delegate : SignInDelegate?
    func setup() {
        // Get SignIn times from the server
        signInLabel.text = "已签到： 0 / 0"
        signInButton.addTarget(self, action: "signIn:", forControlEvents: .TouchUpInside)
    }
    
    func signIn(sender: UIButton) {
		delegate?.signInClicked(self)
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
	@IBOutlet weak var finalTermLabel: UILabel!
	
	@IBOutlet weak var midTermLabel: UILabel!
	func configureCell(midterm:NSDate,finalterm:NSDate){
		let timeFormatter = NSDateFormatter()
		timeFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
		timeFormatter.dateFormat = "yyyy-MM-dd"

		midTermLabel.text = "期中考试:" + timeFormatter.stringFromDate( midterm)
		finalTermLabel.text = "期末考试:" + timeFormatter.stringFromDate(finalterm)
	}
}