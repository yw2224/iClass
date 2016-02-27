//
//  User.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {
    override func awakeFromInsert() {
        email = ""
        name = ""
        phone = ""
        realName = ""
        avatars = NSSet()
    }
}
