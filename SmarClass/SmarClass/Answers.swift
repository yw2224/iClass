//
//  Answers.swift
//  SmartClass
//
//  Created by  on 15/5/11.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData
@objc(Answers)
class Answers: NSManagedObject {

    @NSManaged var answer: String
    @NSManaged var testId: NSNumber
    @NSManaged var testQuestionId: NSNumber

}
