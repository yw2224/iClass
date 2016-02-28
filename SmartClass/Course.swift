//
//  Course.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Course)
class Course: NSManagedObject {

    var teacherNames: String {
        get {
            guard let teacherNames = teacherName.allObjects as? [TeacherName]
                where teacherNames.count > 0
            else { return "无" }
            return teacherNames.map{ $0.name }.sort(<).joinWithSeparator(" ")
        }
    }
}

extension Course: JSONConvertible {
    
    override func awakeFromInsert() {
        course_id = ""
        endDate = NSDate()
        finalExam = NSDate()
        introduction = ""
        maxStudentsNumber = 0
        midterm = NSDate()
        name = ""
        startDate = NSDate()
        students = 0
        term = ""
        lectureTime = NSSet()
        teacherName = NSSet()
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let course = Course.MR_createEntity() else {return nil}
        course.course_id         = json["_id"].string ?? ""
        course.name              = json["name"].string ?? ""
        course.introduction      = json["introduction"].string ?? ""
        course.midterm           = NSDate(timeIntervalSince1970: (json["midterm"].double ?? 0) / 1000.0)
        course.finalExam         = NSDate(timeIntervalSince1970: (json["finalExam"].double ?? 0) / 1000.0)
        course.maxStudentsNumber = json["maxStudentsNumber"].int ?? 0
        course.students          = json["studentCount"].int ?? 0
        course.term              = json["term"].string ?? ""
        course.startDate         = NSDate(timeIntervalSince1970: (json["startDate"].double ?? 0) / 1000.0)
        course.endDate           = NSDate(timeIntervalSince1970: (json["endDate"].double ?? 0) / 1000.0)
        course.lectureTime       = NSSet(array:
            LectureTime.convertWithJSONArray(json["lectureTime"].arrayValue))
        course.teacherName      = NSSet(array:
            TeacherName.convertWithJSONArray(json["teacherNames"].arrayValue))
        return course
    }
}
