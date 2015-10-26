//
//  Splash0ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import AVFoundation

class Splash0ViewController: SplashViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var clockWidth: NSLayoutConstraint!
    @IBOutlet weak var clockTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var clockLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    
    private struct Constants {
        static let topRatio: CGFloat = 434.0 / 716.0
        static let leftRatio: CGFloat = 70.0 / 414.0
        static let widthRatio: CGFloat = 109.0 / 414.0
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
        
        clockTopToTLG.constant = Constants.topRatio * imageBounds.height
        clockLeftToLeading.constant = Constants.leftRatio * imageBounds.width + imageBounds.origin.x
        clockWidth.constant = Constants.widthRatio * imageBounds.width
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

// AnimationControl 
extension Splash0ViewController {
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
