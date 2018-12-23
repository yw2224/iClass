//
//  AvailableTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/7.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON


var cnt: Int = 0
class AvailableTableViewController: CloudAnimateTableViewController {
    
    var courseID: String!
    var groupID: String!
    
    
    var waitingMembers = [GroupMember]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var submitList = [GroupMember]()
    var submitIndex = [Int]()
    var dict = Dictionary<Int, GroupMember>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var newRequest: UIButton! = UIButton()
        self.navigationItem.title = "可选名单"
        self.createBarItem(newRequest)
        
        retrieveAvailableList()
        
    }
    
    @IBAction func newRequestButtonTapped(sender: UIButton?) {
        //getSubmitList()
        
        //performSegueWithIdentifier("ShowNewRequestSegue", sender: sender)
        for (_, object) in dict {
            submitList.append(object)
        }
        
        ContentManager.sharedInstance.saveWish(self.courseID, target: self.submitList) {
            (error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            SVProgressHUD.showInfoWithStatus("提交成功！")
            self.animationDidEnd()
        }
        self.navigationController?.popViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    private func createBarItem(newPost: UIButton) {
        newPost.setTitle("提交", forState: .Normal)
        newPost.sizeToFit()
        newPost.addTarget(self, action: "newRequestButtonTapped:", forControlEvents: .TouchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: newPost)
        navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
    }
    
    
    override var emptyTitle: String {
        get {
            return "没有仍未组队的同学！"
        }
    }
    
    func retrieveAvailableList() {
        cnt = 0
        self.waitingMembers.removeAll()
        ContentManager.sharedInstance.getNoGroup(self.courseID) {
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
            print("plz!")
            print(json)
            let jsonArray: [JSON] = json["members"].arrayValue
            for arrayElement in jsonArray {
                var temp = GroupMember()
                temp.memberID = arrayElement["member_id"].string ?? ""
                temp.memberName = arrayElement["member_name"].string ?? ""
                temp.Ischoosed = false
                self.waitingMembers.append(temp)
                //self.members.last?.memberID = json["member_id"].string ?? ""
            }
            /*for element in self.waitingMembers {
             print("aaa" + element.memberName)
             }*/
            
            self.animationDidEnd()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func animationDidStart() {
        super.animationDidStart()
        retrieveAvailableList()
        // Remember to call 'animationDidEnd' in the following code
        //retrieveExList(i)
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
    
}

extension AvailableTableViewController {
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Show No Group Cell", forIndexPath: indexPath) as! ShowNoGroupTableViewCell
        cell.switchButton.onTintColor = UIColor(red: 156.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        cell.setupInfo(waitingMembers[indexPath.row].memberName)
        cell.memberName = waitingMembers[indexPath.row].memberName
        cell.memberID = waitingMembers[indexPath.row].memberID
        cell.Ischoosed = waitingMembers[indexPath.row].Ischoosed
        if cell.Ischoosed{
            cell.switchButton.on = true
        }else{
            cell.switchButton.on = false
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ShowNoGroupTableViewCell
        if cnt < 4 && cell.switchButton.on == false {
            
            //cell.backgroundColor = UIColor.lightGrayColor()
            cell.switchButton.on = true
            cnt = cnt + 1
            cell.Ischoosed = true
            waitingMembers[indexPath.row].Ischoosed = true
            let tmp = GroupMember()
            tmp.memberID = cell.memberID
            tmp.memberName = cell.memberName
            submitList.append(tmp)
            let tmpIndex = indexPath.row
            dict[tmpIndex] = tmp
            
        }/*
             else if cnt >= 4 {
             for element in submitList {
             print(element.memberID + " " + element.memberName)
             }
             }*/
        else if cell.switchButton.on == true
        {
            cell.switchButton.on = false
            //cell.backgroundColor = UIColor.whiteColor()
            cnt = cnt - 1
            if cnt <= 0{
                cnt = 0}
            cell.Ischoosed = false
            waitingMembers[indexPath.row].Ischoosed = false
            let tmpIndex = indexPath.row
            dict.removeValueForKey(tmpIndex)
        }
        else{
            cell.switchButton.on = false
        }

    }
}

class ShowNoGroupTableViewCell: UITableViewCell
{
    var memberID: String!
    var memberName: String!
    var Ischoosed: Bool = false
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var memberNameLabel: UILabel!
    
    func setupInfo(name: String) {
        memberNameLabel.text = name
    }
}
