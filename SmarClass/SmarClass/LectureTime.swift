//
//  LectureTime.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(LectureTime)
class LectureTime: NSManagedObject, JSONConvertible {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let lectureTime       = LectureTime.MR_createEntity()
        lectureTime.startTime = json["startTime"].int ?? 0
        lectureTime.endTime   = json["endTime"].int ?? 0
        lectureTime.weekday   = json["weekday"].int ?? 0
        return lectureTime
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        return jsonArray.map {
            return objectFromJSONObject($0) as! LectureTime
        }
    }
}