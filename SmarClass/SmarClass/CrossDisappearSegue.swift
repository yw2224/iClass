//
//  CrossDisappear.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/21.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CrossDisappearSegue: UIStoryboardSegue {
   
    override func perform() {
        let svc = sourceViewController as! UIViewController
        let dvc = destinationViewController as! UIViewController
        
        let frame = svc.view.frame
        let center = svc.view.center
        let snapShotView = UIImageView(frame: frame)
        let whiteView = UIView(frame: frame)
        whiteView.backgroundColor = UIColor.whiteColor()
        snapShotView.center = center
        whiteView.center = center
        
        UIGraphicsBeginImageContext(svc.view.bounds.size);
        svc.view.layer.renderInContext(UIGraphicsGetCurrentContext())
        snapShotView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        svc.view.addSubview(whiteView)
        svc.view.addSubview(snapShotView)
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                snapShotView.transform = CGAffineTransformMakeScale(0.15, 0.15)
                dvc.view.alpha = 1.0
            }) {finished in
                if finished {
                    whiteView.removeFromSuperview()
                    snapShotView.removeFromSuperview()
                    dvc.dismissViewControllerAnimated(false, completion: nil)
                }
        }
    }
}
