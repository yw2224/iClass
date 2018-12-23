//
//  Lesson.swift
//  
//
//  Created by W1 on 2016/12/21.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Lesson)
class Lesson: NSManagedObject {
    static func convertWithJSON(jsonArray: [JSON]) -> [Lesson] {
        //print(json)
        var ret = [Lesson]()
        for json in jsonArray {
            guard let lesson = Lesson.MR_createEntity() else {continue}
            lesson.lessonName = json["lesson_name"].string ?? ""
            lesson.lessonID = json["lesson_id"].intValue ?? -1
            ret.append(lesson)
        }
        
        return ret
    }
}
