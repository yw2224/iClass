//
//  File+CoreDataProperties.swift
//  
//
//  Created by W1 on 2016/12/23.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension File {

    @NSManaged var date: NSNumber?
    @NSManaged var fileName: String?
    @NSManaged var url: String?
    @NSManaged var userID: String?
    @NSManaged var userName: String?
    @NSManaged var lessonID: String?
    @NSManaged var lessonName: String?
    @NSManaged var lesson: Lesson?

}
