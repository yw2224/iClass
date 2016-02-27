//
//  CircleView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PercentageView: UIView {
    
    var arc1: CAShapeLayer!
    var arc2: CAShapeLayer!
    var percentageLabel: UILabel!
    
    var percentage: CGFloat = Constants.Pending {
        didSet {
            percentageLabel.hidden = percentage == Constants.Pending
            percentageLabel.text = "\(min(max(percentage * 100, 0), 100).format(".0f"))"
            setNeedsDisplay()
        }
    }
    
    private struct Constants {
        static let Pending: CGFloat = -1.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        labelSetup()
        layerSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        labelSetup()
        layerSetup()
    }
    
    func labelSetup() {
        percentageLabel = UILabel(frame: CGRectZero)
        percentageLabel.textAlignment = .Center
        percentageLabel.font = UIFont.systemFontOfSize(14.0)
        
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(percentageLabel)
        let centerX = NSLayoutConstraint(item: percentageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: percentageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        addConstraints([centerX, centerY])
    }
    
    func layerSetup() {
        arc1?.removeFromSuperlayer()
        arc2?.removeFromSuperlayer()
        
        let radius     = min(CGRectGetWidth(frame), CGRectGetHeight(frame)) / 2.0
        let center     = CGPointMake(radius, radius)
        var startAngle = -CGFloat(M_PI_2)
        let endAngle   = CGFloat(2.0 * M_PI) * percentage + startAngle
        var path       = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        arc1             = CAShapeLayer()
        arc1.path        = path.CGPath
        arc1.fillColor   = UIColor.clearColor().CGColor
        arc1.strokeColor = circleColor(percentage).CGColor
        arc1.lineWidth   = 4
        
        if fabs(endAngle - startAngle) <= 1e-10 {
            startAngle += CGFloat(2 * M_PI)
        }
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        arc2             = CAShapeLayer()
        arc2.path        = path.CGPath
        arc2.fillColor   = UIColor.clearColor().CGColor
        arc2.strokeColor = UIColor.flatWhiteColorDark().CGColor
        arc2.lineWidth   = 4
        
        arc1.hidden = percentage == Constants.Pending
        arc2.hidden = percentage == Constants.Pending
        
        layer.addSublayer(arc1)
        layer.addSublayer(arc2)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        layerSetup()
    }
    
    func circleColor(percentage: CGFloat) -> UIColor {
        switch percentage {
        case 0 ..< 0.60:
            return UIColor.flatRedColor()
        case 0.60 ..< 0.85:
            return UIColor.flatSandColor()
        case 0.85 ... 1:
            return UIColor.flatLimeColor()
        default:
            return UIColor.flatWhiteColorDark()
        }
    }
}
