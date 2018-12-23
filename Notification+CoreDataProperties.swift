//
//  Notification+CoreDataProperties.swift
//  
//
//  Created by Xiaoyu on 2017/1/7.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Notification {

    @NSManaged var content: String?
    @NSManaged var courseID: String?
    @NSManaged var createDate: NSNumber?
    @NSManaged var posterName: String?
    @NSManaged var title: String?
    @NSManaged var course: Course?

}
