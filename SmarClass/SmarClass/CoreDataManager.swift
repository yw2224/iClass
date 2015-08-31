//
//  CoreDataManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CocoaLumberjack
import MagicalRecord

class CoreDataManager: NSObject {
    
    static func config() {
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("SmartClass")
    }
    
    
    func a() {
        let test = User.findAll() as! [User]
    }
    // save background
    // didSet print whether it's on main thread
    
    static func cleanup() {
        MagicalRecord.cleanUp()
    }
    
}
