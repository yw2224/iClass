//
//  Question.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Question)
class Question: NSManagedObject, JSONConvertible {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let question           = Question.MR_createEntity()
        question.question_id   = json["_id"].string ?? ""
        question.content       = json["content"].string ?? ""
        question.type          = json["type"].string ?? ""
        question.options       = NSSet(array:
            Option.objectFromJSONArray(json["options"].arrayValue))
        question.correctAnswer = NSSet(array:
            Choice.objectFromJSONArray(json["correctAnswer"].arrayValue))
        return question
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [Question]()
        for (index, json) in jsonArray.enumerate() {
            let question = objectFromJSONObject(json) as! Question
            question.no = index
            ret.append(question)
        }
        return ret
    }
}
