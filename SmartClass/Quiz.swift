//
//  Quiz.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/4.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Quiz)
class Quiz: NSManagedObject, JSONConvertible {
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let quiz = Quiz.MR_createEntity() else {return nil}
        quiz.course_id  = json["course_id"].string ?? ""
        quiz.quiz_id    = json["_id"].string ?? ""
        quiz.name       = json["name"].string ?? ""
        quiz.from       = NSDate(timeIntervalSince1970: (json["from"].double ?? 0) / 1000.0)
        quiz.to         = NSDate(timeIntervalSince1970: (json["to"].double ?? 0) / 1000.0)
        quiz.total      = json["length"].int ?? 0
        quiz.createDate = NSDate(timeIntervalSince1970: (json["createDate"].double ?? 0) / 1000.0)
        
        
        // MARK : fix this bug later
        quiz.correct = json["answered"].boolValue ? json["correct"].intValue : -1
        return quiz
    }
    
}
