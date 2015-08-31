//
//  ContentManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation

protocol ContentRetrieveActions {
    func login(name: String, password: String) -> Bool
}

class ContentManager: NSObject, ContentRetrieveActions {
    func login(name: String, password: String) -> Bool {
        return true
    }
}
