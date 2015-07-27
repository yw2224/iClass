//
//  ViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class SplashViewController: IndexViewController {
    
    private struct Constants {
        static let imageName = ["Deadline", "Deadline", "Deadline", "Deadline"]
        static let colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.yellowColor(), UIColor.blueColor()]
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        if index >= 0 && index < Constants.imageName.count {
            imageView.image = UIImage(named: Constants.imageName[index])
        }
        if index >= 0 && index < Constants.colors.count {
            view.backgroundColor = Constants.colors[index]
        }
    }
}
