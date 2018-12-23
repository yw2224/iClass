//
//  Login.swift
//  SmartClass
//
//  Created by PengZhao on 16/2/27.
//  Copyright © 2016年 PKU. All rights reserved.
//

import Foundation

enum LoginStatus: CustomStringConvertible, BooleanType, BooleanLiteralConvertible {
    
    case Login, Register
    
    init(booleanLiteral value: Bool) {
        if value {
            self = .Login
        } else {
            self = .Register
        }
    }
    
    var description: String {
        switch self {
        case .Login:
            return "登录"
        case .Register:
            return "注册"
        }
    }
    
    var boolValue: Bool {
        switch self {
        case .Login:
            return true
        case .Register:
            return false
        }
    }
}

enum LoginErrorType: ErrorType {
    case FieldEmpty(NSIndexPath)
    case FieldInvalid(NSIndexPath)
    case UnknownError
}

prefix func ! (status: LoginStatus) -> LoginStatus {
    switch status {
    case .Login:
        return .Register
    case .Register:
        return .Login
    }
}

typealias TextFieldTuple = (cellID: String, placeholder: String, content: String?, isSecure: Bool, keyboardType: UIKeyboardType)

struct Login {
    
    private let cellIDs = [
        LoginStatus.Register: ["Text", "Text", "Text"],
        LoginStatus.Login: ["Empty", "Text", "Text"]
    ]
    
    private let placeholders = [
        LoginStatus.Register: ["学号", "用户名", "密码"],
        LoginStatus.Login: ["", "学号", "密码"]
    ]
    
    private let contents = [
        LoginStatus.Register: ["", "", ""],
        LoginStatus.Login: ["", ContentManager.UserName, ContentManager.Password]
    ]
    
    private let isSecure = [
        false, false, true
    ]
    
    private let keyboardType = [
        LoginStatus.Register:
            [UIKeyboardType.Default, UIKeyboardType.Default, UIKeyboardType.Default],
        LoginStatus.Login:
            [UIKeyboardType.Default, UIKeyboardType.Default, UIKeyboardType.Default],
    ]
    
    private let indexes = [
        LoginStatus.Register: [
            NSIndexPath(forRow: 0, inSection: 0),
            NSIndexPath(forRow: 1, inSection: 0),
            NSIndexPath(forRow: 2, inSection: 0)
        ],
        LoginStatus.Login: [
            NSIndexPath(forRow: 1, inSection: 0),
            NSIndexPath(forRow: 2, inSection: 0)
        ]
    ]
    
    private let validators = [
        LoginStatus.Register: [
            String.isStudentNo,
            String.isNonEmpty,
            String.isNonEmpty
        ],
        LoginStatus.Login: [
            String.isStudentNo,
            String.isNonEmpty,
        ]
    ]
    
    subscript(status: LoginStatus, indexPath: NSIndexPath) -> TextFieldTuple? {
        guard
            let cellID = cellIDs[status]?[indexPath.row],
            let placeholder = placeholders[status]?[indexPath.row],
            let content = contents[status]?[indexPath.row],
            let keyboardType = keyboardType[status]?[indexPath.row]
            where indexPath.row < isSecure.count
        else { return nil }
        return (cellID, placeholder, content, isSecure[indexPath.row], keyboardType)
    }
    
    subscript(status: LoginStatus) -> Int {
        return cellIDs[status]?.count ?? 0
    }
    
    func validate(status: LoginStatus, tableView: UITableView) throws -> (String, String, String) {
        guard let validators = validators[status], indexes = indexes[status] where validators.count == indexes.count else { throw LoginErrorType.UnknownError }
        
        var result = [String]()
        for (i, v) in validators.enumerate() {
            guard let textSetup = tableView.cellForRowAtIndexPath(indexes[i]) as? TextCellSetup
                else { throw LoginErrorType.UnknownError }
            
            let content = textSetup.content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if content.isEmpty {
                throw LoginErrorType.FieldEmpty(indexes[i])
            }
            
           /* if !v(content)() {
                throw LoginErrorType.FieldInvalid(indexes[i])
            }
            */
            result.append(content)
        }
        
        while (result.count < 3) {
            result += [""]
        }
        
        return (result[0], result[1], result[2])
    }
}