//
//  LoginViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SVProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController {
    
    let loginModel = Login()
    var keyboardAppeared = false {
        didSet {
            guard (oldValue != keyboardAppeared) else { return }
            var offset = loginTableView.contentOffset
            offset.y = keyboardAppeared ? Constants.HeaderHeight : 0
            loginTableView.setContentOffset(offset, animated: true)
        }
    }
    var status = LoginStatus.Login {
        didSet {
            loginTableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: oldValue ? .Left : .Right)
            setupButton()
        }
    }
    var isRuntimeInit = false
    var shouldAutoLogin = false
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var loginTableView: UITableView!
    @IBOutlet weak var blankViewHeight: NSLayoutConstraint!
    
    private struct Constants {
        static let CourseListSegueIdentifier     = "Course List Segue"
        static let HeaderHeight: CGFloat         = 100.0
        static let FooterHeight: CGFloat         = 72.0
        static let LoginTableViewHeight: CGFloat = 304
        static let LoginButtonHeight: CGFloat    = 34.0
        static let StatusBarHeight: CGFloat      = 20.0
        static let SpaceRatio: CGFloat           = 2.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let panGesture = UIPanGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollUpTableView", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollDownTableView", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: Auto login
        if shouldAutoLogin {
            shouldAutoLogin = false // Only auto login for at most one time
            loginAction(loginButton)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        let height = CGRectGetHeight(view.frame)
        let blankHeight = (height - Constants.LoginTableViewHeight - Constants.LoginButtonHeight - Constants.StatusBarHeight) / (1 + Constants.SpaceRatio)
        blankViewHeight.constant = max(blankHeight, 8)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        loginTableView.reloadData()
    }
    
    func setupButton() {
        loginButton?.setTitle("\(status)", forState: .Normal)
        toggleButton?.setTitle("课堂助手账号\(!status)", forState: .Normal)
    }
    
    func scrollUpTableView() {
        keyboardAppeared = true
    }
    
    func scrollDownTableView() {
        keyboardAppeared = false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
	@IBAction func loginAction(sender: UIButton!) {
        func shakeCell(indexPath: NSIndexPath) {
            let cell = loginTableView.cellForRowAtIndexPath(indexPath) as! TextCell
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.duration = 0.6
            animation.values = [(-20), (20), (-20), (20), (-10), (10), (-5), (5), (0)]
            cell.textField.layer.addAnimation(animation, forKey: "shake")
        }
        
        do {
            let tuple =  try loginModel.validate(status, tableView: loginTableView)
            
            dismissKeyboard()
            disableLoginButton()
            let block: (NetworkErrorType?) -> Void = {
                (error) in
                
                self.enableLoginButton()
                self.errorHandler(error, serverErrorPrompt: GlobalConstants.ServerErrorPrompt, forbiddenAccessPrompt: self.status ? GlobalConstants.PasswordWrongPrompt : GlobalConstants.DuplicateUserName)
                
                if error == nil {
                    if self.isRuntimeInit {
                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.performSegueWithIdentifier(Constants.CourseListSegueIdentifier, sender: sender)
                    }
                }
            }
            
            if status {
                ContentManager.sharedInstance.login(tuple.0, password: tuple.1, block: block)
            } else {
                ContentManager.sharedInstance.register(tuple.0, realName: tuple.1, password: tuple.2, block: block)
            }
            
        } catch LoginErrorType.FieldEmpty(let indexPath) {
            SVProgressHUD.showErrorWithStatus("此项不能为空")
            shakeCell(indexPath)
        } catch LoginErrorType.FieldInvalid(let indexPath) {
            SVProgressHUD.showErrorWithStatus("格式有误，请重新输入")
            shakeCell(indexPath)
        } catch (let error) {
            DDLogError("Unknown error: \(error)")
        }
	}
    
    @IBAction func toggleTableView(sender: UIButton) {
        status = !status
    }
    
    func enableLoginButton() {
        loginIndicator.stopAnimating()
        loginButton.enabled = true
        loginButton.setTitle("\(status)", forState: .Normal)
    }
    
    func disableLoginButton() {
        loginIndicator.startAnimating()
        loginButton.enabled = false
        loginButton.setTitle("", forState: .Normal)
    }
}

extension LoginViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loginModel[status]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tuple = loginModel[status, indexPath]!
        let cell = tableView.dequeueReusableCellWithIdentifier(tuple.cellID)!
        
        if let cell = cell as? TextCellSetup {
            cell.setupWithPlaceholder(tuple.placeholder, content: tuple.content, isSecure: tuple.isSecure, AndKeyboardType: tuple.keyboardType)
        }
        return cell
    }
}