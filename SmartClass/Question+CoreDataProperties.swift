//
//  Question+CoreDataProperties.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/13.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Question {

    @NSManaged var content: String
    @NSManaged var no: NSNumber
    @NSManaged var question_id: String
    @NSManaged var quiz_id: String
    @NSManaged var type: String
    @NSManaged var correctAnswer: NSSet
    @NSManaged var options: NSSet

}
