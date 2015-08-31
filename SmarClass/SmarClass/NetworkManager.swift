//
//  NetworkManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: NSObject {
    private static let PendingOpDict = [String : NSOperation]()
    private static let OperationQueue = NSOperationQueue()
    private static let Manager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10.0
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }()
    
    func performOperationWithIdentifier(identifier: String) {
        
    }
    
    func cancelOperationWithIdentifier(identifier: String) {
    }
}

extension NetworkManager: ContentRetrieveActions {
    func login(name: String, password: String) -> Bool {
        // add parameters
        return true
    }
}