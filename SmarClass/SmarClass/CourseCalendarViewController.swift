//
//  CourseCalendarViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/3.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import PDTSimpleCalendar

class CourseCalendarViewController: PDTSimpleCalendarViewController {

    var lectureTime = [LectureTime]()
    var startDate = NSDate() {
        didSet {
            firstDate = startDate
        }
    }
    var endDate = NSDate() {
        didSet {
            lastDate = endDate
        }
    }
    var midTerm: NSDate?
    var finalExam: NSDate?
    var importantDate = [String: DateType]()
    let formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "zh_CN")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    enum DateType {
        case MidTerm
        case FinalExam
        case Today
        case Lecture
    }
    
    private struct Constants {
        static let Sunday = 7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "重要日期"
        delegate = self
        weekdayHeaderEnabled = false
        PDTSimpleCalendarViewCell.appearance().textDefaultColor = UIColor.flatGrayColorDark()
        
        if let m = midTerm {
            importantDate[formatter.stringFromDate(m)] = .MidTerm
        }
        if let f = finalExam {
            importantDate[formatter.stringFromDate(f)] = .FinalExam
        }
        importantDate[formatter.stringFromDate(NSDate())] = .Today
        
        func countLectureTime() {
            let weekDayConvert: (Int) -> Int = {
                let addOne = 1 + $0
                return addOne > 7 ? addOne - 7 : addOne
            }
            
            let calendar = NSCalendar.currentCalendar()
            if let refer = calendar.nextDateAfterDate(startDate,
                matchingUnit: .CalendarUnitWeekday,
                value: weekDayConvert(Constants.Sunday),
                options: .SearchBackwards | .MatchStrictly) {
                for lt in lectureTime {
                    let components = NSDateComponents()
                    components.weekday = weekDayConvert(lt.weekday.integerValue)
                    calendar.enumerateDatesStartingAfterDate(refer,
                        matchingComponents: components,
                        options: .MatchStrictly) {
                            [weak self] (date, Bool, stop) in
                            if self?.endDate.compare(date) == .OrderedAscending {
                                stop.memory = true
                            }
                            if let key = self?.formatter.stringFromDate(date) {
                                if self?.importantDate[key] == nil {
                                    self?.importantDate[key] = .Lecture
                                }
                            }
                    }
                }
            }
        }
        
        countLectureTime()
        collectionView?.delegate = self
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
        if let type = importantDate[formatter.stringFromDate(date)] {
            return true
        }
        return false
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
        if let type = importantDate[formatter.stringFromDate(date)] {
            return UIColor.whiteColor()
        }
        return UIColor.flatGrayColorDark()
    }
}

// Since PDTSimpleCalendarViewController adopts a collection view to be the inside calendar,
// we can disable the item selection.
extension CourseCalendarViewController: UICollectionViewDelegate {
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}