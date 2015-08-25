//
//  Splash2ViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/22.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class Splash2ViewController: SplashViewController {
    @IBOutlet weak var confirm: UIImageView!
    @IBOutlet weak var note1: UIImageView!
    @IBOutlet weak var note2: UIImageView!
    @IBOutlet weak var confirmWidth: NSLayoutConstraint!
    @IBOutlet weak var note1Width: NSLayoutConstraint!
    @IBOutlet weak var note2Width: NSLayoutConstraint!
    
    var confirmTopToTLG: NSLayoutConstraint!
    var confirmLeftToLeading: NSLayoutConstraint!
    var note1TopToTLG: NSLayoutConstraint!
    var note1LeftToLeading: NSLayoutConstraint!
    var note2TopToTLG: NSLayoutConstraint!
    var note2LeftToLeading: NSLayoutConstraint!
    
    private struct Constants {
        static let confirmTopRatio: CGFloat   = 601.0 / 736.0
        static let confirmLeftRatio: CGFloat  = 122.0 / 414.0
        static let confirmWidthRatio: CGFloat = 71.0 / 414.0
        static let note1TopRatio: CGFloat     = 511.0 / 736.0
        static let note1LeftRatio: CGFloat    = 39.0 / 414.0
        static let note1WidthRatio: CGFloat   = 31.0 / 414.0
        static let note2TopRatio: CGFloat     = 570.0 / 736.0
        static let note2LeftRatio: CGFloat    = 20.0 / 414.0
        static let note2WidthRatio: CGFloat   = 56.0 / 414.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "Splash2")
        
        let width  = CGRectGetWidth(view.frame)
        let height = CGRectGetHeight(view.frame)
        confirmTopToTLG = NSLayoutConstraint(
            item: confirm,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.confirmTopRatio * height)
        confirmLeftToLeading = NSLayoutConstraint(
            item: confirm,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.confirmLeftRatio * width)
        note1TopToTLG = NSLayoutConstraint(
            item: note1,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.note1TopRatio * height)
        note1LeftToLeading = NSLayoutConstraint(
            item: note1,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.note1LeftRatio * width)
        note2TopToTLG = NSLayoutConstraint(
            item: note2,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.note2TopRatio * height)
        note2LeftToLeading = NSLayoutConstraint(
            item: note2,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.note2LeftRatio * width)
        
        confirmWidth.constant = Constants.confirmWidthRatio * width
        note1Width.constant   = Constants.note1WidthRatio * width
        note2Width.constant   = Constants.note2WidthRatio * width
        
        confirm.setTranslatesAutoresizingMaskIntoConstraints(false)
        note1.setTranslatesAutoresizingMaskIntoConstraints(false)
        note2.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([confirmTopToTLG, confirmLeftToLeading, note1TopToTLG, note1LeftToLeading, note2TopToTLG, note2LeftToLeading])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = CGRectGetHeight(view.frame)
        if topLayoutGuide.length == 0 {
            // Lengthen the autolayout constraint to where we know the
            // top layout guide will be when the transition completes
            confirmTopToTLG.constant = Constants.confirmTopRatio * height + parentTLGlength
            note1TopToTLG.constant   = Constants.note1TopRatio * height + parentTLGlength
            note2TopToTLG.constant   = Constants.note2TopRatio * height + parentTLGlength
        } else {
            confirmTopToTLG.constant = Constants.confirmTopRatio * height
            note1TopToTLG.constant   = Constants.note1TopRatio * height
            note2TopToTLG.constant   = Constants.note2TopRatio * height
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

extension Splash2ViewController: AnimationControl {
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
