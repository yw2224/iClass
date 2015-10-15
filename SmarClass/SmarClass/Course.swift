//
//  Course.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Course)
class Course: NSManagedObject {

    var teacherNameString: String {
        get {
            guard let teacherNames = teacherNames?.allObjects as? [TeacherNames] where teacherNames.count > 0 else {return "无"}
            let teacherNameArray: [String] = teacherNames.map({return $0.name ?? ""}).sort(<)
            return teacherNameArray.joinWithSeparator("\t")
        }
    }
}

extension Course: JSONConvertible {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let course               = Course.MR_createEntity()
        course.course_id         = json["course_id"].string ?? ""
        course.name              = json["name"].string ?? ""
        course.introduction      = json["introduction"].string ?? ""
        course.midterm           = NSDate(timeIntervalSince1970: (json["midterm"].double ?? 0) / 1000.0)
        course.finalExam         = NSDate(timeIntervalSince1970: (json["finalExam"].double ?? 0) / 1000.0)
        course.maxStudentsNumber = json["maxStudentsNumber"].int ?? 0
        course.students          = json["students"].int ?? 0
        course.term              = json["term"].string ?? ""
        course.startDate         = NSDate(timeIntervalSince1970: (json["startDate"].double ?? 0) / 1000.0)
        course.endDate           = NSDate(timeIntervalSince1970: (json["endDate"].double ?? 0) / 1000.0)
        course.lectureTime       = NSSet(array:
            LectureTime.objectFromJSONArray(json["lectureTime"].arrayValue))
        course.teacherNames      = NSSet(array:
            TeacherNames.objectFromJSONArray(json["teacherNames"].arrayValue))
        return course
    }
}
