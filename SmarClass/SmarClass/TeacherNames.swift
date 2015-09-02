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

}


extension TeacherNames {
    static func objectFromJSONArray(jsonArray: [JSON]) -> [TeacherNames] {
        return {
            var ret = [TeacherNames]()
            for name in jsonArray {
                let teacherName = TeacherNames.MR_createEntity()
                teacherName.name = name.description
                ret.append(teacherName)
            }
            return ret
        }()
    }
}