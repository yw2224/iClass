//
//  JSONConvertible.swift
//  SmartClass
//
//  Created by PengZhao on 16/2/27.
//  Copyright © 2016年 PKU. All rights reserved.
//

import CoreData
import SwiftyJSON

protocol JSONConvertible {
    
    static func convertWithJSON(json: JSON) -> NSManagedObject?
}

extension JSONConvertible {
    
    static func convertWithJSONArray(jsonArray: [JSON]) -> [NSManagedObject] {
        var ret = [NSManagedObject]()
        jsonArray.map{ convertWithJSON($0) }.forEach{
            guard let obj = $0 else {return}
            ret.append(obj)
        }
        return ret
    }
    
}