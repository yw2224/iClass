//
//  ImageViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/12/25.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class ImageViewController: UIViewController, UIWebViewDelegate {

    var url: String!
    var webView = UIWebView()
    
    @IBOutlet weak var showContent: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        print(url)
        
        //var str: String!
        //str = "http://www.icst.pku.edu.cn/lcwm/course/WebDataMining2016/slides/Lecture2.pdf"
        if let url = NSURL(string: url + "?_id=" + ContentManager.UserID! + "&token=" + ContentManager.Token!) {
            let request = NSURLRequest(URL: url)
           
            showContent.loadRequest(request)
            SVProgressHUD.showInfoWithStatus("加载中...")
            if showContent.loading == true
            {
                SVProgressHUD.dismiss()
                
            }
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
