//
//  LoginViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import SwiftyJSON

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
            "name": NSIndexPath(forRow: 1, inSection: 0),
            "password": NSIndexPath(forRow: 2, inSection: 0)
        ]
    ]
    let SNSCollectionIdentifiers = [("QQ", "QQ"), ("Wechat", "微信"), ("Weibo", "微博")]
    
    private struct Constants {
        static let LoginToMainHomeSegueIdentifier = "Login To MainHome Segue"
        static let HeaderHeight: CGFloat = 100.0
        static let FooterHeight: CGFloat = 72.0
        static let RegisterCollectionViewMarginRatio: CGFloat = 0.3
        static let LoginCollectionViewMarginRatio: CGFloat = 0.24
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollUpTableView", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollDownTableView", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupButton() {
        loginButton?.setTitle(status == LoginStatus.Register ? "注册" : "登录", forState: .Normal)
        toggleButton?.setTitle(status == LoginStatus.Register ? "课堂助手账号登录" : "课堂助手账号注册", forState: .Normal)
    }
    
    func scrollUpTableView() {
        keyboardAppeared = true
    }
    
    func scrollDownTableView() {
        keyboardAppeared = false
    }
    
    func checkInput() -> (Bool, String, String, String) {
        let indexes = cellIndexes[status]
        let someDigitsRegex = NSRegularExpression(pattern: "\\d+", options: .allZeros, error: nil)!
        func trimWhiteSpace(text: String) -> String {
            return text.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        }
        
        if status == LoginStatus.Register {
            let (name: String, realName: String, password: String) = {
                return (trimWhiteSpace((self.loginTableView.cellForRowAtIndexPath($0) as! LoginTableViewCell).textFieldContent()),
                        trimWhiteSpace((self.loginTableView.cellForRowAtIndexPath($1) as! LoginTableViewCell).textFieldContent()),
                        trimWhiteSpace((self.loginTableView.cellForRowAtIndexPath($2) as! LoginTableViewCell).textFieldContent()))
            } (indexes!["name"]!, indexes!["realName"]!, indexes!["password"]!)
            
            if count(name) == 0 || count(realName) == 0 || count(password) == 0 {
                return (false, name, realName, password)
            }
            let regexResult = someDigitsRegex.matchesInString(name, options: .allZeros, range: NSMakeRange(0, count(name)))
            if count(regexResult) != 1 {
                return (false, name, realName, password)
            }
            return (true, name, realName, password)
        } else {
            let (name: String, password: String) = {
                return (trimWhiteSpace((self.loginTableView.cellForRowAtIndexPath($0) as! LoginTableViewCell).textFieldContent()),
                    trimWhiteSpace((self.loginTableView.cellForRowAtIndexPath($1) as! LoginTableViewCell).textFieldContent()))
                } (indexes!["name"]!, indexes!["password"]!)
            
            if count(name) == 0 || count(password) == 0 {
                return (false, name, "", password)
            }
            let regexResult = someDigitsRegex.matchesInString(name, options: .allZeros, range: NSMakeRange(0, count(name)))
            if count(regexResult) != 1 {
                return (false, name, "", password)
            }
            return (true, name, "", password)
        }
    }
    
	@IBAction func loginAction(sender: UIButton) {
        let input = checkInput()
        var title = loginButton.currentTitle
        if !input.0 {
            //  Show a HUD or somewhat
            println("Showing HUD")
            return
        }
        
        // Nice tip: Resign first responder for its all subviews.
        // Stackoverflow: http://stackoverflow.com/questions/6906246/how-do-i-dismiss-the-ios-keyboard
        view.endEditing(false)
        
        disableLoginButton()
    
        if status == LoginStatus.Register {
            ContentManager.sharedInstance.register(input.1, realName: input.2, password: input.3) {
                [weak self] (success, message) in
                
                self?.enableLoginButton()

                if success {
                    self?.performSegueWithIdentifier(Constants.LoginToMainHomeSegueIdentifier, sender: Constants.LoginCollectionViewMarginRatio)
                } else {
                    println("Showing HUD failed or somewhat")
                    println(message)
                }
            }
        } else {
            ContentManager.sharedInstance.login("S1", password: "SS1") {
                [weak self] (success, message) in
                
                self?.enableLoginButton()

                if success {
                    self?.performSegueWithIdentifier(Constants.LoginToMainHomeSegueIdentifier, sender: sender)
                } else {
                    println("Showing HUD failed or somewhat")
                    println(message)
                }
            }
        }
	}
    
    @IBAction func toggleTableView(sender: UIButton) {
        if status == LoginStatus.Register {
            status = LoginStatus.Login
        } else {
            status = LoginStatus.Register
        }
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        SNSCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func enableLoginButton() {
        loginIndicator.stopAnimating()
        loginButton.enabled = true
        loginButton.setTitle(status == LoginStatus.Register ? "注册" : "登录", forState: .Normal)
    }
    
    func disableLoginButton() {
        loginIndicator.startAnimating()
        loginButton.enabled = false
        loginButton.setTitle("", forState: .Normal)
    }
}

// Protrait View Controller
//extension LoginViewController {
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
//    
//    override func supportedInterfaceOrientations() -> Int {
//        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
//    }
//}

// MARK: tableview datasource & delegate
extension LoginViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowIdentifiers[rowIdentifiers.startIndex].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var (cellId: String, text: String) = {
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
        header.configureHeader(status == LoginStatus.Register ? "社交网络注册" : "社交网络登录")
        return header
    }
}

extension LoginViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsetsZero
        if status == LoginStatus.Register {
            inset.left = CGRectGetWidth(collectionView.frame) * Constants.RegisterCollectionViewMarginRatio
            inset.right = inset.left
        } else {
            inset.left = CGRectGetWidth(collectionView.frame) * Constants.LoginCollectionViewMarginRatio
            inset.right = inset.left
        }
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        var interSpacing: CGFloat = 0
        if status == LoginStatus.Register {
            interSpacing = CGRectGetWidth(collectionView.frame) * (1 - 2 * Constants.RegisterCollectionViewMarginRatio)
            interSpacing -= 2 * Constants.CollectionCellWidth
        } else {
            interSpacing = CGRectGetWidth(collectionView.frame) * (1 - 2 * Constants.LoginCollectionViewMarginRatio)
            interSpacing -= 3 * Constants.CollectionCellWidth
            interSpacing /= 2
        }
        return max(interSpacing, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath)
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
            textField.keyboardType = .Default
//            textField.keyboardType = .NumberPad
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

class SNSCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var SNSImage: UIImageView!
    @IBOutlet weak var SNSName: UILabel!
    func configureCellWithImage(imageName: String, name: String) {
        SNSImage.backgroundColor = UIColor.whiteColor()
        if let image = UIImage(named: imageName) {
            SNSImage.image = image
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