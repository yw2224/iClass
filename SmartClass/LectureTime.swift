//
//  LectureTime.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(LectureTime)
class LectureTime: NSManagedObject, JSONConvertible {
    
    override func awakeFromInsert() {
        endTime = 0
        startTime = 0
        weekday = 0
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let lectureTime = LectureTime.MR_createEntity() else {return nil}
        lectureTime.startTime = json["startTime"].int ?? 0
        lectureTime.endTime   = json["endTime"].int ?? 0
        lectureTime.weekday   = json["weekday"].int ?? 0
        return lectureTime
    }
    
}