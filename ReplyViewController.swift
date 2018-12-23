//
//  ReplyViewController.swift
//  SmartClass
//
//  Created by Xiaoyu on 2017/1/7.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD


class ReplyViewController: UIViewController {
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var courseID: String!
    var type: String!
    var postingID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let panGesture = UIPanGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBOutlet weak var justalabel: UILabel!
    
    @IBOutlet weak var contentTextField: UITextView!
    
    @IBAction func post(sender: UIButton) {
        
        let content = contentTextField.text
        
        print("postType:" + self.type)
        ContentManager.sharedInstance.Replyposting(ContentManager.UserID, token: ContentManager.Token, postingID: self.postingID, content: content) {
            (newReply, error) in
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
        self.navigationController?.popViewControllerAnimated(true)
        //performSegueWithIdentifier("BackToPostSegue", sender: self)
        

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BackToPostSegue"
        {
            if let dest = segue.destinationViewController as? PostTableViewController
            {
                dest.courseID = courseID
                dest.currentSeg = type
                dest.postID = self.postingID
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
