
//
//  Avatar.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/27.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class AvatarView: UIView {
    
    enum ShowingStatus {
        case Text
        case Image
    }
    
    var view: UIView!
    var status = ShowingStatus.Text {
        didSet {
            if status == .Text {
                textLabel.hidden = false
                imageView.image = nil
                imageView.hidden = true
            } else {
                textLabel.hidden = true
                imageView.hidden = false
            }
        }
    }
    var capital: String = "N / A" {
        didSet {
            textLabel.text = {
                if ($0 == "") {
                    return ""
                }
                let string = CFStringCreateMutableCopy(nil, 0, $0)
                CFStringTransform(string, nil, kCFStringTransformToLatin, false)
                CFStringTransform(string, nil, kCFStringTransformStripCombiningMarks, false)
                return (string as NSString).substringToIndex(1).uppercaseString
            }(capital)
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
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        setup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "AvatarView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    func setup() {
        layer.cornerRadius = CGRectGetWidth(frame) / 2.0
        layer.masksToBounds = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        backgroundColor = UIColor.randomFlatColor()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    
    // If you add custom drawing, it'll be behind any view loaded from XIB
    
    
    }
    */
}
