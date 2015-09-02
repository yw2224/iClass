//
//  MainHomeViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MainHomeViewController: CloudAnimateTableViewController {

    private struct Constants {
        static let CellIdentifier = "Course Cell"
        static let CourseCellHeight : CGFloat = 88.0
    }
    
    var courseList = [Course]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var delegate: CenteralViewDelegate?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.CourseCellHeight
        
        retrieveCourseList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
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
//        if let dest = segue.destinationViewController as? TabBarController
//		{
//			dest.delegate = dest
//			if let covc = dest.contentViewController(0) as? CourseOverviewController {
//				let indexPath = self.courseTableView.indexPathForSelectedRow()
//				if let course = courseList?[indexPath!.section] {
//					covc.course = course
//					dest.course = course
//				}
//			}
//			
//		}
	}
    
    // MARK: Actions
    @IBAction func toggleLeftPanel(sender: UIBarButtonItem) {
        delegate?.toggleLeftPanel(true)
    }
    
    @IBAction func addOrRemoveCourse(sender: UIBarButtonItem) {
        println("add or remove course")
    }
    
    func disableTableView() {
        tableView.userInteractionEnabled = false
    }
    
    func enableTableView() {
        tableView.userInteractionEnabled = true
    }
    
    func retrieveCourseList() {
        ContentManager.sharedInstance.courseList {
            [weak self] (success, courseList, message) in
            DDLogDebug("\(success) \(message)")
            self?.courseList = courseList
            self?.animationDidEnd()
        }
    }
}

extension MainHomeViewController: RefreshControlHook {
    override func animationDidStart() {
        super.animationDidStart()

        // Remember to call 'animationDidEnd' in the following code
        retrieveCourseList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

extension MainHomeViewController: UITableViewDataSource {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! CourseTableViewCell
        let course = courseList[indexPath.row]
        let teacherNameString: String = {
            var ret = ""
            var teacherNameArray: [String] = {
                var array = [String]()
                for teacherName in course.teacherNames.allObjects {
                    array.append(teacherName.name)
                }
                array.sort() {
                    return $0 < $1
                }
                return array
            }()
            for teacherName in teacherNameArray {
                ret += "\(teacherName)\t"
            }
            return ret
        }()
        cell.setupUIWithImage(
            imageName: "Computer Networks",
            courseTitle: course.name,
            teacherName: teacherNameString,
            badgeNum: 0
        )
        return cell
    }
}

extension MainHomeViewController: UITableViewDelegate {
    
}


class CourseTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeView!
    func setupUIWithImage(imageName: String = "DefaultBookCover", courseTitle course: String, teacherName teacher: String, badgeNum badge: Int) {
        if let image = UIImage(named: imageName) {
            bookCover.image = image
        } else {
            bookCover.image = UIImage(named: "DefaultBookCover")
        }
        courseName.text = course
        teacherLabel.text = teacher
        badgeView.badgeNum = badge
    }
    
    func setBadgeNum(badgeNum: Int) {
        badgeView.badgeNum = badgeNum
    }
}

// MARK: WHY THESE CODE ARE IN VIEW CONTROLLERS???
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
