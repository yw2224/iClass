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
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [Choice] {
        return jsonArray.map {
            let choice = Choice.MR_createEntity()
            choice.content = $0.description
            return choice
        }
    }
    
    static func objectFromStringArray(strArray: [String]) -> [Choice] {
        return strArray.map {
            let choice = Choice.MR_createEntity()
            choice.content = $0
            return choice
        }
    }
}
