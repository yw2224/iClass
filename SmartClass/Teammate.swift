//
//  Teammate.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/14.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Teammate: NSManagedObject, JSONConvertible {

// Insert code here to add functionality to your managed object subclass
    override func awakeFromInsert() {
        name = ""
        realName = ""
        encypted_id = ""
        course_id = ""
    }
    
    static func convertWithJSON(json: JSON) -> NSManagedObject? {
        guard let teammate = Teammate.MR_createEntity() else {return nil}
        teammate.name = json["name"].string ?? ""
        teammate.realName = json["realName"].string ?? ""
        teammate.encypted_id = json["_id"].string ?? ""
        return teammate
    }
}
