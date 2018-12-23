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
    override func awakeFromInsert() {
        created = true
        group_id = ""
        name = ""
        project_id = ""
        status = GroupStatus.Pending.rawValue
        creator = nil
        members = NSSet()
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let group = Group.MR_createEntity() else {return nil}
        group.group_id = json["_id"].string ?? ""
        if let creator = Member.MR_createEntity() {
            creator.name = json["creator", "name"].string ?? ""
            creator.realName = json["creator", "realName"].string ?? ""
            creator.status = GroupStatus.Accept.rawValue
            group.creator = creator
        }
        var members = [Member]()
        json["members"].arrayValue.forEach {
            if $0["role"].stringValue == "creator" {
                return
            }
            
            if let member = Member.MR_createEntity() {
                member.name = ($0)["student", "name"].string ?? ""
                member.realName = ($0)["student", "realName"].string ?? ""
                member.status = ($0)["status"].int ?? GroupStatus.Pending.rawValue
                members.append(member)
            }
        }
        group.members = NSSet(array: members)
        group.name = json["problem", "name"].string ?? ""
        group.status = json["status"].int ?? GroupStatus.Pending.rawValue
        return group
    }
    
}
