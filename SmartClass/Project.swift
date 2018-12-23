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
class Project: NSManagedObject {

    override func awakeFromInsert() {
        course_id = ""
        from = NSDate()
        name = ""
        project_id = ""
        to = NSDate()
    }
    
    static func convertWithJSON(jsonArray: [JSON]) -> [Project] {
        
        var ret = [Project]()
        for json in jsonArray {
            guard let project = Project.MR_createEntity() else {continue}
            project.project_id = json["_id"].string ?? ""
            project.name = json["name"].string ?? ""
            project.from = NSDate(timeIntervalSince1970: (json["from"].double ?? 0) / 1000.0)
            project.to   = NSDate(timeIntervalSince1970: (json["to"].double ?? 0) / 1000.0)
            ret.append(project)
        }
        
        return ret

    }
    
}
