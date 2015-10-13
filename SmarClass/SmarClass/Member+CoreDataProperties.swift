//
//  Member+CoreDataProperties.swift
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

extension Member {

    @NSManaged var name: String?
    @NSManaged var realName: String?
    @NSManaged var status: NSNumber?

}
