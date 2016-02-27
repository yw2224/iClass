//
//  ChoiceView.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/8.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class ChoiceView: CustomView {

    var selected: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var correct: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var numberIndex: Int = 1 {
        didSet {
            letterLabel.text = convertToTitle(numberIndex)
        }
    }
    
    var circleLayer: CAShapeLayer!
    
    @IBOutlet weak var letterLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        layerSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        layerSetup()
    }
    
    func layerSetup() {
        circleLayer?.removeFromSuperlayer()
        
        circleLayer = CAShapeLayer()
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor = UIColor.flatWatermelonColor().CGColor
        circleLayer.fillColor = UIColor.clearColor().CGColor
        layer.addSublayer(circleLayer)
    }
    
    /**
     Convert string into title, e.g., 1 -> A, 1 -> B ... 27 -> AA
     - parameter n: n int
     - returns: converted string
     */
    func convertToTitle(var number: Int) -> String {
        var ret = ""
        repeat {
            let letter = ("A" as Character).unicodeScalarCodePoint() + UInt32((--number) % 26)
            ret = String(UnicodeScalar(letter)) + ret
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
