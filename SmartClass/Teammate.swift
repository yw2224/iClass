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
    static func objectFromJSONObject(json: JSON) -> NSManagedObject? {
        let teammate = Teammate.MR_createEntity()
        teammate.name = json["name"].string ?? ""
        teammate.realName = json["realName"].string ?? ""
        teammate.encypted_id = json["_id"].string ?? ""
        return teammate
    }
}
