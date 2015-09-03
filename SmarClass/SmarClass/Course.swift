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

    @NSManaged var course_id: String
    @NSManaged var name: String
    @NSManaged var introduction: String
    @NSManaged var midterm: NSDate
    @NSManaged var finalExam: NSDate
    @NSManaged var maxStudentsNumber: NSNumber
    @NSManaged var students: NSNumber
    @NSManaged var term: String
    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var lectureTime: NSSet
    @NSManaged var teacherNames: NSSet
    
    var teacherNameString: String {
        get {
            var str = ""
            var teacherNameArray: [String] = {
                var array = [String]()
                for teacherName in self.teacherNames.allObjects {
                    array.append(teacherName.name)
                }
                array.sort() {
                    return $0 < $1
                }
                return array
            }()
            for teacherName in teacherNameArray {
                str += "\(teacherName)\t"
            }
            return str
        }
    }
}

extension Course: JSON2ObjectConvert {
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let course = Course.MR_createEntity()
        course.course_id = json["course_id"].string ?? ""
        course.name = json["name"].string ?? ""
        course.introduction = json["introduction"].string ?? ""
        course.midterm = NSDate(timeIntervalSince1970: (json["midterm"].double ?? 0) / 1000.0)
        course.finalExam = NSDate(timeIntervalSince1970: (json["finalExam"].double ?? 0) / 1000.0)
        course.maxStudentsNumber = json["maxStudentsNumber"].int ?? 0
        course.students = json["students"].int ?? 0
        course.term = json["term"].string ?? ""
        course.startDate = NSDate(timeIntervalSince1970: (json["startDate"].double ?? 0) / 1000.0)
        course.endDate = NSDate(timeIntervalSince1970: (json["endDate"].double ?? 0) / 1000.0)
        course.lectureTime = NSSet(array:
            LectureTime.objectFromJSONArray(json["lectureTime"].arrayValue))
        course.teacherNames = NSSet(array:
            TeacherNames.objectFromJSONArray(json["teacherNames"].arrayValue))
        return course
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [Course]()
        for json in jsonArray {
            ret.append(objectFromJSONObject(json) as! Course)
        }
        return ret
    }
}
