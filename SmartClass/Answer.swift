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
    
    override func awakeFromInsert() {
        question_id = ""
        quiz_id = ""
        score = 0
        originAnswer = NSSet()
    }

    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let answer = Answer.MR_createEntity() else {return nil}
        answer.question_id  = json["question"].string ?? json["_id"].string ?? ""
        answer.score        = json["score"].int ?? 0
        answer.originAnswer = NSSet(array:
            Choice.convertWithJSONArray(json["originAnswer"].arrayValue))
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