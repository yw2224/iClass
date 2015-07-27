//
//  Group.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/29.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData
@objc(Group)
class Group: NSManagedObject {

    @NSManaged var groupId: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var leader: String
    @NSManaged var member: String
    @NSManaged var projectId: NSNumber
    @NSManaged var status: NSNumber
    @NSManaged var chosenQuestionId: NSNumber

}
