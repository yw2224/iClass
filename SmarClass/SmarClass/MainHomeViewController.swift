//
//  MainHomeViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
//import CocoaLumberjack

class MainHomeViewController: UIViewController {

    private struct Constants {
        static let CellIdentifier = "CourseCell"
        static let CourseCellHeight : CGFloat = 88.0
    }
    
	var courseList = [Course]()
	var teacherList = [User]()
    
    var delegate: CenteralViewDelegate?
    
    var editButton: UIButton!
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var courseTableView: UITableView! {
        didSet {
            courseTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		courseTableView.addSubview(refreshControl)
        
		refreshControl.tintColor = GlobalConstants.RefreshControlColor
		refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
        
        editButton = UIButton(frame: CGRectZero)
        editButton.setBackgroundImage(UIImage(named: "AddOrRemove"), forState: .Normal)
        editButton.sizeToFit()
        editButton.addTarget(self, action: "addOrRemoveCourse:", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        editButton.startGlow(UIColor.yellowColor())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigations
//    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        let crossDisappearSegue = CrossDisappear(identifier: identifier, source: fromViewController, destination: toViewController)
//        return  crossDisappearSegue
//    }
    
    @IBAction func unwindToHomePage(segue: UIStoryboardSegue) {
//        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? TabBarController
		{
			dest.delegate = dest
			if let covc = dest.contentViewController(0) as? CourseOverviewController {
//				let indexPath = self.courseTableView.indexPathForSelectedRow()
//				if let course = courseList?[indexPath!.section] {
//					covc.course = course
//					dest.course = course
//				}
			}
			
		}
	}
    
    // MARK: Actions
    @IBAction func toggleLeftPanel(sender: UIBarButtonItem) {
        delegate?.toggleLeftPanel(true)
    }
    
    func handleRefresh(sender: UIRefreshControl) {
        let delayInSeconds = 2.0
        let delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW,
            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), {
            sender.endRefreshing()
        })
    }
    
    func addOrRemoveCourse(sender: UIButton) {
        delegate?.collapseLeftPanel()
    }
    
    // MARK: Assistant functions
    func disableTableView() {
        courseTableView.userInteractionEnabled = false
    }
    
    func enableTableView() {
        courseTableView.userInteractionEnabled = true
    }
}

extension MainHomeViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! UITableViewCell
        if let courseCell = cell as? CourseTableViewCell {
            courseCell.setupUIWithImage(
                UIImage(named: "Computer Networks"),
                courseTitle: "计算机网络概论",
                teacherName: "严伟", badgeNum: 10000
            )
            return courseCell
        }
        return cell
    }
}

extension MainHomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CourseCellHeight
    }
}


class CourseTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    func setupUIWithImage(image: UIImage?, courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        if let theImage = image {
            bookCover.image = image
        } else {
            bookCover.image = UIImage(named: "DefaultBookCover")
        }
        courseName.text = course
        teacherLabel.text = teacher
        badgeView.badgeNum = badge
        accessoryType = .DisclosureIndicator
    }
    
    func setBadgeNum(badgeNum: Int) {
        badgeView.badgeNum = badgeNum
    }
}

// MARK: WHY THESE CODE IN VIEW CONTROLLERS???
//func getCourseTeacherList(){
//    if courseList?.count > 0 {
//        for course in courseList!{
//            let courseId = course.id.integerValue
//            let teacherId = course.teacher.integerValue
//            //				SCRequest.courseTeacher(teacherId)
//            //					{ (_, _, JSON, _) -> Void in
//            //						if JSON?.valueForKey("result") as? Bool == true{
//            //							let teacherList = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.User) as? [User]
//            //							if teacherList?.count > 0 {
//            //								self.teacherList?.append(teacherList![0])
//            //								self.courseTableView.reloadData()
//            //							}
//            //						}
//            //				}
//        }
//    }
//}
//
//func getTeacherNameById(teacherId:Int)->String?{
//    //		if let teacher = ModelCRUD.teacherById(teacherId) {
//    //			if count(teacher.firstname) > 0 {
//    //				return teacher.firstname
//    //			}
//    //			return teacher.username
//    //		}
//    return nil
//}
