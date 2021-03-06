//
//  LectureTime+CoreDataProperties.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/22.
//  Copyright © 2015年 PKU. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LectureTime {

    @NSManaged var endTime: NSNumber
    @NSManaged var startTime: NSNumber
    @NSManaged var weekday: NSNumber

}
