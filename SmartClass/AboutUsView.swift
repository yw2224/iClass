
//
//  AboutUsView.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/10.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class AboutUsView: CustomView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    private struct Constants {
        static let CardBackgroundColor: [UIColor] = {
            let colors = [
                UIColor.flatWatermelonColor(),
                UIColor.flatYellowColor(),
                UIColor.flatLimeColor(),
                UIColor.flatPowderBlueColor(),
                UIColor.flatSandColor()
            ]
            let colors2 = [
                UIColor.flatRedColor(),
                UIColor.flatOrangeColor(),
                UIColor.flatGreenColor(),
                UIColor.flatSkyBlueColor(),
                UIColor.flatCoffeeColor()
            ]
            return zip(colors, colors).map {
                UIColor(gradientStyle: .Radial, withFrame: UIScreen.mainScreen().bounds, andColors: [$0.0, $0.1])
            }
        }()
        static let texts = [
            "课堂助手 —— 让课堂学习更贴心 v1.0.0",
            "赵鹏 —— iOS客户端作者，Node后端作者",
            "段祎纯 —— Android客户端作者",
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
    
    
    func layerSetup() {
        view.layer.cornerRadius  = 3.0
        view.layer.masksToBounds = true
        
        layer.shadowPath    = UIBezierPath(roundedRect: frame, cornerRadius: 3.0).CGPath
        layer.shadowOpacity = 0.7
        layer.shadowOffset  = CGSizeZero
        layer.shadowRadius  = 4.0
        
        textLabel.startGlow(UIColor.flatYellowColor())
    }
    
    func setupWithIndex(index: Int) {
        let index = min(max(index, 0), Constants.CardBackgroundColor.count - 1)
        view.backgroundColor = Constants.CardBackgroundColor[index]
        textLabel.text = Constants.texts[index]
        imageView.image = UIImage(named: Constants.imageNames[index])
    }
}
