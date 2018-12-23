
//
//  Avatar.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/27.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

enum ShowingStatus: BooleanType {
    case Text
    case Image
    
    var boolValue: Bool {
        if case Text = self {
            return true
        }
        return false
    }
}

prefix func ! (status: ShowingStatus) -> ShowingStatus {
    switch status {
    case .Text:
        return .Image
    case .Image:
        return .Text
    }
}

class AvatarView: CustomView {
    
    var status = ShowingStatus.Text {
        didSet {
            textLabel.hidden = !status
            imageView.hidden = !(!status)
        }
    }
    var capital: String = "N / A" {
        didSet {
            guard !capital.isEmpty else { return }
            let string = CFStringCreateMutableCopy(nil, 0, capital)
            CFStringTransform(string, nil, kCFStringTransformToLatin, false)
            CFStringTransform(string, nil, kCFStringTransformStripCombiningMarks, false)
            textLabel.text = (string as NSString).substringToIndex(1).uppercaseString
            status = .Text
        }
    }
    var image: UIImage! {
        didSet {
            imageView.image = image
            status = .Image
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        setup()
    }
    
    func setup() {
        layer.cornerRadius = CGRectGetWidth(frame) / 2.0
        layer.masksToBounds = true
        
        backgroundColor = UIColor.randomFlatColor()
    }
}
