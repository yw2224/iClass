//
//  CircleView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PercentageView: UIView {
    
    private struct Constants {
        static let Pending: CGFloat = -1.0
    }
    
    var view: UIView!
    var arc1: CAShapeLayer!
    var arc2: CAShapeLayer!
    var percentage: CGFloat = Constants.Pending {
        didSet {
            if percentage == Constants.Pending {
                arc1.hidden = true
                arc2.hidden = true
                percentageLabel.hidden = true
                activity.startAnimating()
            } else {
                arc1.hidden = false
                arc2.hidden = false
                percentageLabel.hidden = false
                percentageLabel.text = "\(min(max(percentage, 0), 100))%"
                setNeedsDisplay()
            }
        }
    }
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
        layerSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        layerSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func layerSetup() {
        arc1 = CAShapeLayer()
        arc2 = CAShapeLayer()
        
        layer.addSublayer(arc1)
        layer.addSublayer(arc2)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "PercentageView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        println("redraw")
        arc1?.removeFromSuperlayer()
        arc2?.removeFromSuperlayer()
        
        var startAngle = -CGFloat(M_PI_2)
        let endAngle = CGFloat(2.0 * M_PI) * percentage / 100.0 + startAngle
        var path = UIBezierPath(arcCenter: center, radius: frame.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        arc1 = CAShapeLayer()
        arc1.path = path.CGPath
        arc1.fillColor = UIColor.clearColor().CGColor
        arc1.strokeColor = UIColor(red: 20.0 / 255.0, green: 154.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0).CGColor
        arc1.lineWidth = 6
        
        if fabs(endAngle - startAngle) <= 1e-9 {
            startAngle += CGFloat(2 * M_PI)
        }
        path = UIBezierPath(arcCenter: center, radius: frame.width / 2.0, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        arc2 = CAShapeLayer()
        arc2.path = path.CGPath
        arc2.fillColor = UIColor.clearColor().CGColor
        arc2.strokeColor = UIColor(red: 203.0 / 255.0, green: 213.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0).CGColor
        arc2.lineWidth = 6
        
        layer.addSublayer(arc1)
        layer.addSublayer(arc2)
        
//        MARK: shadow settings
//        layer.cornerRadius = frame.width / 2.0
//        layer.backgroundColor = UIColor.clearColor().CGColor
//        layer.shadowOpacity = 0.7
//        layer.shadowColor = UIColor.blackColor().CGColor
//        layer.shadowOffset = CGSizeMake(0.0, 2.0)
//        layer.shadowRadius = 2.0
//        
        layer.shouldRasterize = true;
        layer.rasterizationScale = UIScreen.mainScreen().scale;
    }

}
