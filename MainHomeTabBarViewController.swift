//
//  mainHomeTabBarViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/11/23.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit

class mainHomeTabBarViewController: UITabBarController {

    
    //weak var delegate: CenteralViewDelegate?
    /*@IBAction func toggleLeftPanel(sender: UIBarButtonItem) {
        delegate?.toggleLeftPanel(true)
    }*/
    var attendOrQuitCourse: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的课程"
        self.tabBar.tintColor = GlobalConstants.BarTintColor
        // Do any additional setup after loading the view.
       
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disableTableView() {
        view.userInteractionEnabled = false
    }
    
    func enableTableView() {
        view.userInteractionEnabled = true
    }
    @IBAction func unwindToMainHomeTabBarPage(segue: UIStoryboardSegue) {
        // Force refresh the data
        
    }
  
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        switch item.title!
        {
        case "课程":
            self.navigationItem.title = "课程"
        case "通知":
            self.navigationItem.title = "通知"
        case "小组":
            self.navigationItem.title = "小组"
        default: break
        }
        
    }
    
    var courseID = [String]()
    var courseList = [Course]() {
        didSet {
            courseID = courseList.map {
                return $0.course_id
            }//把courseList中每个元素的.course_id赋给courseID对应的项
            //tableView.reloadData()
        }
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let dest = segue.destinationViewController as? AttendCourseViewController
        {
            print("reach here! preparing for segue to AttendCourseViewController...")
            dest.attendCourseID = courseList.map
            {
                return $0.course_id
            }
            dest.attendCourse = courseList
        }
        
    }

    
}
