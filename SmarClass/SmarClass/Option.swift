//
//  Option.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Option)
class Option: NSManagedObject {

    @NSManaged var no: NSNumber
    @NSManaged var content: String

}

extension Option: JSONConvertible {
    
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let option     = Option.MR_createEntity()
        option.no      = json["no"].int ?? -1
        option.content = json["content"].string ?? ""
        return option
    }
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        return jsonArray.map() {
            return objectFromJSONObject($0) as! Option
        }
    }
}
