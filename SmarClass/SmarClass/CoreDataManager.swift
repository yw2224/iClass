//
//  CoreDataManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CocoaLumberjack
import CoreData
import MagicalRecord

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    
    static func config() {
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("SmartClass")
    }
    
    static func cleanup() {
        MagicalRecord.cleanUp()
    }
    
    func saveInBackground() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion {
            (success, error) in
            DDLogInfo("save in background: \(success) \(error)")
        }
    }
    
    func saveInForeground() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func courseList() -> [Course] {
        return Course.MR_findAllSortedBy("course_id", ascending: true) as! [Course]
    }
    
    func quizList() -> [Quiz] {
        return Quiz.MR_findAllSortedBy("to", ascending: false) as! [Quiz]
    }
}
