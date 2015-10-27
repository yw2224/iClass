//
//  CrossDissolve.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/21.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CrossDissolveSegue: UIStoryboardSegue {
    
    var image: UIImage?
    
    override func perform() {
        
        let svc = sourceViewController 
        let dvc = destinationViewController 
        
        let popOverView: UIImageView = {
            let length = min(CGRectGetWidth(svc.view.frame), CGRectGetHeight(svc.view.frame))
            let square = CGRectMake(0, 0, length, length)
            let center = svc.view.center
            let popOverView = UIImageView(frame: square)
            popOverView.center = center
            popOverView.contentMode = .ScaleAspectFit
            popOverView.alpha = 0.5
            popOverView.image = self.image ?? UIImage(named: "DefaultBookCover")
            return popOverView
        }()
        svc.view.addSubview(popOverView)
        
        // Transformation start scale
        popOverView.transform = CGAffineTransformMakeScale(0.15, 0.15)
        
        UIView.animateWithDuration(0.6,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                popOverView.transform = CGAffineTransformMakeScale(3, 3)
                popOverView.alpha = 0
            }) {
                if $0 {
                    svc.presentViewController(dvc, animated: false) {
                        popOverView.removeFromSuperview()
                    }
                }
            }
    }
}
