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

@objc(TeacherName)
class TeacherName: NSManagedObject {

    static func convertWithJSONArray(jsonArray: [JSON]) -> [TeacherName] {
        var ret = [TeacherName]()
        jsonArray.forEach {
            guard let teacher = TeacherName.MR_createEntity() else {return}
            teacher.name = $0.description
            ret.append(teacher)
        }
        return ret
    }
}