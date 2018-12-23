//
//  Avatar.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import Foundation
import CoreData

class Avatar: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    override func awakeFromInsert() {
        name = ""
    }
}
