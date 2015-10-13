//
//  MainHomeViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class MainHomeViewController: CloudAnimateTableViewController {
    
    // MARK: synchronized with each other in case Core Date Object will fault over time
    var courseID = [String]()
    var courseList = [Course]() {
        didSet {
            courseID = courseList.map {
                return $0.course_id
            }
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "课程库为空。\n请添加课程/下拉刷新重试！"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Course Cell"
        static let CourseCellHeight : CGFloat = 88.0
        static let PresentCourseOverviewSegueIdentifier = "Present Course Overview Segue"
    }
    
    // MARK: Inited in the prepareForSegue()
    weak var delegate: CenteralViewDelegate?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.CourseCellHeight
        
        retrieveCourseList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.userInteractionEnabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
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
        retrieveCourseListFromCache()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? TabBarController {
            let indexPath = tableView.indexPathForSelectedRow!
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CourseTableViewCell
            let course = courseList[indexPath.row]
            
            dest.delegate = dest
            dest.courseID = course.course_id
            
            if let covc = dest.contentViewController(0) as? CourseOverviewController {
                covc.courseID = course.course_id
            }
            if let segue = segue as? CrossDissolveSegue {
                segue.image = cell.bookCover.image
            }
        } else if let dest = segue.destinationViewController as? NavigationController {
            if let acvc = dest.contentViewController(0) as? AttendCourseViewController {
                acvc.attendCourseID = courseList.map {
                    return $0.course_id
                }
            }
        }
	}
    
    // MARK: Actions
    @IBAction func toggleLeftPanel(sender: UIBarButtonItem) {
        delegate?.toggleLeftPanel(true)
    }
    
    func disableTableView() {
        tableView.userInteractionEnabled = false
    }
    
    func enableTableView() {
        tableView.userInteractionEnabled = true
    }
    
    func retrieveCourseList() {
        ContentManager.sharedInstance.courseList {
            (courseList, error) in
            self.courseList = courseList
            self.animationDidEnd()
        }
    }
    
    func retrieveCourseListFromCache() {
        let predicate = NSPredicate(format: "course_id IN %@", courseID)
        courseList = CoreDataManager.sharedInstance.courseList(predicate)
    }
}

// MARK: RefreshControlHook
extension MainHomeViewController {
    
    override func animationDidStart() {
        super.animationDidStart()

        // Remember to call 'animationDidEnd' in the following code
        retrieveCourseList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
    
}

// MARK: UITableViewDatasource
extension MainHomeViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! CourseTableViewCell
        let course = courseList[indexPath.row]
        cell.setupUIWithImage(
            "Computer Networks",
            courseTitle: course.name,
            teacherName: course.teacherNameString,
            badgeNum: 0
        )
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension MainHomeViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.userInteractionEnabled = false
        performSegueWithIdentifier(Constants.PresentCourseOverviewSegueIdentifier, sender: cell)
    }
}

class CourseTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    
    func setupUIWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        courseName.text = course
        teacherLabel.text = teacher
        badgeView.badgeNum = badge
    }
    
    func setBadgeNum(badgeNum: Int) {
        badgeView.badgeNum = badgeNum
    }
}
