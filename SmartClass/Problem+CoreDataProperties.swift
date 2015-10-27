//
//  Problem+CoreDataProperties.swift
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

extension Problem {

    @NSManaged var current: NSNumber!
    @NSManaged var deskription: String!
    @NSManaged var groupSize: NSNumber!
    @NSManaged var maxGroupNum: NSNumber!
    @NSManaged var name: String!
    @NSManaged var problem_id: String!
    @NSManaged var project_id: String!

}
