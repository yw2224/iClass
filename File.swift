//
//  File.swift
//  
//
//  Created by W1 on 2016/12/23.
//
//

import Foundation
import CoreData
import SwiftyJSON


class File: NSManagedObject {
    static func convertWithJSON(jsonArray: [JSON]) -> [File] {
        //print(json)
        var ret = [File]()
        for json in jsonArray {
            guard let file = File.MR_createEntity() else {continue}
            file.fileName = json["name"].string ?? ""
            file.url = json["url"].string ?? ""
            file.userName = json["user_name"].string ?? ""
            file.userID = json["user_id"].string ?? ""
            file.date = json["date"].intValue ?? -1
            
            ret.append(file)
        }
        
        return ret
    }
}
