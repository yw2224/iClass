//
//  Answer.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/8.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Answer)
class Answer: NSManagedObject {

    @NSManaged var quiz_id: String
    @NSManaged var question_id: String
    @NSManaged var score: NSNumber
    @NSManaged var originAnswer: NSSet
}

class AnswerJSON {
    var question_id  = ""
    var originAnswer = [String]()
    
    init (question_id: String, originAnswer: [String]) {
        self.question_id  = question_id
        self.originAnswer = originAnswer
    }
}

extension Answer: JSONConvertible {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let answer          = Answer.MR_createEntity()
        answer.question_id  = json["question_id"].string ?? json["_id"].string ?? ""
        answer.score        = json["score"].int ?? 0
        answer.originAnswer = NSSet(array:
            Choice.objectFromJSONArray(json["originAnswer"].arrayValue))
        return answer
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [Answer]()
        for json in jsonArray {
            ret.append(objectFromJSONObject(json) as! Answer)
        }
        return ret
    }
}
