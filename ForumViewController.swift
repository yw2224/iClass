//
//  ForumViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/4.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForumViewController: UIViewController {

    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContentManager.sharedInstance.exList(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, type: "EX", page: 1) {
            (exList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
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
