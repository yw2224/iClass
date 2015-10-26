//
//  ChoiceView.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/8.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class ChoiceView: UIView {

    var view: UIView!
    var selected: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var correct: Bool = false {
        didSet {
            if correct {
                setNeedsDisplay()
            }
        }
    }
    var numberIndex: Int! {
        didSet {
            letterLabel.text = convertToTitle(max(min(numberIndex, 25), 0))
        }
    }
    var circleLayer: CAShapeLayer!

    @IBOutlet weak var letterLabel: UILabel!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
        layerSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        backgroundColor = UIColor.clearColor()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "ChoiceView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    func layerSetup() {
        circleLayer?.removeFromSuperlayer()
        
        circleLayer = CAShapeLayer()
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor = UIColor.flatWatermelonColor().CGColor
        circleLayer.fillColor = UIColor.clearColor().CGColor
        layer.addSublayer(circleLayer)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    /**
    Convert string into title, e.g., 1 -> A, 1 -> B ... 27 -> AA
    - parameter n: n int
    - returns: converted string
    */
    func convertToTitle(var number: Int) -> String {
        var ret = ""
        repeat {
            let A = ("A" as Character).unicodeScalarCodePoint() + (--number) % 26
            let c = Character(UnicodeScalar(UInt32(A)))
            ret = String(c) + ret
            number /= 26
        } while (number != 0)
        return ret
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        letterLabel.textColor = selected || correct ? UIColor.whiteColor() : UIColor.flatWatermelonColor()
        circleLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        if correct {
            circleLayer.strokeColor = UIColor.flatLimeColor().CGColor
            circleLayer.fillColor = UIColor.flatLimeColor().CGColor
        } else {
            circleLayer.strokeColor = UIColor.flatWatermelonColor().CGColor
            circleLayer.fillColor = selected ? UIColor.flatWatermelonColor().CGColor :
                UIColor.clearColor().CGColor
        }
        bringSubviewToFront(view)
    }

}
