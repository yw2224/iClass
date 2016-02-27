//
//  CorrectAnswer.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/8.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Choice)
class Choice: NSManagedObject {
    
    override func awakeFromInsert() {
        content = ""
    }
    
    static func convertWithJSONArray(jsonArray: [JSON]) -> [Choice] {
        var ret = [Choice]()
        for json in jsonArray {
            guard let choice = Choice.MR_createEntity() else {continue}
            choice.content = json.description
            ret.append(choice)
        }
        return ret
    }
    
    static func convertWithStringArray(strArray: [String]) -> [Choice] {
        var ret = [Choice]()
        for str in strArray {
            guard let choice = Choice.MR_createEntity() else {continue}
            choice.content = str
            ret.append(choice)
        }
        return ret
    }
}
