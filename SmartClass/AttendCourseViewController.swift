//
//  AttendCourseViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import SVProgressHUD
import UIKit

class AttendCourseViewController: CloudAnimateTableViewController {

    var attendCourse = [Course]()
    var courseList = [Course]()
    
    override var emptyTitle: String {
        get {
            return "课程加载失败，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Course Cell"
        static let CourseCellHeight : CGFloat = 88.0
        static let DissmissAttendCourseSegueIdentifier = "Dissmiss Attend Course Segue"
    }
    
    // MARK: Inited in the prepareForSegue()
    var attendCourseID: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let superView = navigationController?.view {
            let vibrancyView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            let topToTLG = NSLayoutConstraint(item: vibrancyView, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1.0, constant: 0.0)
            let bottomToBLG = NSLayoutConstraint(item: vibrancyView, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
            let leftToLeading = NSLayoutConstraint(item: vibrancyView, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
            let rightToTrailing = NSLayoutConstraint(item: vibrancyView, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            vibrancyView.translatesAutoresizingMaskIntoConstraints = false
            superView.insertSubview(vibrancyView, atIndex: 0)
            superView.addConstraints([topToTLG, bottomToBLG, leftToLeading, rightToTrailing])
        }
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.CourseCellHeight
        tableView.setEditing(true, animated: true)
        
        retrieveCourseList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        courseList.forEach {
            $0.MR_deleteEntity()
        }
        CoreDataManager.sharedInstance.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func attendCourse(sender: UIBarButtonItem) {
        SVProgressHUD.showWithStatus(GlobalConstants.AttendingCoursePrompt)
        attendCourseAtSection(0, row: 0)
        
    }
    
    func attendCourseAtSection(section: Int, row: Int) {
        if section >= 2 {
            SVProgressHUD.popActivity()
            performSegueWithIdentifier(Constants.DissmissAttendCourseSegueIdentifier, sender: self) // Recursion exit
            return
        }
        
        if row >= tableView.numberOfRowsInSection(section) {
            attendCourseAtSection(section + 1, row: 0)
            return
        }
        
        let block: (NetworkErrorType?) -> Void = {
            error in
            if error == nil {
                self.attendCourseAtSection(section, row: row + 1)
            } else {
                SVProgressHUD.popActivity()
                
                if case .NetworkUnauthenticated = error! {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.AttendCourseErrorPrompt)
                } else if case NetworkErrorType.NetworkForbiddenAccess = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.AttendCourseErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
                return
            }
        }
        if section == 0 {
            let course = attendCourse[row]
            ContentManager.sharedInstance.attendCourse(course.course_id, block: block)
        } else if section == 1 {
            let course = courseList[row]
            ContentManager.sharedInstance.quitCourse(course.course_id, block: block)
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Navigation back
        if let _ = segue.destinationViewController as? MainHomeViewController {
            courseList.forEach { // Delete extra entities
                $0.MR_deleteEntity()
            }
        }
    }
    
    func retrieveCourseList() {
        ContentManager.sharedInstance.allCourse {
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
            
            self.attendCourse.removeAll()
            self.courseList = courseList.filter {
                if self.attendCourseID.indexOf($0.course_id) != nil {
                    self.attendCourse.append($0)
                    return false
                }
                return true
            }
            self.tableView.reloadData()
            self.animationDidEnd()
        }
    }

}

// MARK: RefreshControlHook
extension AttendCourseViewController {
    
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
extension AttendCourseViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return attendCourse.count
        }
        return courseList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! CourseTableViewCell2
        let course = (indexPath.section == 0) ? attendCourse[indexPath.row] : courseList[indexPath.row]
        cell.setupUIWithImage(
            "Computer Networks",
            courseTitle: course.name,
            teacherName: course.teacherNameString)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "已选课程"
        } else if section == 1 {
            return "备选课程"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else if indexPath.section == 1 {
            return .Insert
        }
        return .None
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let course = sourceIndexPath.section == 0 ? attendCourse[sourceIndexPath.row] : courseList[sourceIndexPath.row]
        sourceIndexPath.section == 0 ? attendCourse.removeAtIndex(sourceIndexPath.row) : courseList.removeAtIndex(sourceIndexPath.row)
        destinationIndexPath.section == 0 ? attendCourse.insert(course, atIndex: destinationIndexPath.row) : courseList.insert(course, atIndex: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        if indexPath.section == 0 && editingStyle == .Delete {
            let course = attendCourse[row]
            attendCourse.removeAtIndex(row)
            courseList.insert(course, atIndex: 0)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Left)
            tableView.endUpdates()
        } else if indexPath.section == 1 && editingStyle == .Insert {
            let course = courseList[row]
            courseList.removeAtIndex(row)
            attendCourse.insert(course, atIndex: 0)
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Left)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.endUpdates()
        }
    }
}

// MARK: UITableViewDelegate
extension AttendCourseViewController {

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

class CourseTableViewCell2 : UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    
    func setupUIWithImage(imageName: String? = "DefaultBookCover", courseTitle course: String, teacherName teacher: String) {
        bookCover.image = UIImage(named: imageName ?? "DefaultBookCover")
        courseName.text = course
        teacherLabel.text = teacher
    }
}

