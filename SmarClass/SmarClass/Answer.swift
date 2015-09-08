//
//  Answer.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/8.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData

@objc(Answer)
class Answer: NSManagedObject {

    @NSManaged var quiz_id: String
    @NSManaged var question_id: String
    @NSManaged var originAnswer: NSSet

}
