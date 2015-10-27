//
//  Answer.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/8.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Answer)
class Answer: NSManagedObject, JSONConvertible {

    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let answer          = Answer.MR_createEntity()
        answer.question_id  = json["question_id"].string ?? json["_id"].string ?? ""
        answer.score        = json["score"].int ?? 0
        answer.originAnswer = NSSet(array:
            Choice.objectFromJSONArray(json["originAnswer"].arrayValue))
        return answer
    }
    
}

class AnswerJSON {
    var question_id  = ""
    var originAnswer = [String]()
    
    init (question_id: String, originAnswer: [String]) {
        self.question_id  = question_id
        self.originAnswer = originAnswer
    }
}