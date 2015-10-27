//
//  Project.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Project)
class Project: NSManagedObject, JSONConvertible {

    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let project = Project.MR_createEntity()
        project.project_id = json["project_id"].string ?? ""
        project.name = json["name"].string ?? ""
        project.from = NSDate(timeIntervalSince1970: (json["from"].double ?? 0) / 1000.0)
        project.to   = NSDate(timeIntervalSince1970: (json["to"].double ?? 0) / 1000.0)
        return project
    }
    
}
