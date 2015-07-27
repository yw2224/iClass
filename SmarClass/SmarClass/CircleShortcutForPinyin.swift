
//
//  CircleShortcutForPinyin.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/27.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class CircleShortcutForPinyin: UIView {
    var capital: String = "N / A" {
        didSet {
            textLabel.text = capital
            textLabel.sizeToFit()
            textLabel.frame.origin = CGPointMake(
                max(0, (frame.width - textLabel.frame.width) / 2.0),
                max(0, (frame.height - textLabel.frame.height) / 2.0)
            )
            backgroundColor = UIColor.darkGrayColor()
            textLabel.hidden = false
            imageView.hidden = true
        }
    }
    var image: UIImage! {
        didSet {
            imageView.image = image
            backgroundColor = UIColor.whiteColor()
            textLabel.hidden = true
            imageView.hidden = false
        }
    }
    
    var font: UIFont = UIFont.boldSystemFontOfSize(14.0) {
        didSet {
            textLabel.font = font
        }
    }
    private var textLabel: UILabel!
    private var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setupTextLabel() {
        textLabel = UILabel(frame: CGRectZero)
        textLabel.font = font
        textLabel.textAlignment = .Center
        textLabel.numberOfLines = 1
        textLabel.minimumScaleFactor = 0.1
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.textColor = UIColor.whiteColor()
        
        addSubview(textLabel)
    }
    
    func setupImage() {
        imageView = UIImageView(frame: CGRectZero)
        imageView.frame.size = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame))
        imageView.contentMode = .ScaleAspectFit
        
        addSubview(imageView)
    }
    
    func setup() {
        setupTextLabel()
        setupImage()
        
        textLabel.hidden = true
        imageView.hidden = true
        layer.cornerRadius = CGRectGetWidth(frame) / 2.0
        layer.masksToBounds = true
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
