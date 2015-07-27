//
//  Course.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/23.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData
@objc(Course)
class Course: NSManagedObject {

    @NSManaged var describe: String
    @NSManaged var id: NSNumber
    @NSManaged var mainDate: String
    @NSManaged var name: String
    @NSManaged var notificationNumber: NSNumber
    @NSManaged var numberProject: NSNumber
    @NSManaged var numberTest: NSNumber
    @NSManaged var projectId: NSNumber
    @NSManaged var status: NSNumber
    @NSManaged var teacher: NSNumber
    @NSManaged var term: String
    @NSManaged var midTerm: String
    @NSManaged var finalTerm: String

}
