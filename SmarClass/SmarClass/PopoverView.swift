//
//  PopoverView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/26.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PopoverView: UIView {
    var value: Int = 0 {
        didSet {
            text = String(value)
            textLabel.text = text
            setNeedsDisplay()
        }
    }
    
    private var text: String = ""
    private var textLabel: UILabel!
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let popoverView = UIImageView(image: UIImage(named: "SliderLabel"))
        addSubview(popoverView)
        
        textLabel = UILabel()
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.font = UIFont.boldSystemFontOfSize(15.0)
        textLabel.textColor = UIColor(white: 1.0, alpha: 0.7)
        textLabel.text = text
        textLabel.textAlignment = .Center
        textLabel.frame = CGRectMake(0, -5.0, popoverView.frame.size.width, popoverView.frame.size.height)
        addSubview(textLabel)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
