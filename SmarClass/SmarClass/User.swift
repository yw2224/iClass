//
//  User.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var realName: String
    @NSManaged var avatars: NSSet

}
