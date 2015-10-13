//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var email: String!
    @NSManaged var name: String!
    @NSManaged var phone: String!
    @NSManaged var realName: String!
    @NSManaged var avatars: NSSet!

}
