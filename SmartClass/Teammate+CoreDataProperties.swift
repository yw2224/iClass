//
//  Teammate+CoreDataProperties.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/14.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Teammate {

    @NSManaged var name: String!
    @NSManaged var realName: String!
    @NSManaged var encypted_id: String!
    @NSManaged var course_id: String!

}
