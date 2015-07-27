//
//  CircleView.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    var shapeLayer: CAShapeLayer!
    var restShapeLayer: CAShapeLayer!
    var percentage : CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
//        if shapeLayer != nil && restShapeLayer != nil {
//            return
//        }
        shapeLayer?.removeFromSuperlayer()
        restShapeLayer?.removeFromSuperlayer()
        
        let arcCenter = CGPointMake(frame.width / 2.0, frame.height / 2.0)
        var startAngle = -CGFloat(M_PI_2)
        let endAngle = CGFloat(2.0 * M_PI) * percentage / 100.0 + startAngle
        var path = UIBezierPath(arcCenter: arcCenter, radius: frame.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor(red: 20.0 / 255.0, green: 154.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0).CGColor
        shapeLayer.lineWidth = 6
        
        if fabs(endAngle - startAngle) <= 1e-9 {
            startAngle += CGFloat(2 * M_PI)
        }
        path = UIBezierPath(arcCenter: arcCenter, radius: frame.width / 2.0, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        restShapeLayer = CAShapeLayer()
        restShapeLayer.path = path.CGPath
        restShapeLayer.fillColor = UIColor.clearColor().CGColor
        restShapeLayer.strokeColor = UIColor(red: 203.0 / 255.0, green: 213.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0).CGColor
        restShapeLayer.lineWidth = 6
        
        layer.addSublayer(shapeLayer)
        layer.addSublayer(restShapeLayer)
        
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
