//
//  PersonalCenterViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/12/13.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class PersonalCenterViewController: UIViewController {
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBOutlet weak var ShowuserName: UILabel!
    @IBOutlet weak var showid: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    func block(_: NetworkErrorType?) -> Void {
    }
    
    @IBAction func submitUserInfo(sender: UIButton) {
        
        

        
        ContentManager.sharedInstance.userInfo(userName.text!, password: passWord.text!, block: block)
        print(ContentManager.Token! + " " + ContentManager.realName! + " " + ContentManager.Password!)
        SVProgressHUD.showSuccessWithStatus("修改信息成功！")

        ShowuserName.text = userName.text!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let panGesture = UIPanGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
        self.navigationItem.title = "个人中心"
        ShowuserName.text = ContentManager.realName
        showid.text = ContentManager.UserName
        userName.text = ContentManager.realName
        passWord.text = ContentManager.Password
        // Do any additional setup after loading the view.
      print(userName.text)
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
