//
//  GroupMemberTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/6.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class GroupMember: NSObject {
    var memberID: String = ""
    var memberName: String = ""
    var Ischoosed: Bool = false
}

class GroupMemberTableViewController: CloudAnimateTableViewController {

    var groupID: String!
    var courseID: String!
    var groupName: String = ""
    //var temp: GroupMember = GroupMember()
    
    var leader: GroupMember = GroupMember(){
        didSet {
            tableView.reloadData()
        }
    }
    
    var members: [GroupMember] = [GroupMember]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func createBarItem(newPost: UIButton) {
        newPost.setBackgroundImage(UIImage(named: "PlusOrMinus"), forState: .Normal)
        newPost.sizeToFit()
        newPost.addTarget(self, action: "newRequestButtonTapped:", forControlEvents: .TouchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: newPost)
        navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
    }
    
    @IBAction func newRequestButtonTapped(sender: UIButton?) {
        
        performSegueWithIdentifier("ShowNewRequestSegue", sender: sender)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var newRequest: UIButton! = UIButton()
        self.navigationItem.title = "我的小组"
        
        self.createBarItem(newRequest)
        
        retrieveGroupDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveGroupDetail() {
        self.members.removeAll()
        ContentManager.sharedInstance.showGroup(ContentManager.UserID, token: ContentManager.Token, groupID: self.groupID) {
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
            
            self.leader = GroupMember()
            self.leader.memberID = json["leader_id"].string ?? ""
            self.leader.memberName = json["leader_name"].string ?? ""
            //self.leader = temp
            
            self.groupName = json["group_name"].string ?? ""
            
            
            let jsonArray: [JSON] = json["member"].arrayValue
            for arrayElement in jsonArray {
                var temp = GroupMember()
                temp.memberID = arrayElement["member_id"].string ?? ""
                temp.memberName = arrayElement["member_name"].string ?? ""
                self.members.append(temp)
                //self.members.last?.memberID = json["member_id"].string ?? ""
                
            }
            //print("therethere" + self.leader.memberID + " " + self.leader.memberName)
            self.animationDidEnd()
        }
    }

    override func animationDidStart() {
        super.animationDidStart()
        retrieveGroupDetail()
        // Remember to call 'animationDidEnd' in the following code
        //retrieveExList(i)
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

extension GroupMemberTableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNewRequestSegue" {
            if let dest = segue.destinationViewController as? ShowRequestTableViewController
            {
                print("courseID" + courseID)
                print("groupID" + groupID)
                dest.courseID = courseID
                dest.groupID = groupID
            }
        }
        
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return members.count
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section
        {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("Show Group Cell", forIndexPath: indexPath) as! ShowGroupTableViewCell
            cell.setupInfo("组名", content: groupName)
           
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("Show Group Cell", forIndexPath: indexPath) as! ShowGroupTableViewCell
            cell.setupInfo("组长", content: leader.memberName)
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Show Group Cell", forIndexPath: indexPath) as! ShowGroupTableViewCell
            cell.setupInfo("组员", content: members[indexPath.row].memberName)
            
            return cell

        }
        
    }
}

class ShowGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var showInfoLabel: UILabel!
    
    func setupInfo(type: String, content: String) {
        showInfoLabel.text = type + ": " + content
    }
}

