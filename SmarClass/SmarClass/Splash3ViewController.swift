//
//  Splash3ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import AVFoundation

class Splash3ViewController: SplashViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var laugh: UIImageView!
    @IBOutlet weak var cry: UIImageView!
    
    @IBOutlet weak var laughTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var laughLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var cryTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var cryLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var laughWidth: NSLayoutConstraint!
    @IBOutlet weak var cryWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    
    private struct Constants {
        static let laughTopRatio: CGFloat   = 205.0 / 716.0
        static let laughLeftRatio: CGFloat  = 32.0 / 414.0
        static let laughWidthRatio: CGFloat = 67.0 / 414.0
        static let cryTopRatio: CGFloat     = 175.0 / 716.0
        static let cryLeftRatio: CGFloat    = 345.0 / 414.0
        static let cryWidthRatio: CGFloat   = 61.0 / 414.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appendTopSpaceLayoutConstraint(imageViewTop)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let imageSize      = imageView.image!.size
        let imageViewFrame = CGRectMake(0, parentTLGlength, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame) - parentTLGlength)
        let imageBounds    = AVMakeRectWithAspectRatioInsideRect(imageSize, imageViewFrame)
        let width          = imageBounds.width
        let height         = imageBounds.height
        
        laughTopToTLG.constant      = Constants.laughTopRatio * height
        laughLeftToLeading.constant = Constants.laughLeftRatio * width + imageBounds.origin.x
        cryTopToTLG.constant        = Constants.cryTopRatio * height
        cryLeftToLeading.constant   = Constants.cryLeftRatio * width + imageBounds.origin.x
        
        laughWidth.constant = Constants.laughWidthRatio * width
        cryWidth.constant   = Constants.cryWidthRatio * width
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

extension Splash3ViewController: AnimationControl {
    override func setupAnimation() {
        let move = NSValue(CATransform3D: CATransform3DMakeTranslation(0, 2, 0))
        let offset = CAKeyframeAnimation(keyPath: "transform")
        offset.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            move
        ]
        offset.autoreverses = true
        offset.repeatCount = 5
        offset.duration = 0.1
        laugh.layer.addAnimation(offset, forKey: "transformation")
        
        let move2 = NSValue(CATransform3D: CATransform3DMakeTranslation(-3, -1, 0))
        let offset2 = CAKeyframeAnimation(keyPath: "transform")
        offset2.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            move2
        ]
        offset2.autoreverses = true
        offset2.repeatCount = 5
        offset2.duration = 0.1
        cry.layer.addAnimation(offset2, forKey: "transformation")
    }
    
    override func removeAnimation() {
        laugh.layer.removeAllAnimations()
        cry.layer.removeAllAnimations()
    }
}
