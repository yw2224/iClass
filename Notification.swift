//
//  Notification.swift
//  
//
//  Created by W1 on 2016/12/25.
//
//

import Foundation
import CoreData
import SwiftyJSON

class Notification: NSManagedObject {
    static func convertWithJSON(jsonArray: [JSON]) -> [Notification] {
        //print(json)
        var ret = [Notification]()
        for json in jsonArray {
            guard let notification = Notification.MR_createEntity() else {continue}
            notification.title = json["title"].string ?? ""
            notification.content = json["content"].string ?? ""
            notification.posterName = json["poster_name"].string ?? ""
            notification.createDate = json["create_at"].number
            ret.append(notification)
        }
        
        return ret
    }
}
