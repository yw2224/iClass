//
//  LoginViewController.swift
//  SmartClass
//
//  Created by  ChenYang on 15/5/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

	@IBOutlet weak var usernameTextField: UITextField!
	
	
	@IBOutlet weak var passwordTextField: UITextField!
	
	@IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		usernameTextField.text = "1100012936"
		passwordTextField.text = "7654321"
		passwordTextField.secureTextEntry = true
		
    }
	private struct InnerConstants {
		static let LoginToHomePageSegueIdentifier = "LoginToHomePageSegue"
	}

	@IBAction func loginAction(sender: UIButton) {
//        jumpToMainHome()
//		let username = usernameTextField.text
//		let password = passwordTextField.text
//		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//		hud.mode = MBProgressHUDMode.Text
//		if (username != nil) && (password != nil){
//			SCRequest.loginByPassword(username, password: password)
//				{ (_, _, JSON, _) -> Void in
//					if JSON?.valueForKey("result") as? Bool == true {
//						hud.labelText = "登录成功"
//						
//					}else {
//						hud.labelText = "用户名或密码错误!"
//					}
//
//				
//				hud.showAnimated(true,
//					whileExecutingBlock:
//					{ () -> Void in
//						NSThread.sleepForTimeInterval(1)
//					})
//					{ () -> Void in
//					//segue to home page
//						
//							if JSON?.valueForKey("result") as? Bool == true {
//								if let userlist = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.User) as? [User] {
//									if userlist.count > 0 {
//										 let user = userlist[0]
//										println(user)
//	//									NSUserDefaults.standardUserDefaults().setValue(user, forKey: "user")
//											NSUserDefaults.standardUserDefaults().setValue(user.firstname, forKey: "realname")
//											
//									}
//									
//								}
//								println(JSON)
//								NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
//								NSUserDefaults.standardUserDefaults().setValue(password, forKey: "password")
//								//jumpToHomePageView
//								self.jumpToMainHome()
////								self.performSegueWithIdentifier(InnerConstants.LoginToHomePageSegueIdentifier, sender: self)
//							}
//						}
//
//						
//					}
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
