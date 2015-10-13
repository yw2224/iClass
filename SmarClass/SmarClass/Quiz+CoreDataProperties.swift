//
//  Quiz+CoreDataProperties.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Quiz {

    @NSManaged var correct: NSNumber!
    @NSManaged var course_id: String!
    @NSManaged var createDate: NSDate!
    @NSManaged var from: NSDate!
    @NSManaged var name: String!
    @NSManaged var quiz_id: String!
    @NSManaged var to: NSDate!
    @NSManaged var total: NSNumber!

}
