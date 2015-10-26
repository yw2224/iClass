//
//  Problem.swift
//  SmarClass
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
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let problem = Problem.MR_createEntity()
        problem.problem_id = json["problem_id"].string ?? ""
        problem.name = json["name"].string ?? ""
        problem.deskription = json["description"].string ?? ""
        problem.maxGroupNum = json["maxGroupNum"].int ?? 0
        problem.groupSize = json["groupSize"].int ?? 0
        problem.current = json["current"].int ?? 0
        return problem
    }

}
