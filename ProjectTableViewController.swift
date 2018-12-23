//
//  ProjectTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/5.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class Groups {
    var courseID: String = ""
    var leaderID: String = ""
    var leaderName: String = ""
    var groupName: String = ""
    var groupID: String = "" //??
    //var member: [GroupMember] = [GroupMember]()
}
/*
class GroupMember {
    var memberID: String = ""
    var memberName: String = ""
}*/


class ProjectTableViewController: CloudAnimateTableViewController {

    
    var courseID : String!
    var ProjectList = [Groups]() {
        didSet {
            tableView.reloadData()
        }
    }
    var joinedaGroup : String = ""
    var groupID : String!
    
    override var emptyTitle: String {
        get {
            return "没有课程内容，请下拉以刷新。"
        }
    }
    
    private func createBarItem(add: UIButton, mine: UIButton, auto: UIButton) {
        add.setBackgroundImage(UIImage(named: "add"), forState: .Normal)
        add.sizeToFit()
        add.addTarget(self, action: "addButtonTapped:", forControlEvents: .TouchUpInside)
        
        mine.setImage(UIImage(named: "usermy"), forState: .Normal)
        mine.sizeToFit()
        mine.addTarget(self, action: "mineButtonTapped:", forControlEvents: .TouchUpInside)
        
        auto.setImage(UIImage(named: "spechbubble"), forState: .Normal)
        auto.sizeToFit()
        auto.addTarget(self, action: "autoButtonTapped:", forControlEvents: .TouchUpInside)
        
        let barAdd = UIBarButtonItem(customView: add)
        let barMine = UIBarButtonItem(customView: mine)
        let barAuto = UIBarButtonItem(customView: auto)
        
        let gap = UIBarButtonItem(barButtonSystemItem: .FixedSpace,target: nil, action: nil)
        gap.width = 15;
        self.navigationItem.rightBarButtonItems = [barAdd, gap, barMine, gap, barAuto]
        //let barButtonItem = UIBarButtonItem(customView: add + gap + mine)
        //navigationItem.setRightBarButtonItem(UIBarButtonItem(add, gap, mine), animated: true)
    }
    
    @IBAction func mineButtonTapped(sender: UIButton?) {
        if joinedaGroup != "in group" {
            SVProgressHUD.showErrorWithStatus("您尚未加入小组！")
        }
        else if joinedaGroup == "in group" {
            performSegueWithIdentifier("ShowGroupMemberSegue", sender: self)
        }
    }
    
    @IBAction func addButtonTapped(sender: UIButton?) {
        if joinedaGroup == "in group"
        {
            SVProgressHUD.showErrorWithStatus("您已加入小组！")
        }
        else if joinedaGroup == "none" {
            createGroup()
            //joinedaGroup = "in group"
            //performSegueWithIdentifier("ShowCreateGroupSegue", sender: self)
        }
        else if joinedaGroup == "applying group"
        {
            SVProgressHUD.showInfoWithStatus("您已发送申请！")
        }
        //??retrieve??
    }
    
    @IBAction func autoButtonTapped(sender: UIButton?) {
        if joinedaGroup == "in group"
        {
            SVProgressHUD.showErrorWithStatus("您已加入小组！")
        }
        else if joinedaGroup == "none" {
            performSegueWithIdentifier("ShowAvailableSegue", sender: self)
        }
        else if joinedaGroup == "applying group"
        {
            SVProgressHUD.showInfoWithStatus("您已发送申请！")
        }

    }

    
    func createGroup() {
        var groupName: String! = ""
        let alertController = UIAlertController(title: "创建小组:", message: "", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "组名"
        }
        alertController.addAction(UIAlertAction(title: "确认", style: .Destructive) {
            (alertAction) in
            //CoreDataManager.sharedInstance.saveInForeground()
                groupName = alertController.textFields!.first?.text
                print("groupName:" + groupName)
                self.submitGroup(groupName)
                self.joinedaGroup = "in group"
            })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
        
    func submitGroup(groupName: String) {
        ContentManager.sharedInstance.createGroup(ContentManager.UserID, token: ContentManager.Token, courseID: self.courseID, leaderName: ContentManager.UserName, groupName: groupName) {
            (newGroup, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
        SVProgressHUD.showInfoWithStatus("创建小组成功！")
        retrieveProjectList()
        groupQuery()
    }
    
    func joinGroup(groupID: String) {
        print("joinedaGroup:" + joinedaGroup)
        if self.joinedaGroup == "none"
        {
            let alertController = UIAlertController(title: "申请加入该组？", message: "", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "确认", style: .Destructive) {
                (alertAction) in
                //CoreDataManager.sharedInstance.saveInForeground()
                //self.navigationController?.popViewControllerAnimated(true)
                    self.groupApply(groupID)
                    SVProgressHUD.showInfoWithStatus("申请已发送！")
                    self.joinedaGroup = "applying group"
                    //self.groupQuery()
                })
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if self.joinedaGroup == "applying group"
        {
            SVProgressHUD.showInfoWithStatus("您已发送申请！")
        }
        else if self.joinedaGroup == "in group"
        {
            SVProgressHUD.showErrorWithStatus("您已加入小组！")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "小组"
        var add: UIButton! = UIButton()
        var mine: UIButton! = UIButton()
        var auto: UIButton! = UIButton()
        self.createBarItem(add, mine: mine, auto: auto)
        groupQuery()
        retrieveProjectList()
        //joinedaGroup = CoreDataManager.sharedInstance.course(self.courseID).joinedaGroup as? Bool
        //print(joinedaGroup)
        
        
        print("joinedaGroup:" + joinedaGroup)
        
    }
    
    func groupApply(groupID: String) {
        ContentManager.sharedInstance.applyGroup(groupID) {
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
        }
    }
    
    func groupQuery() {
        ContentManager.sharedInstance.groupQuery(self.courseID) {
            (myStatus, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                    
                        return
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            print(myStatus)
            self.joinedaGroup = myStatus["status"].string ?? ""
            self.groupID = myStatus["group_id"].string ?? ""
        }
        //SVProgressHUD.showInfoWithStatus("创建小组成功！")
        print("joinedaGroup:" + self.joinedaGroup)
        //retrieveProjectList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //CoreDataManager.sharedInstance.saveInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func block(_: NetworkErrorType?) -> Void {
    }
    
    func retrieveProjectList() {
        ProjectList.removeAll()
        ContentManager.sharedInstance.projectList(courseID) {
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
            let jsonArray: [JSON] = json["groups"].arrayValue
            for arrayElement in jsonArray {
                var temp = Groups()
                temp.courseID = arrayElement["course_id"].string ?? ""
                temp.leaderID = arrayElement["leader_id"].string ?? ""
                temp.leaderName = arrayElement["leader_name"].string ?? ""
                temp.groupName = arrayElement["group_name"].string ?? ""
                temp.groupID = arrayElement["_id"].string ?? ""
               /* print("self.temp")
                print(self.temp.courseID + " " + self.temp.leaderID + " " + self.temp.leaderName + " " + self.temp.groupName)*/
                self.ProjectList.append(temp)
            }
            
            //self.tableView.cel
            self.animationDidEnd()
            
        }

        //print("project:")
        print(ProjectList.count)
    }
}

extension ProjectTableViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveProjectList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

// MARK: UITableViewDataSource
extension ProjectTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProjectList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Project List Cell") as! ProjectListTableViewCell
        let project = ProjectList[indexPath.row]
        print("forcell:")
        for group in ProjectList {
            print(group.groupName)
        }
        cell.setupWithInfo(project.courseID, leaderID: project.leaderID, leaderName: project.leaderName, groupName: project.groupName)
        return cell
    }
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let groupID = ProjectList[indexPath.row].groupID
        joinGroup(groupID)
       /* let lessonID = lessonList[indexPath.row].lessonID!.stringValue
        let lessonName = lessonList[indexPath.row].lessonName
        
        performSegueWithIdentifier("Show Lesson File Segue", sender: self)*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCreateGroupSegue" {
            if let dest = segue.destinationViewController as? CreateGroupViewController
            {
                dest.courseID = courseID
            }
        }
        if segue.identifier == "ShowGroupMemberSegue" {
            if let dest = segue.destinationViewController as? GroupMemberTableViewController
            {
                dest.courseID = courseID
                dest.groupID = groupID
            }
        }
        if segue.identifier == "ShowAvailableSegue" {
            if let dest = segue.destinationViewController as? AvailableTableViewController
            {
                dest.courseID = courseID
            }
        }

    }
}

// MARK: UITableViewDelegate
extension ProjectTableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}

class ProjectListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var leaderIDLabel: UILabel!
    @IBOutlet weak var leaderNameLabel: UILabel!
   
    func setupWithInfo(id: String, leaderID: String, leaderName: String, groupName: String) {
        nameLabel.text = "小组：" + groupName
        //leaderIDLabel.text = leaderID
        leaderNameLabel.text = "组长：" + leaderName
    }
}

