//
//  Group+CoreDataProperties.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/6.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Group {

    @NSManaged var project_id: String!
    @NSManaged var status: NSNumber!
    @NSManaged var group_id: String!
    @NSManaged var created: NSNumber!
    @NSManaged var name: String!
    @NSManaged var creator: Member!
    @NSManaged var members: NSSet!

}
