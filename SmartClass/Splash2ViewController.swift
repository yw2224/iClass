//
//  Splash2ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import AVFoundation

class Splash2ViewController: SplashViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confirm: UIImageView!
    @IBOutlet weak var note1: UIImageView!
    @IBOutlet weak var note2: UIImageView!
    @IBOutlet weak var confirmWidth: NSLayoutConstraint!
    @IBOutlet weak var note1Width: NSLayoutConstraint!
    @IBOutlet weak var note2Width: NSLayoutConstraint!
    
    @IBOutlet weak var confirmTopToTLG: NSLayoutConstraint!
    @IBOutlet weak var confirmLeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var note1TopToTLG: NSLayoutConstraint!
    @IBOutlet weak var note1LeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var note2TopToTLG: NSLayoutConstraint!
    @IBOutlet weak var note2LeftToLeading: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    
    private struct Constants {
        static let confirmTopRatio: CGFloat   = 601.0 / 716.0
        static let confirmLeftRatio: CGFloat  = 120.0 / 414.0
        static let confirmWidthRatio: CGFloat = 71.0 / 414.0
        static let note1TopRatio: CGFloat     = 471.0 / 716.0
        static let note1LeftRatio: CGFloat    = 39.0 / 414.0
        static let note1WidthRatio: CGFloat   = 31.0 / 414.0
        static let note2TopRatio: CGFloat     = 550.0 / 716.0
        static let note2LeftRatio: CGFloat    = 20.0 / 414.0
        static let note2WidthRatio: CGFloat   = 56.0 / 414.0
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

        confirmTopToTLG.constant      = Constants.confirmTopRatio * height
        confirmLeftToLeading.constant = Constants.confirmLeftRatio * width + imageBounds.origin.x
        note1TopToTLG.constant        = Constants.note1TopRatio * height
        note1LeftToLeading.constant   = Constants.note1LeftRatio * width + imageBounds.origin.x
        note2TopToTLG.constant        = Constants.note2TopRatio * height
        note2LeftToLeading.constant   = Constants.note2LeftRatio * width + imageBounds.origin.x

        confirmWidth.constant = Constants.confirmWidthRatio * width
        note1Width.constant   = Constants.note1WidthRatio * width
        note2Width.constant   = Constants.note2WidthRatio * width
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

// MARK: AnimationControl
extension Splash2ViewController {
    override func setupAnimation() {
        let move = NSValue(CATransform3D: CATransform3DMakeTranslation(-3, 3, 0))
        let offset = CAKeyframeAnimation(keyPath: "transform")
        offset.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            move
        ]
        offset.autoreverses = true
        offset.repeatCount = 5
        offset.duration = 0.3
        note1.layer.addAnimation(offset, forKey: "transformation")
        
        let move2 = NSValue(CATransform3D: CATransform3DMakeTranslation(-3, -2, 0))
        let offset2 = CAKeyframeAnimation(keyPath: "transform")
        offset2.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            move2
        ]
        offset2.autoreverses = true
        offset2.repeatCount = 5
        offset2.duration = 0.3
        note2.layer.addAnimation(offset2, forKey: "transformation")
    }
    
    override func removeAnimation() {
        note1.layer.removeAllAnimations()
        note2.layer.removeAllAnimations()
    }
}
