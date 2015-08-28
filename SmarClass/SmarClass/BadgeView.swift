//
//  BadgeView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit


class BadgeView: UIView {
    
    var view: UIView!
    var badgeNum: Int = 0 {
        didSet {
            if badgeNum == 0 {
                textLabel.hidden = true
                hidden = true
                return
            }
            
            textLabel.hidden = false
            hidden = false
            textLabel.text = String(min(badgeNum, Constants.MaxBadgeNum))
            textLabel.sizeToFit()
            setNeedsDisplay()
        }
    }
    @IBOutlet weak var textLabel: UILabel!

    private struct Constants {
        static let MaxBadgeNum = 99
        static let CornerRadiusOffset: CGFloat = 3.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        setupTextLabel()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        setupTextLabel()
    }
    
    func setupTextLabel() {
        textLabel.hidden = true
        
        layer.masksToBounds = true
        layer.cornerRadius = (CGRectGetWidth(frame) - Constants.CornerRadiusOffset) / 2.0
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        //        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "BadgeView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    
    // If you add custom drawing, it'll be behind any view loaded from XIB
    
    
    }
    */
}