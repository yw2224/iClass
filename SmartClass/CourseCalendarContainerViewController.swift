//
//  CourseCalendarContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/4.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CourseCalendarContainerViewController: UIViewController {

    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        guard let ccvc = segue.destinationViewController as? CourseCalendarViewController else {return}
        ccvc.courseID = courseID
    }

}
