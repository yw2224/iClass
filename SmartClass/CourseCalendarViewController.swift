//
//  CourseCalendarViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/3.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import PDTSimpleCalendar

class CourseCalendarViewController: PDTSimpleCalendarViewController {
    
    enum DateType {
        case MidTerm
        case FinalExam
        case Today
        case Lecture
    }
    
    var lectureTime = [LectureTime]() {
        didSet {
            lectureTime.sortInPlace() {
                return $0.weekday.integerValue < $1.weekday.integerValue
            }
        }
    }
    var importantDate = [String: DateType]()
    let formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "zh_CN")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    private struct Constants {
        static let Sunday = 7
    }
    
    // MARK: Inited in the prepareForSegue()
    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let course = CoreDataManager.sharedInstance.course(courseID)
        firstDate = course.startDate
        lastDate = course.endDate
        lectureTime = course.lectureTime.allObjects as! [LectureTime]
        
        func countLectureTime(startDate: NSDate, endDate: NSDate) {
            importantDate[formatter.stringFromDate(course.midterm)] = .MidTerm
            importantDate[formatter.stringFromDate(course.finalExam)] = .FinalExam
            importantDate[formatter.stringFromDate(NSDate())] = .Today
            
            let weekDayConvert: (Int) -> Int = {
                let addOne = 1 + $0
                return addOne > 7 ? addOne - 7 : addOne
            }
            
            let calendar = NSCalendar.currentCalendar()
            if let refer = calendar.nextDateAfterDate(startDate,
                matchingUnit: .Weekday,
                value: weekDayConvert(Constants.Sunday),
                options: [.SearchBackwards, .MatchStrictly]) {
                for lt in lectureTime {
                    let components = NSDateComponents()
                    components.weekday = weekDayConvert(lt.weekday.integerValue)
                    calendar.enumerateDatesStartingAfterDate(refer,
                        matchingComponents: components,
                        options: .MatchStrictly) {
                            (date, Bool, stop) in
                            guard let date = date else {return}
                            let key = self.formatter.stringFromDate(date)
                            if endDate.compare(date) == .OrderedAscending {
                                stop.memory = true
                            }
                            if self.importantDate[key] == nil {
                                self.importantDate[key] = .Lecture
                            }
                    }
                }
            }
        }
        
        countLectureTime(firstDate, endDate: lastDate)
        
        delegate = self
        collectionView?.delegate = self
        
        weekdayHeaderEnabled = false
        PDTSimpleCalendarViewCell.appearance().textDefaultColor = UIColor.flatGrayColorDark()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CourseCalendarViewController: PDTSimpleCalendarViewDelegate {
    
    func simpleCalendarViewController(controller: PDTSimpleCalendarViewController!, shouldUseCustomColorsForDate date: NSDate!) -> Bool {
        return importantDate[formatter.stringFromDate(date)] != nil
    }
    
    func simpleCalendarViewController(controller: PDTSimpleCalendarViewController!, circleColorForDate date: NSDate!) -> UIColor! {
        if let type = importantDate[formatter.stringFromDate(date)] {
            switch type {
            case .MidTerm, .FinalExam:
                return UIColor.flatRedColor()
            case .Today:
                return UIColor.flatWatermelonColor()
            case .Lecture:
                return UIColor.flatYellowColor()
            }
        }
        return UIColor.whiteColor()
    }
    
    func simpleCalendarViewController(controller: PDTSimpleCalendarViewController!, textColorForDate date: NSDate!) -> UIColor! {
        return importantDate[formatter.stringFromDate(date)] != nil ? UIColor.whiteColor() : UIColor.flatGrayColor()
    }
    
}

// Since PDTSimpleCalendarViewController adopts a collection view to be the inside calendar,
// we can disable the item selection.
// MARK: UICollectionViewDelegate
extension CourseCalendarViewController {
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}