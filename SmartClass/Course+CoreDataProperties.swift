//
//  Course+CoreDataProperties.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/13.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Course {
/*
    @NSManaged var course_id: String
    @NSManaged var endDate: NSDate
    @NSManaged var finalExam: NSDate
    @NSManaged var introduction: String
    @NSManaged var maxStudentsNumber: NSNumber
    @NSManaged var midterm: NSDate
    @NSManaged var name: String
    @NSManaged var startDate: NSDate
    @NSManaged var students: NSNumber
    @NSManaged var term: String
    @NSManaged var lectureTime: NSSet
    @NSManaged var teacherName: NSSet
*/
    @NSManaged var course_id: String
    @NSManaged var endDate: NSDate
    @NSManaged var finalExam: NSDate
    @NSManaged var introduction: String
    @NSManaged var maxStudentsNumber: NSNumber
    @NSManaged var midterm: NSDate
    @NSManaged var name: String
    @NSManaged var startDate: NSDate
    @NSManaged var students: NSNumber
    @NSManaged var term: String
    @NSManaged var joinedaGroup: NSNumber
    @NSManaged var ex: EX
    @NSManaged var lectureTime: NSSet
    @NSManaged var lesson: NSSet
    @NSManaged var notification: Notification
    @NSManaged var qa: QA
    @NSManaged var teacherName: NSSet
}
