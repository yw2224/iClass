//
//  EX+CoreDataProperties.swift
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

extension EX {

    @NSManaged var courseID: String?
    @NSManaged var like: NSNumber?
    @NSManaged var postDate: String?
    @NSManaged var postingID: String?
    @NSManaged var postUserID: String?
    @NSManaged var title: String?
    @NSManaged var course: Course?

}
