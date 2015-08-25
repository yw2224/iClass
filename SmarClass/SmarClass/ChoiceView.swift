//
//  ChoiceView.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/8.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class ChoiceView: UIView {

	var isSelected : Bool = false
	var path :UIBezierPath = UIBezierPath()
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let width = rect.size.width
		let height = rect.size.height
		let margin : CGFloat = 2.0
		let origin  = CGPoint(x: rect.origin.x + margin, y: rect.origin.y + margin)
		let size = CGSize(width: width - margin*2, height: height - margin*2)
		let pathRect = CGRect(origin: origin, size: size)
		let path = UIBezierPath(ovalInRect: pathRect)
		UIColor.blackColor().setStroke()
		let context = UIGraphicsGetCurrentContext()
		path.lineWidth = 2.0
		path.stroke()
//		CGContextStrokePath(context)
		path.stroke()
		if isSelected {
			UIColor.greenColor().setFill()
//			CGContextFillPath(context)
			path.fill()
		}else {
			UIColor.clearColor().setFill()
//			CGContextFillPath(context)
			path.fill()
		}
		self.path = path
    }

	func setSelected(){
		isSelected = true
		setNeedsDisplay()
	}
	func setUnSelected(){
		isSelected = false
		setNeedsDisplay()
	}

}
