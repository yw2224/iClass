//
//  Lesson+CoreDataProperties.swift
//  
//
//  Created by W1 on 2016/12/21.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lesson {

    @NSManaged var lessonID: NSNumber?
    @NSManaged var lessonName: String?
    @NSManaged var courseID: String?
    @NSManaged var course: Course?

}
