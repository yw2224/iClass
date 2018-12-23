//
//  ShowRequestTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/6.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class ShowRequestTableViewController: CloudAnimateTableViewController {
    
    var courseID: String!
    var groupID: String!
    
    var waitingMembers: [GroupMember] = [GroupMember]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "请求加入的名单"
        retrieveRequestList()
        
    }
    
    override var emptyTitle: String {
        get {
            return "没有请求！"
        }
    }
    
    func retrieveRequestList() {
        self.waitingMembers.removeAll()
        ContentManager.sharedInstance.showRequest(self.courseID) {
            (json, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            print(json)
            let jsonArray: [JSON] = json["waiting_member"].arrayValue
            for arrayElement in jsonArray {
                var temp = GroupMember()
                temp.memberID = arrayElement["member_id"].string ?? ""
                temp.memberName = arrayElement["member_name"].string ?? ""
                self.waitingMembers.append(temp)
                //self.members.last?.memberID = json["member_id"].string ?? ""
                
            }
            self.animationDidEnd()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func animationDidStart() {
        super.animationDidStart()
        retrieveRequestList()
        // Remember to call 'animationDidEnd' in the following code
        //retrieveExList(i)
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }

    
}

extension ShowRequestTableViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return waitingMembers.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Show Request Cell", forIndexPath: indexPath) as! ShowRequestTableViewCell
        cell.setupInfo(waitingMembers[indexPath.row].memberName)
        cell.groupID = self.groupID
        cell.courseID = self.courseID
        cell.memberID = waitingMembers[indexPath.row].memberID
        cell.memberName = waitingMembers[indexPath.row].memberName
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let member = waitingMembers[indexPath.row]
        
        let alertController = UIAlertController(title: "同意该申请？", message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "同意", style: .Destructive) {
            (alertAction) in
            self.sendMessage("confirm", memberID: member.memberID, memberName: member.memberName)
            self.navigationController?.popViewControllerAnimated(true)
            SVProgressHUD.showInfoWithStatus("已接受！")
            
            })
        alertController.addAction(UIAlertAction(title: "拒绝", style: .Cancel){
            (alertAction) in
            self.sendMessage("reject", memberID: member.memberID, memberName: member.memberName)
            self.navigationController?.popViewControllerAnimated(true)
            SVProgressHUD.showInfoWithStatus("已拒绝！")
            })
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func sendMessage(type: String, memberID: String, memberName: String)
    {
        ContentManager.sharedInstance.dealGroup(groupID, courseID: courseID, type: type, memberID: memberID, memberName: memberName){
            (error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    //self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            
        }
        
    }
}

class ShowRequestTableViewCell: UITableViewCell
{
    @IBOutlet weak var memberNameLabel: UILabel!

    var groupID: String!
    var memberID: String!
    var courseID: String!
    var memberName: String!
    func setupInfo(name: String) {
        memberNameLabel.text = name
    }
}

