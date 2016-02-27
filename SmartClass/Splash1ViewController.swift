//
//  Splash1ViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import AVFoundation

class Splash1ViewController: SplashViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var smileLeft: UIImageView!
    @IBOutlet weak var smileRight: UIImageView!
    @IBOutlet weak var bulb: UIImageView!

    @IBOutlet weak var bulbWidth: NSLayoutConstraint!
    @IBOutlet weak var smileLeftWidth: NSLayoutConstraint!
    @IBOutlet weak var smileRightWidth: NSLayoutConstraint!
    @IBOutlet weak var bulbTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var bulbLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var smileLeftTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var smileLeftLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var smileRightTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var smileRightLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!

    private struct Constants {
        static let bulbTopRatio: CGFloat         = 182.0 / 716.0
        static let bulbLeftRatio: CGFloat        = 207.0 / 414.0
        static let bulbWidthRatio: CGFloat       = 25.0 / 414.0
        static let smileLeftTopRatio: CGFloat    = 467.0 / 716.0
        static let smileLeftLeftRatio: CGFloat   = 193.0 / 414.0
        static let smileLeftWidthRatio: CGFloat  = 12.0 / 414.0
        static let smileRightTopRatio: CGFloat   = 460.0 / 716.0
        static let smileRightLeftRatio: CGFloat  = 237.0 / 414.0
        static let smileRightWidthRatio: CGFloat = 12.0 / 414.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        appendTopSpaceLayoutConstraint(imageViewTop)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let imageSize = imageView.image!.size
        let imageViewFrame = CGRectMake(0, parentTLGlength, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame) - parentTLGlength)
        let imageBounds = AVMakeRectWithAspectRatioInsideRect(imageSize, imageViewFrame)
        let width = imageBounds.width
        let height = imageBounds.height
        
        bulbTopToTLG.constant = Constants.bulbTopRatio * height
        bulbLeftToLeading.constant = Constants.bulbLeftRatio * width + imageBounds.origin.x
        smileLeftTopToTLG.constant = Constants.smileLeftTopRatio * height
        smileLeftLeftToLeading.constant = Constants.smileLeftLeftRatio * width + imageBounds.origin.x
        smileRightTopToTLG.constant = Constants.smileRightTopRatio * height
        smileRightLeftToLeading.constant = Constants.smileRightLeftRatio * width + imageBounds.origin.x
        
        bulbWidth.constant       = Constants.bulbWidthRatio * width
        smileLeftWidth.constant  = Constants.smileLeftWidthRatio * width
        smileRightWidth.constant = Constants.smileRightWidthRatio * width
    }

}

// MARK: AnimationControl
extension Splash1ViewController {
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
