//
//  Quiz.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/4.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Quiz)
class Quiz: NSManagedObject {

    @NSManaged var course_id: String
    @NSManaged var quiz_id: String
    @NSManaged var name: String
    @NSManaged var from: NSDate
    @NSManaged var to: NSDate
    @NSManaged var total: NSNumber

}

extension Quiz: JSONConvertible {
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let quiz       = Quiz.MR_createEntity()
        quiz.course_id = json["course_id"].string ?? ""
        quiz.quiz_id   = json["quiz_id"].string ?? ""
        quiz.name      = json["name"].string ?? ""
        quiz.from      = NSDate(timeIntervalSince1970: (json["from"].double ?? 0) / 1000.0)
        quiz.to        = NSDate(timeIntervalSince1970: (json["to"].double ?? 0) / 1000.0)
        quiz.total     = json["total"].int ?? 0
        return quiz
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [Quiz]()
        for json in jsonArray {
            ret.append(objectFromJSONObject(json) as! Quiz)
        }
        return ret
    }
}
