//
//  Option.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Option)
class Option: NSManagedObject, JSONConvertible {
    
    override func awakeFromInsert() {
        content = ""
        no = 0
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let option = Option.MR_createEntity() else {return nil}
        option.no      = json["no"].int ?? -1
        option.content = json["content"].string ?? ""
        return option
    }
}
