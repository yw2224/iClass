//
//  ProjectQuestion.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/20.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData
@objc(ProjectQuestion)
class ProjectQuestion: NSManagedObject {

    @NSManaged var describe: String
    @NSManaged var fileUrl: String
    @NSManaged var id: NSNumber
    @NSManaged var maxGroup: NSNumber
    @NSManaged var name: String
    @NSManaged var numberPerGroup: NSNumber
    @NSManaged var projectId: NSNumber
    @NSManaged var questionId: NSNumber

}
