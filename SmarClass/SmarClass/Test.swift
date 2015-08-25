//
//  Test.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData

@objc(Test)class Test: NSManagedObject {

    @NSManaged var btime: String
    @NSManaged var courseId: NSNumber
    @NSManaged var ctime: String
    @NSManaged var etime: String
    @NSManaged var fileUrl: String
    @NSManaged var id: NSNumber
    @NSManaged var mtime: String
    @NSManaged var name: String
    @NSManaged var numberStudent: NSNumber
    @NSManaged var questionNumber: NSNumber
    @NSManaged var status: NSNumber

}
