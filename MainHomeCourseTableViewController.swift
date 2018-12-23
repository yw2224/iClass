//
//  MainHomeCourseTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/11/23.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainHomeCourseTableViewController:  CloudAnimateTableViewController {

    var courseID = [String]()
    var courseList = [Course]() {
        didSet {
            courseID = courseList.map {
                return $0.course_id
            }//把courseList中每个元素的.course_id赋给courseID对应的项
            tableView.reloadData()
        }
    }
     
    override var emptyTitle: String {
        get {
            return "课程库为空。\n请添加课程/下拉刷新重试！"
        }
    }
    
    private struct Constants {
        static let CellIdentifier                      = "CourseCell Identifier"
        static let CourseCellHeight: CGFloat           = 450.0
        static let CourseOverviewSegueIdentifier       = "Course Overview Segue"
        static let AttendCourseSegueIdentifier         = "Attend Course Segue"
    }
    
    weak var delegate: CenteralViewDelegate?
    var attendOrQuitCourse: UIButton!
    //var attendOrQuitCourse: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRectZero)
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.CourseCellHeight
    
        attendOrQuitCourse = UIButton()
        
        attendOrQuitCourse.setBackgroundImage(UIImage(named: "add"), forState: .Normal)
        attendOrQuitCourse.sizeToFit()
        attendOrQuitCourse.addTarget(self, action: "attendCourseButtonTapped:", forControlEvents: .TouchUpInside)
        
        //let navigationBarButtonItem = UINavigationItem(title: attendOrQuitCourse)
        let barButtonItem = UIBarButtonItem(customView: attendOrQuitCourse)
        
        navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
        self.navigationItem.title = "我的课程"
     
        retrieveCourseList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        enableTableView()
        attendOrQuitCourse.startGlow(UIColor.flatYellowColor())
    }
    
       @IBAction func unwindCourseListPage(segue: UIStoryboardSegue) {
        // Force refresh the data
        courseList.removeAll()
        retrieveCourseList()
    }
    
    func retrieveCourseList() {
        ContentManager.sharedInstance.courseList {
            (courseList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.CourseListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            self.courseList = courseList
            self.animationDidEnd()
        }
        
        
        ContentManager.sharedInstance.studentinfo (ContentManager.UserID,block: {
            (userInfoList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.CourseListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            //self.userInfoList = userInfoList
            self.animationDidEnd()
            
        })
        print(courseList)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let identifier = segue.identifier
        {
            switch identifier
            {
            case "ShowCourseOverview":
                    if let dest = segue.destinationViewController as? UINavigationController
                    {
                        if let courseOverviewTabelViewController = dest.contentViewController(0) as? CourseOverviewTableViewController
                        {
                            let indexPath = tableView.indexPathForSelectedRow!
                            //let cell = tableView.cellForRowAtIndexPath(indexPath) as! MainHomeCourseTableViewCell
                            let course = courseList[indexPath.row]
                            //courseOverviewTabelViewController.delegate = dest
                            courseOverviewTabelViewController.courseID = course.course_id
                            courseOverviewTabelViewController.courseName = course.name
                            courseOverviewTabelViewController.currentCourse = course
                        }
                    }
            case "Attend Course Segue":
                if let dest = segue.destinationViewController as? AttendCourseViewController
                {
                    dest.attendCourseID = courseList.map
                    {
                          return $0.course_id
                    }
                }
            default: break
            }
        }
        
            /*
            if let covc = dest.contentViewController(0) as? CourseOverviewController {
                covc.courseID = course.course_id
            }*/
         /*   if let segue = segue as? CrossDissolveSegue {
                segue.image = cell.bookCover.image
            }*/
         /*else if let dest = segue.destinationViewController as? NavigationController {
            if let acvc = dest.contentViewController(0) as? AttendCourseViewController {
                acvc.attendCourseID = courseList.map {
                    return $0.course_id
                }
            }
        }*/
    }
    
    @IBAction func toggleLeftPanel(sender: UIBarButtonItem) {
         delegate?.toggleLeftPanel(true)
    }
    
    func disableTableView() {
        tableView.userInteractionEnabled = false
    }
    
    func enableTableView() {
        tableView.userInteractionEnabled = true
    }
    
    func attendCourseButtonTapped(sender: UIButton) {
        performSegueWithIdentifier(Constants.AttendCourseSegueIdentifier, sender: sender)
    }
    
}

extension MainHomeCourseTableViewController {
 
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveCourseList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
    
}


extension MainHomeCourseTableViewController {
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        CoreDataManager.sharedInstance.saveInBackground()
        attendOrQuitCourse.stopGlow()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 2
        return courseList.count
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell Identifier", forIndexPath: indexPath) as! MainHomeCourseTableViewCell
         let course = courseList[indexPath.row]
         cell.setupWithImage(
         "Computer Networks",
         courseTitle: course.name,
         teacherName: course.teacherNames,
         badgeNum: 0
         )
        return cell
    }

}

class MainHomeCourseTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    
    func setupLabel(course: String, teacher: String) {
        courseName.text = course
        teacherLabel.text = teacher
        
    }
    
    func setupWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        //bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        courseName.text = course
        teacherLabel.text = teacher
        //badgeView.badgeNum = badge
    }
    
    func setBadgeNum(badgeNum: Int) {
        badgeView.badgeNum = badgeNum
    }
}


