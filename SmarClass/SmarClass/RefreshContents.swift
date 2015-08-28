//
//  RefreshContents.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/27.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class RefreshContents: UIView {
    @IBOutlet weak var spot: UIImageView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var refreshingImageView: UIImageView!
    var view: UIView!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
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
        let nib = UINib(nibName: "RefreshContents", bundle: bundle)
        
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