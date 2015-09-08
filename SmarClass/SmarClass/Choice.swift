//
//  CorrectAnswer.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/8.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Choice)
class Choice: NSManagedObject {

    @NSManaged var content: String
    
    static func objectFromJSONArray(jsonArray: [JSON]) -> [Choice] {
        return {
            var ret = [Choice]()
            for name in jsonArray {
                let choice = Choice.MR_createEntity()
                choice.content = name.description
                ret.append(choice)
            }
            return ret
        }()
    }
    
    static func objectFromStringArray(strArray: [String]) -> [Choice] {
        return {
            var ret = [Choice]()
            for name in strArray {
                let choice = Choice.MR_createEntity()
                choice.content = name
                ret.append(choice)
            }
            return ret
        }()
    }
}
