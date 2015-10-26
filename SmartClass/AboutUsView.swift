
//
//  AboutUsView.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/10.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class AboutUsView: UIView {

    var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    private struct Constants {
        static let CardBackgroundColor: [UIColor] = {
            let arrayOf4Color = [UIColor.flatWatermelonColor(), UIColor.flatYellowColor(), UIColor.flatLimeColor(), UIColor.flatPowderBlueColor(), UIColor.flatSandColor()]
            let anotherOf4Color = [UIColor.flatRedColor(), UIColor.flatOrangeColor(), UIColor.flatGreenColor(), UIColor.flatSkyBlueColor(), UIColor.flatCoffeeColor()]
            var gradientColorArray = [UIColor]()
            for (index, color) in arrayOf4Color.enumerate() {
                gradientColorArray.append(UIColor(gradientStyle: .Radial, withFrame: UIScreen.mainScreen().bounds, andColors: [color, anotherOf4Color[index]]))
            }
            return gradientColorArray
        }()
        static let texts = [
            "课堂助手 —— 让课堂学习更贴心 v1.0.0",
            "赵鹏 —— iOS客户端作者，Node后端作者",
            "段祎纯 —— 安卓客户端作者",
            "陈希 —— 美工",
            "特别感谢为此app开发做出帮助的人们，课堂助手的成长离不开你们的帮助！"
        ]
        static let imageNames = [
            "Blackboard",
            "Boy",
            "Girl1",
            "Girl2",
            "Heart"
        ]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        layerSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        layerSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func layerSetup() {
        view.layer.cornerRadius  = 3.0
        view.layer.masksToBounds = true
        
        layer.shadowPath    = UIBezierPath(roundedRect: frame, cornerRadius: 3.0).CGPath
        layer.shadowOpacity = 0.7
        layer.shadowOffset  = CGSizeZero
        layer.shadowRadius  = 4.0
        
        textLabel.startGlow(UIColor.flatYellowColor())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "AboutUsView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    func setupWithIndex(index: Int) {
        let index = min(max(index, 0), 4)
        view.backgroundColor = Constants.CardBackgroundColor[index]
        textLabel.text = Constants.texts[index]
        imageView.image = UIImage(named: Constants.imageNames[index])
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    
    // If you add custom drawing, it'll be behind any view loaded from XIB
    }
    */
}
