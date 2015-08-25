//
//  LoginViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

enum LoginStatus {
    case Register
    case Login
}

class LoginViewController: UIViewController {
    
    var animationLeft = true
    var keyboardAppeared = false {
        didSet {
            if oldValue != keyboardAppeared && loginTableView != nil {
                var offset = loginTableView.contentOffset
                if keyboardAppeared {
                    offset.y = Constants.HeaderHeight
                } else {
                    offset.y = 0
                }
                loginTableView.setContentOffset(offset, animated: true)
            }
        }
    }
    var status: LoginStatus! {
        didSet {
            if loginTableView != nil && SNSCollectionView != nil {
                loginTableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: animationLeft ? .Left: .Right)
                SNSCollectionView.reloadSections(NSIndexSet(index: 0))
                setupButton()
                animationLeft = !animationLeft
            }
        }
    }
    
    let rowIdentifiers = [
        LoginStatus.Register: ["学号", "姓名", "密码"],
        LoginStatus.Login: ["Empty", "学号", "密码"]
    ]
    let cellIndexes = [
        LoginStatus.Register: [
            "name": NSIndexPath(forRow: 0, inSection: 0),
            "realName": NSIndexPath(forRow: 1, inSection: 0),
            "password": NSIndexPath(forRow: 2, inSection: 0)
        ],
        LoginStatus.Login: [
            "name": NSIndexPath(index: 1),
            "password": NSIndexPath(forRow: 2, inSection: 0)
        ]
    ]
    let SNSCollectionIdentifiers = [("QQ", "QQ"), ("Wechat", "微信"), ("Weibo", "微博")]
    
    private struct Constants {
//        static let LoginToHomePageSegueIdentifier = "LoginToHomePageSegue"
        static let HeaderHeight: CGFloat = 100.0
        static let FooterHeight: CGFloat = 72.0
        static let MarginForRegisterRatio: CGFloat = 0.3
        static let MarginForLoginrRatio: CGFloat = 0.24
        static let CollectionViewCellIdentifier = "SNS Cell"
        static let CollectionViewHeaderIdentifier = "SNS Header"
        static let CollectionCellWidth: CGFloat = 50.0
        static let CollectionCellHeight: CGFloat = 80.0
    }
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var loginTableView: UITableView!
    @IBOutlet weak var SNSCollectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollUpTableView", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollDownTableView", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupButton() {
        loginButton?.setTitle(status == LoginStatus.Register ? "注册" : "登陆", forState: .Normal)
        toggleButton?.setTitle(status == LoginStatus.Register ? "课堂助手账号注册" : "课堂助手账号登陆", forState: .Normal)
    }
    
    func scrollUpTableView() {
        keyboardAppeared = true
    }
    
    func scrollDownTableView() {
        keyboardAppeared = false
    }
    
    func checkInput() -> (Bool, String, String, String) {
        if status == LoginStatus.Register {
            
        } else {
            
        }
        return (false, "", "", "")
    }
    
	@IBAction func loginAction(sender: UIButton) {
        
        loginIndicator.startAnimating()
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
    
    @IBAction func toggleTableView(sender: UIButton) {
        if status == LoginStatus.Register {
            status = LoginStatus.Login
        } else {
            status = LoginStatus.Register
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

// MARK: tableview datasource & delegate
extension LoginViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowIdentifiers[rowIdentifiers.startIndex].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellId = "", text = ""
        (cellId, text) = {
            if let content = self.rowIdentifiers[self.status]?[indexPath.row] {
                return (content == "Empty" ? content : "Text", content)
            }
            return ("Empty", "")
        }()
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
        if cellId != "Empty" {
            (cell as! LoginTableViewCell).configureCellWithPlaceHolder(text)
        }
        return cell
    }
}

extension LoginViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: collection datasource & delegate
extension LoginViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SNSCollectionIdentifiers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CollectionViewCellIdentifier, forIndexPath: indexPath) as! SNSCollectionViewCell
        cell.configureCellWithImage(
            SNSCollectionIdentifiers[indexPath.row].0,
            name: SNSCollectionIdentifiers[indexPath.row].1)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.CollectionViewHeaderIdentifier, forIndexPath: indexPath) as! SNSCollectionViewHeader
        header.configureHeader(status == LoginStatus.Register ? "社交网络注册" : "社交网络登陆")
        return header
    }
}

extension LoginViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsetsZero
        if status == LoginStatus.Register {
            inset.left = CGRectGetWidth(collectionView.frame) * Constants.MarginForRegisterRatio
            inset.right = inset.left
        } else {
            inset.left = CGRectGetWidth(collectionView.frame) * Constants.MarginForLoginrRatio
            inset.right = inset.left
        }
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        var interSpacing: CGFloat = 0
        if status == LoginStatus.Register {
            interSpacing = CGRectGetWidth(collectionView.frame) * (1 - 2 * Constants.MarginForRegisterRatio)
            interSpacing -= 2 * Constants.CollectionCellWidth
        } else {
            interSpacing = CGRectGetWidth(collectionView.frame) * (1 - 2 * Constants.MarginForLoginrRatio)
            interSpacing -= 3 * Constants.CollectionCellWidth
            interSpacing /= 2
        }
        return max(interSpacing, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath)
    }
}

class LoginTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    func configureCellWithPlaceHolder(text: String) {
        textField.text = ""
        textField.placeholder = text
        textField.keyboardType = .Default
        textField.returnKeyType = .Done
        textField.secureTextEntry = false
        textField.clearsOnBeginEditing = false
        textField.clearButtonMode = .Never
        if text == "学号" {
            textField.keyboardType = .NumberPad
        } else if text == "密码" {
            textField.secureTextEntry = true
            textField.clearsOnBeginEditing = true
            textField.clearButtonMode = .WhileEditing
        }
        textField.delegate = self
    }
    
    
    func textFieldContent() -> String {
        return textField.text
    }
}

extension LoginTableViewCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


class SNSCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var SNSButton: UIButton!
    @IBOutlet weak var SNSName: UILabel!
    func configureCellWithImage(imageName: String, name: String) {
        SNSButton.backgroundColor = UIColor.whiteColor()
        if let image = UIImage(named: imageName) {
            SNSButton.setImage(image, forState: .Normal)
        }
        SNSName.text = name
    }
}

class SNSCollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    func configureHeader(text: String) {
        label.text = text
    }
}