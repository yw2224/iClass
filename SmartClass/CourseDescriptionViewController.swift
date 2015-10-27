//
//  CourseDescriptionViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/2.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class CourseDescriptionViewController: UIViewController {

    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.text = "\t\(text)"
        
        // tips: set textView scroll to top, see stackoverflow for details.
        // http://stackoverflow.com/questions/1343894/refresh-uitextviews-scroll-position-on-iphone
        textView.scrollRangeToVisible(NSMakeRange(0, 0))
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
