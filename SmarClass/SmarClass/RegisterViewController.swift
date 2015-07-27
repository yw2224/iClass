//
//  RegisterViewController.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
//import MBProgressHUD
class RegisterViewController: UIViewController {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	@IBOutlet weak var messageLabel: UILabel!
	
	@IBOutlet weak var realnameTextField: UITextField!
	@IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		passwordTextField.secureTextEntry = true
		confirmPasswordTextField.secureTextEntry = true
		realnameTextField.placeholder = "真实姓名不能为空"
		realnameTextField.text = "中文"
		messageLabel.text = ""
    }

	@IBAction func registerAction(sender: UIButton) {
		logoutFromServer()
		let username = usernameTextField.text
		let password = passwordTextField.text
		let confirmPassword = confirmPasswordTextField.text
		let realname = realnameTextField.text
		if (username != nil) && (password != nil) && ( confirmPassword != nil ) && (realname != nil)
		{
			if password == confirmPassword {
				registerToServer(username, password: password,realname: realname)
			}else{
				messageLabel.text = "信息填写有误，请重新填写"
				passwordTextField.text = ""
				confirmPasswordTextField.text = ""
			}
		}
	}
	
	func registerToServer(username:String,password:String,realname:String)
	{
//		SCRequest.registerByPassword(username, password: password,realname:realname)
//			{ (_, _, JSON, _) -> Void in
//				let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//				hud.mode = MBProgressHUDMode.Text
//				
//				if let message = JSON?.valueForKey("message") as? String{
//					NSLog(message)
//					hud.labelText = message
//				}
//				
//				if JSON?.valueForKey("result") as? Bool == true {
//					hud.labelText = "注册成功"
//					//save userinfo
//					if let userlist = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.User) as? [User] {
//						 let user = userlist[0]
////						NSUserDefaults.standardUserDefaults().setValue(user, forKey: "user")
//						
//					}
//
//				}else {
//					hud.labelText = "注册失败!"
//				}
//				hud.showAnimated(true, whileExecutingBlock: { () -> Void in
//					sleep(1)
//					}) { () -> Void in
//						if let result = JSON?.valueForKey("result") as? Int
//						{
//							NSLog("result is: \(result)")
//							NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
//							NSUserDefaults.standardUserDefaults().setValue(password, forKey: "password")
//							NSUserDefaults.standardUserDefaults().setValue(realname, forKey: "realname")
//							//loginToServer
//							self.loginToServer(username, password: password)
//							//jumpToHomePageView
//							self.jumpToMainHome()
//						}
//				}
//		}
	}

	func jumpToMainHome()
	{
		
		if let myStoryBoard = self.storyboard{
			if let mainHomeView :ContainerViewController = myStoryBoard.instantiateViewControllerWithIdentifier("ContainerViewController") as? ContainerViewController{
				self.presentViewController(mainHomeView, animated: true, completion: nil)
			}
			
		}
		
	}
	func loginToServer(username:String,password:String)
	{
//		SCRequest.loginByPassword(username, password: password)
//			{ (_, _, JSON, _) -> Void in
//				
//		}
	}

	func logoutFromServer(){
//		SCRequest.logout { (_, _, JSON, _) -> Void in
//			if JSON?.valueForKey("result") as? Bool == false {
//				self.messageLabel.text = "登出失败"
//			}
//		}
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
