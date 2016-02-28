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

    override func awakeFromInsert() {
        course_id = ""
        from = NSDate()
        name = ""
        project_id = ""
        to = NSDate()
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let project = Project.MR_createEntity() else {return nil}
        project.project_id = json["_id"].string ?? ""
        project.name = json["name"].string ?? ""
        project.from = NSDate(timeIntervalSince1970: (json["from"].double ?? 0) / 1000.0)
        project.to   = NSDate(timeIntervalSince1970: (json["to"].double ?? 0) / 1000.0)
        return project
    }
    
}
