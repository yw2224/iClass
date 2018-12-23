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
    
    override func awakeFromInsert() {
        content = ""
        no = 0
        question_id = ""
        quiz_id = ""
        type = ""
        correctAnswer = NSSet()
        options = NSSet()
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let question = Question.MR_createEntity() else {return nil}
        question.question_id   = json["_id"].string ?? ""
        question.content       = json["content"].string ?? ""
        question.type          = json["type"].string ?? ""
        question.options       = NSSet(array:
            Option.convertWithJSONArray(json["options"].arrayValue))
        question.correctAnswer = NSSet(array:
            Choice.convertWithJSONArray(json["correctAnswer"].arrayValue))
        return question
    }
    
    static func convertWithJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [Question]()
        var cnt = 0
        for json in jsonArray {
            guard let question = convertWithJSON(json) as? Question else {continue}
            question.no = cnt++
            ret.append(question)
        }
        return ret
    }
}
