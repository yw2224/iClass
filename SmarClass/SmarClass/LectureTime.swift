//
//  LectureTime.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(LectureTime)
class LectureTime: NSManagedObject {

    @NSManaged var startTime: NSNumber
    @NSManaged var endTime: NSNumber
    @NSManaged var weekday: NSNumber

}

extension LectureTime: JSON2ObjectConvert {
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let lectureTime = LectureTime.MR_createEntity()
        lectureTime.startTime = json["startTime"].int ?? 0
        lectureTime.endTime = json["endTime"].int ?? 0
        lectureTime.weekday = json["weekday"].int ?? 0
        return lectureTime
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [LectureTime]()
        for json in jsonArray {
            ret.append(objectFromJSONObject(json) as! LectureTime)
        }
        return ret
        
    }
}