//
//  Group.swift
//  SmarClass
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
//    group_id：小组_id  String
//    creator：创建者的name和realName组成的JSON对象  [Creator -- JSON]
//    members：组员的信息列表  [Member -- JSON]，由name，realName和status组成。
    //    name，realName：组员的用户名和真实姓名  String
    //    status：组员的状态  Int，0表示尚未确认，1表示接受，2表示拒绝
//    problem：小组申请的题目，包含problem_id，name，description，maxGroupNum，groupSize，current几项内容。
//    status：小组的状态  Int，0表示尚未确认，1表示成功，2表示失败
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let group = Group.MR_createEntity()
        group.group_id = json["group_id"].string ?? ""
        let creator = Member.MR_createEntity()
        creator.name = json["creator", "name"].string ?? ""
        creator.realName = json["creator", "realName"].string ?? ""
        creator.status = 1 // Accepted
        group.creator = creator
        let members: [Member] = json["members"].arrayValue.map {
            let member = Member.MR_createEntity()
            member.name = ($0)["name"].string ?? ""
            member.realName = ($0)["realName"].string ?? ""
            member.status = ($0)["status"].int ?? 0
            return member
        }
        group.members = NSSet(array: members)
        group.name = json["problem", "name"].string ?? ""
        group.status = json["status"].int ?? 0
        return group
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        return jsonArray.map {
            return objectFromJSONObject($0) as! Group
        }
    }
}
