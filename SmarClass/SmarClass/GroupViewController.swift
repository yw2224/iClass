//
//  GroupViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class GroupViewController: CloudAnimateTableViewController {

    var createdGroupList = [Group]()
    var invitedGroupList = [Group]()
    var groupID: String?
    
    override var emptyTitle: String {
        get {
            return "组队信息为空。\n请添加组队/下拉刷新重试！"
        }
    }

    private struct Constants {
        static let CellIdentifier = "Group Cell"
        static let GroupCellHeight : CGFloat = 210.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var courseID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.GroupCellHeight
        
        retrieveGroupList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func retrieveGroupList() {
        guard let projectID = CoreDataManager.sharedInstance.projectIDForCourse(courseID) else {
            ContentManager.sharedInstance.projectList(courseID) {
                (projectID, error) in
                
                if error == nil, let pID = projectID {
                    self.retrieveGroupListForProject(pID)
                } else {
                    // MARK: present HUD
                    self.animationDidEnd()
                }
            }
            return
        }
        
        retrieveGroupListForProject(projectID)
    }
    
    func retrieveGroupListForProject(projectID: String) {
        ContentManager.sharedInstance.groupList(projectID) {
            (groupID, creatorList, memberList, error) in
            if error == nil {
                // MARK: map process for groupID
                self.createdGroupList = creatorList
                self.invitedGroupList = memberList
                self.groupID = groupID
                self.tableView.reloadData()
            }
            
            self.animationDidEnd()
        }
    }
}

// MARK: RefreshControlHook
extension GroupViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveGroupList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
    
}

// UITableViewDataSource
extension GroupViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return createdGroupList.count
        } else if section == 1 {
            return invitedGroupList.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && createdGroupList.count > 0 {
            return "我创建的小组"
        } else if section == 1 && invitedGroupList.count > 0 {
            return "邀请我的小组"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! GroupTableViewCell
        if indexPath.section == 0 {
            let group = createdGroupList[indexPath.row]
            cell.setupCellWithProjectName()
        } else if indexPath.section == 1 {
            
        }
        return cell
    }
}

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var captainLabel: UILabel!
    
    func setupCellWithProjectName(name: String, creator: Member, members: [Member]) {
        
    }
    
}
