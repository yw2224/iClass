//
//  CourseCalendarContainerViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/4.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CourseCalendarContainerViewController: UIViewController {

    var lectureTime: [LectureTime]! {
        didSet {
            lectureTime.sortInPlace {
                return $0.weekday < $1.weekday
            }
        }
    }
    var startDate: NSDate!
    var endDate: NSDate!
    var midTerm: NSDate?
    var finalExam: NSDate?
    
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
        let dest = segue.destinationViewController 
        if let ccvc = dest as? CourseCalendarViewController {
            ccvc.startDate = startDate
            ccvc.endDate = endDate
            ccvc.midTerm = midTerm
            ccvc.finalExam = finalExam
            ccvc.lectureTime = lectureTime
        }
    }

}
