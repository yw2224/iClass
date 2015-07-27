//
//  TestQuestion.swift
//  SmartClass
//
//  Created by  ChenYang on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import Foundation
import CoreData

@objc(TestQuestion)class TestQuestion: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var testId: NSNumber
    @NSManaged var questionId: NSNumber
    @NSManaged var content: String
    @NSManaged var answer: String
    @NSManaged var choice: String

}
