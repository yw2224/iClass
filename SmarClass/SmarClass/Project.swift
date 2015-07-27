//
//  Project.swift
//  SmartClass
//
//  Created by  ChenYang on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData

@objc(Project)class Project: NSManagedObject {

    @NSManaged var btime: String
    @NSManaged var courseId: NSNumber
    @NSManaged var ctime: String
    @NSManaged var etime: String
    @NSManaged var fileUrl: String
    @NSManaged var groupNumber: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var isGrouped: NSNumber
    @NSManaged var name: String
    @NSManaged var numberStudent: NSNumber
    @NSManaged var status: NSNumber

}
