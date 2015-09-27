//
//  TeacherNames.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(TeacherNames)
class TeacherNames: NSManagedObject {

    @NSManaged var name: String

    static func objectFromJSONArray(jsonArray: [JSON]) -> [TeacherNames] {
        return jsonArray.map() {
            let teacherName = TeacherNames.MR_createEntity()
            teacherName.name = $0.description
            return teacherName
        }
    }
}