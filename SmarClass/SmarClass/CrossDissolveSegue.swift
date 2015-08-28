//
//  CrossDissolve.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/21.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CrossDissolveSegue: UIStoryboardSegue {
    
    override func perform() {
        let svc = sourceViewController as! UIViewController
        let dvc = destinationViewController as! UIViewController
        
        let frame = svc.view.frame
        let center = svc.view.center
        let blankView = UIView(frame: frame)
        blankView.center = center
        blankView.backgroundColor = UIColor.whiteColor()
        svc.view.addSubview(blankView)
        
        // Transformation start scale
        blankView.transform = CGAffineTransformMakeScale(0.15, 0.15);
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                blankView.transform = CGAffineTransformIdentity
            }) {finished in
                if finished {
                    svc.presentViewController(dvc, animated: false) {
                        blankView.removeFromSuperview()
                    }
            }
        }
        
    }
}
