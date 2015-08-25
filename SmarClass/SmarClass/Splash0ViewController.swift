//
//  Splash0ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class Splash0ViewController: SplashViewController {

    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var clockWidth: NSLayoutConstraint!
    var clockTopToTLG: NSLayoutConstraint!
    var clockLeftToLeading: NSLayoutConstraint!
    
    private struct Constants {
        static let topRatio: CGFloat = 431.0 / 736.0
        static let leftRatio: CGFloat = 74.0 / 414.0
        static let widthRatio: CGFloat = 109.0 / 414.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "Splash0")

        clockTopToTLG = NSLayoutConstraint(
            item: clock,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.topRatio * CGRectGetHeight(view.frame))
        clockLeftToLeading = NSLayoutConstraint(
            item: clock,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.leftRatio * CGRectGetWidth(view.frame))
        clockWidth.constant = Constants.widthRatio * CGRectGetWidth(view.frame)
        clock.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([clockTopToTLG, clockLeftToLeading])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if topLayoutGuide.length == 0 {
            // Lengthen the autolayout constraint to where we know the
            // top layout guide will be when the transition completes
            clockTopToTLG.constant = Constants.topRatio * CGRectGetHeight(view.frame) + parentTLGlength
        } else {
            clockTopToTLG.constant = Constants.topRatio * CGRectGetHeight(view.frame)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Splash0ViewController: AnimationControl {
    override func setupAnimation() {
        let leftBorder = NSValue(CATransform3D: CATransform3DMakeRotation(-CGFloat(M_PI) / 10, 0, 0, 1))
        
        let shake = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            leftBorder
        ]
        shake.autoreverses = true
        shake.repeatCount = 10
        shake.duration = 0.15
        clock.layer.addAnimation(shake, forKey: "shake")
    }
    
    override func removeAnimation() {
        clock.layer.removeAllAnimations()
    }
}
