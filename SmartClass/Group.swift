//
//  Group.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Group)
class Group: NSManagedObject, JSONConvertible {

// Insert code here to add functionality to your managed object subclass
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let group = Group.MR_createEntity()
        group.group_id = json["group_id"].string ?? ""
        let creator = Member.MR_createEntity()
        creator.name = json["creator", "name"].string ?? ""
        creator.realName = json["creator", "realName"].string ?? ""
        creator.status = GroupStatus.Accept.rawValue
        group.creator = creator
        let members: [Member] = json["members"].arrayValue.map {
            let member = Member.MR_createEntity()
            member.name = ($0)["name"].string ?? ""
            member.realName = ($0)["realName"].string ?? ""
            member.status = ($0)["status"].int ?? GroupStatus.Pending.rawValue
            return member
        }
        group.members = NSSet(array: members)
        group.name = json["problem", "name"].string ?? ""
        group.status = json["status"].int ?? GroupStatus.Pending.rawValue
        return group
    }
    
}
