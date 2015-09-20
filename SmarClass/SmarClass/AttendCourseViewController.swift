//
//  AttendCourseViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class AttendCourseViewController: CloudAnimateTableViewController {

    var attendCourse: [String]!
    var courseList = [Course]() {
        didSet {
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "课程加载失败，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func retrieveCourseList() {
//        ContentManager.sharedInstance.allCourse(course_id) {
//            (success, courseList, message) in
//            DDLogDebug("\(success) \(message)")
//            self.courseList = courseList
//            self.animationDidEnd()
//        }
    }

}
