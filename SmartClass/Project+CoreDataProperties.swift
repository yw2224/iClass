//
//  Project+CoreDataProperties.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/13.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Project {

    @NSManaged var course_id: String!
    @NSManaged var from: NSDate!
    @NSManaged var name: String!
    @NSManaged var project_id: String!
    @NSManaged var to: NSDate!

}
