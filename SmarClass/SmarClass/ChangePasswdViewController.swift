//
//  ChangePasswdViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/21.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

//import MBProgressHUD
@IBDesignable
class ChangePasswdViewController: UIViewController {

	@IBOutlet weak var oldPasswordTextField: UITextField!
   
	@IBOutlet weak var newPasswordTextField: UITextField!
	@IBOutlet weak var rePasswordTextField: UITextField!
	@IBOutlet weak var doneBtn: UIBarButtonItem!
	private struct InnerConstants{
		static let unwindSegueIdentifier = "unwindToPersonalInfoPageSegue"
	}
	override func viewDidLoad() {
		doneBtn.enabled = true
		doneBtn.tintColor = UIColor.greenColor()
		doneBtn.target = self
		doneBtn.action = "handleChangePassword:"
		self.oldPasswordTextField.secureTextEntry = true
		self.newPasswordTextField.secureTextEntry = true
		self.rePasswordTextField.secureTextEntry = true
	}
	func handleChangePassword(sender:UIBarButtonItem){
		if let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
			let password = self.newPasswordTextField.text
			let repassword = self.rePasswordTextField.text
//			if password == repassword {
//				SCRequest.changePassword(username, password: password)
//					{ (_, _, JSON, _) -> Void in
//					println(JSON)
//						self.showAlertView()
//				}
//			}else{
//				return
//			}
		}
	}
	
	
	func showAlertView(){
//		let alert = MBProgressHUD()
//		alert.mode = MBProgressHUDMode.Text
//		alert.labelText = "密码修改成功"
//		alert.showAnimated(true,
//			whileExecutingBlock: { () -> Void in
//				NSThread.sleepForTimeInterval(0.5)
//		}) { () -> Void in
//			self.performSegueWithIdentifier(InnerConstants.unwindSegueIdentifier, sender: self)
//		}
//		let alert = UIAlertController(title: "", message: "密码修改成功，点击确认返货", preferredStyle: UIAlertControllerStyle.Alert)
//		alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
//			//do nothing
//		}))
//		alert.addAction(UIAlertAction(
//			title: "确认",
//			style: <#UIAlertActionStyle#>,
//			handler: <#((UIAlertAction!) -> Void)!##(UIAlertAction!) -> Void#>))
	}
}
