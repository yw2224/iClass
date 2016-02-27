//
//  Problem.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Problem)
class Problem: NSManagedObject, JSONConvertible {

// Insert code here to add functionality to your managed object subclass
    override func awakeFromInsert() {
        current = 0
        deskription = ""
        groupSize = 0
        maxGroupNum = 0
        name = ""
        problem_id = ""
        project_id = ""
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let problem = Problem.MR_createEntity() else {return nil}
        problem.problem_id = json["problem_id"].string ?? ""
        problem.name = json["name"].string ?? ""
        problem.deskription = json["description"].string ?? ""
        problem.maxGroupNum = json["maxGroupNum"].int ?? 0
        problem.groupSize = json["groupSize"].int ?? 0
        problem.current = json["current"].int ?? 0
        return problem
    }

}
