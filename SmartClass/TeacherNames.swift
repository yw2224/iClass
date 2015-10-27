//
//  TeacherNames.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(TeacherNames)
class TeacherNames: NSManagedObject {

    static func objectFromJSONArray(jsonArray: [JSON]) -> [TeacherNames] {
        return jsonArray.map {
            let teacher = TeacherNames.MR_createEntity()
            teacher.name = $0.description
            return teacher
        }
    }
}