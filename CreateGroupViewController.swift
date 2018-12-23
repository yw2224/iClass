//
//  CreateGroupViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/6.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var leaderNameLabel: UILabel!
    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leaderNameLabel.text = "组长：" + ContentManager.UserName!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: UIButton) {
        let groupName = self.groupName.text
        
        ContentManager.sharedInstance.createGroup(ContentManager.UserID, token: ContentManager.Token, courseID: self.courseID, leaderName: ContentManager.UserName, groupName: groupName) {
            (newGroup, error) in
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
