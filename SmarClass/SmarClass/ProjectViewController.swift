//
//  ProjectViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProjectViewController: CloudAnimateTableViewController {
    
//    // MARK: synchronized with each other in case Core Date Object will fault over time
//    var courseID = [String]()
//    var courseList = [Course]() {
//        didSet {
//            courseID = courseList.map() {
//                return $0.course_id
//            }
//            tableView.reloadData()
//        }
//    }
//    override var emptyTitle: String {
//        get {
//            return "尚无课程项目，请下拉刷新重试！"
//        }
//    }
//    
//    private struct Constants {
//        static let CellIdentifier = "Course Cell"
//        static let CourseCellHeight : CGFloat = 88.0
//        static let PresentCourseOverviewSegueIdentifier = "Present Course Overview Segue"
//    }
//    
//    // MARK: Life cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        tableView.tableFooterView = UIView(frame: CGRectZero)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = Constants.CourseCellHeight
//        
//        retrieveProjectList()
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        tableView.userInteractionEnabled = true
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        CoreDataManager.sharedInstance.saveInBackground()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//    }
//    
//    @IBAction func unwindToPorjectList(segue: UIStoryboardSegue) {
//        
//    }
//    
//    func retrieveProjectList() {
//        ContentManager.sharedInstance.courseList {
//            (courseList, error) in
//            self.courseList = courseList
//            self.animationDidEnd()
//        }
//    }
}
//
//// MARK: RefreshControlHook
//extension ProjectViewController {
//    
//    override func animationDidStart() {
//        super.animationDidStart()
//        
//        // Remember to call 'animationDidEnd' in the following code
//        retrieveProjectList()
//    }
//    
//    override func animationDidEnd() {
//        super.animationDidEnd()
//    }
//    
//}
//
//// MARK: UITableViewDatasource
//extension ProjectViewController {
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! CourseTableViewCell
//        let course = courseList[indexPath.row]
//        cell.setupUIWithImage(
//            "Computer Networks",
//            courseTitle: course.name,
//            teacherName: course.teacherNameString,
//            badgeNum: 0
//        )
//        return cell
//    }
//    
//}
//
//// MARK: UITableViewDelegate
//extension ProjectViewController {
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
////        let cell = tableView.cellForRowAtIndexPath(indexPath)!
////        tableView.userInteractionEnabled = false
////        performSegueWithIdentifier(Constants.PresentCourseOverviewSegueIdentifier, sender: cell)
//    }
//}
//
//class ProjectTableViewCell : UITableViewCell {
//    
//    @IBOutlet weak var bookCover: UIImageView!
//    @IBOutlet weak var courseName: UILabel!
//    @IBOutlet weak var teacherLabel: UILabel!
//    @IBOutlet weak var badgeView: BadgeView!
//    
//    func setupUIWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
//        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
//        courseName.text = course
//        teacherLabel.text = teacher
//        badgeView.badgeNum = badge
//    }
//    
//    func setBadgeNum(badgeNum: Int) {
//        badgeView.badgeNum = badgeNum
//    }
//}