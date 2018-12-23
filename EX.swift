//
//  EX.swift
//  
//
//  Created by W1 on 2017/1/4.
//
//

import Foundation
import CoreData
import SwiftyJSON

class EX: NSManagedObject {

    static func convertWithJSON(jsonArray: [JSON]) -> [EX] {
        //print(json)
        var ret = [EX]()
        for json in jsonArray {
            guard let ex = EX.MR_createEntity() else {continue}
            ex.title = json["title"].string ?? ""
            ex.postingID = json["posting_id"].string ?? ""
            ex.postUserID = json["postUser_name"].string ?? ""
            
            ex.postDate = json["postDate"].string ?? ""
            /*let dateFormatter = NSDateFormatter()
            print(str1.substringFromIndex(str1.startIndex.advancedBy(6)) )
            
            let date = dateFormatter.dateFromString(json["postDate"].string ?? "")
            ex.postDate = date*/
            /*var dateString = json["postDate"].string ?? ""
            dateString = dateString.substringToIndex(Index(10))
            print("date:???")
            print()
            */
            ex.like = json["like"].intValue ?? 0
            ret.append(ex)
        }
        
        return ret
    }

}
