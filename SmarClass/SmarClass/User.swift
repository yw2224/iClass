//
//  User.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/20.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData
@objc(User)
class User: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var username: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var email: String
    @NSManaged var utype: String

}
