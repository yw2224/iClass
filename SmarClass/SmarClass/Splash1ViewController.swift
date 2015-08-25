//
//  Splash1ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class Splash1ViewController: SplashViewController {

    @IBOutlet weak var smileLeft: UIImageView!
    @IBOutlet weak var smileRight: UIImageView!
    @IBOutlet weak var bulb: UIImageView!

    @IBOutlet weak var bulbWidth: NSLayoutConstraint!
    @IBOutlet weak var smileLeftWidth: NSLayoutConstraint!
    @IBOutlet weak var smileRightWidth: NSLayoutConstraint!
    var bulbTopToTLG: NSLayoutConstraint!
    var bulbLeftToLeading: NSLayoutConstraint!
    var smileLeftTopToTLG: NSLayoutConstraint!
    var smileLeftLeftToLeading: NSLayoutConstraint!
    var smileRightTopToTLG: NSLayoutConstraint!
    var smileRightLeftToLeading: NSLayoutConstraint!

    private struct Constants {
        static let bulbTopRatio: CGFloat         = 185.0 / 736.0
        static let bulbLeftRatio: CGFloat        = 207.0 / 414.0
        static let bulbWidthRatio: CGFloat       = 25.0 / 414.0
        static let smileLeftTopRatio: CGFloat    = 466.0 / 736.0
        static let smileLeftLeftRatio: CGFloat   = 193.0 / 414.0
        static let smileLeftWidthRatio: CGFloat  = 12.0 / 414.0
        static let smileRightTopRatio: CGFloat   = 460.0 / 736.0
        static let smileRightLeftRatio: CGFloat  = 239.0 / 414.0
        static let smileRightWidthRatio: CGFloat = 12.0 / 414.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let width  = CGRectGetWidth(view.frame)
        let height = CGRectGetHeight(view.frame)
        imageView.image = UIImage(named: "Splash1")
        bulbTopToTLG = NSLayoutConstraint(
            item: bulb,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.bulbTopRatio * height)
        bulbLeftToLeading = NSLayoutConstraint(
            item: bulb,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.bulbLeftRatio * width)
        smileLeftTopToTLG = NSLayoutConstraint(
            item: smileLeft,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.smileLeftTopRatio * height)
        smileLeftLeftToLeading = NSLayoutConstraint(
            item: smileLeft,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.smileLeftLeftRatio * width)
        smileRightTopToTLG = NSLayoutConstraint(
            item: smileRight,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.smileRightTopRatio * height)
        smileRightLeftToLeading = NSLayoutConstraint(
            item: smileRight,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.smileRightLeftRatio * width)
        
        bulbWidth.constant       = Constants.bulbWidthRatio * width
        smileLeftWidth.constant  = Constants.smileLeftWidthRatio * width
        smileRightWidth.constant = Constants.smileRightWidthRatio * width
        
        bulb.setTranslatesAutoresizingMaskIntoConstraints(false)
        smileLeft.setTranslatesAutoresizingMaskIntoConstraints(false)
        smileRight.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([bulbTopToTLG, bulbLeftToLeading, smileLeftTopToTLG, smileLeftLeftToLeading, smileRightTopToTLG, smileRightLeftToLeading])
        
        view.bringSubviewToFront(bulb)
        view.bringSubviewToFront(smileLeft)
        view.bringSubviewToFront(smileRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = CGRectGetHeight(view.frame)
        if topLayoutGuide.length == 0 {
            // Lengthen the autolayout constraint to where we know the
            // top layout guide will be when the transition completes
            bulbTopToTLG.constant       = Constants.bulbTopRatio * height + parentTLGlength
            smileLeftTopToTLG.constant  = Constants.smileLeftTopRatio * height + parentTLGlength
            smileRightTopToTLG.constant = Constants.smileRightTopRatio * height + parentTLGlength
        } else {
            bulbTopToTLG.constant       = Constants.bulbTopRatio * height
            smileLeftTopToTLG.constant  = Constants.smileLeftTopRatio * height
            smileRightTopToTLG.constant = Constants.smileRightTopRatio * height
        }
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

extension Splash1ViewController: AnimationControl {
    override func setupAnimation() {
        let small = NSValue(CATransform3D: CATransform3DMakeScale(0.8, 0.8, 1.0))
        
        let scale = CAKeyframeAnimation(keyPath: "transform")
        scale.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            small
        ]
        scale.autoreverses = true
        scale.repeatCount = 5
        scale.duration = 0.3
        bulb.layer.addAnimation(scale, forKey: "scale")
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = M_PI * 2.0
        rotate.duration = 0.5
        rotate.cumulative = true
        rotate.repeatCount = 5
        
        smileLeft.layer.addAnimation(rotate, forKey: "rotation")
        smileRight.layer.addAnimation(rotate, forKey: "rotation")
    }
    
    override func removeAnimation() {
        bulb.layer.removeAllAnimations()
        smileLeft.layer.removeAllAnimations()
        smileRight.layer.removeAllAnimations()
    }
}
