//
//  User.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var email: String
    @NSManaged var phone: String
    @NSManaged var realName: String
    @NSManaged var avatars: NSSet
}
