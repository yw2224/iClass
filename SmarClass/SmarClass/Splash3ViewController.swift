//
//  Splash3ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class Splash3ViewController: SplashViewController {
    @IBOutlet weak var laugh: UIImageView!
    @IBOutlet weak var cry: UIImageView!
    @IBOutlet weak var laughWidth: NSLayoutConstraint!
    @IBOutlet weak var cryWidth: NSLayoutConstraint!
    
    var laughTopToTLG: NSLayoutConstraint!
    var laughLeftToLeading: NSLayoutConstraint!
    var cryTopToTLG: NSLayoutConstraint!
    var cryLeftToLeading: NSLayoutConstraint!
    
    private struct Constants {
        static let laughTopRatio: CGFloat   = 206.0 / 736.0
        static let laughLeftRatio: CGFloat  = 25.0 / 414.0
        static let laughWidthRatio: CGFloat = 67.0 / 414.0
        static let cryTopRatio: CGFloat     = 178.0 / 736.0
        static let cryLeftRatio: CGFloat    = 347.0 / 414.0
        static let cryWidthRatio: CGFloat   = 61.0 / 414.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "Splash3")
        let width  = CGRectGetWidth(view.frame)
        let height = CGRectGetHeight(view.frame)
        laughTopToTLG = NSLayoutConstraint(
            item: laugh,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.laughTopRatio * height)
        laughLeftToLeading = NSLayoutConstraint(
            item: laugh,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.laughLeftRatio * width)
        cryTopToTLG = NSLayoutConstraint(
            item: cry,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.cryTopRatio * height)
        cryLeftToLeading = NSLayoutConstraint(
            item: cry,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.cryLeftRatio * width)
        
        laughWidth.constant = Constants.laughWidthRatio * width
        cryWidth.constant   = Constants.cryWidthRatio * width
        
        laugh.setTranslatesAutoresizingMaskIntoConstraints(false)
        cry.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([laughTopToTLG, laughLeftToLeading, cryTopToTLG, cryLeftToLeading])
        
        view.bringSubviewToFront(laugh)
        view.bringSubviewToFront(cry)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = CGRectGetHeight(view.frame)
        if topLayoutGuide.length == 0 {
            // Lengthen the autolayout constraint to where we know the
            // top layout guide will be when the transition completes
            laughTopToTLG.constant = Constants.laughTopRatio * height + parentTLGlength
            cryTopToTLG.constant   = Constants.cryTopRatio * height + parentTLGlength
        } else {
            laughTopToTLG.constant = Constants.laughTopRatio * height
            cryTopToTLG.constant   = Constants.cryTopRatio * height
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
