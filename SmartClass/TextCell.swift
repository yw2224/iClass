//
//  LoginCell.swift
//  iBeaconToy
//
//  Created by PengZhao on 16/1/2.
//  Copyright © 2016年 pku. All rights reserved.
//

import UIKit

protocol TextCellSetup {
    var content: String {get}
    func setupWithPlaceholder(placeholder: String, content: String?, isSecure: Bool, AndKeyboardType keyboardType: UIKeyboardType)
}

class TextCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    var content: String {
        return textField.text ?? ""
    }
}

extension TextCell: TextCellSetup {
    
    func setupWithPlaceholder(placeholder: String, content: String?, isSecure: Bool, AndKeyboardType keyboardType: UIKeyboardType) {
        
        textField.text = content
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        
        textField.secureTextEntry = isSecure
        textField.clearsOnBeginEditing = isSecure
        textField.clearButtonMode = isSecure ? .WhileEditing : .Never
        textField.keyboardType = keyboardType
    }
}

extension TextCell: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}