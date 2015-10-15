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
        static let CellIdentifer = "Group Cell"
        static let GroupCellHeight : CGFloat = 220.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var projectID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.GroupCellHeight
        
        retrieveGroupList(projectID)
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

    func retrieveGroupList(projectID: String) {
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
        retrieveGroupList(projectID)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifer) as! GroupTableViewCell
        let group = indexPath.section == 0 ? createdGroupList[indexPath.row] : invitedGroupList[indexPath.row]
        cell.setupCellWithProjectName(group.name, creator: group.creator, members: group.members.allObjects as! [Member])
        switch group.status {
        case 1:
            cell.accessoryView = UIImageView(image: UIImage(named: "Accept"))
        case 2:
            cell.accessoryView = UIImageView(image: UIImage(named: "Decline"))
        default:
            cell.accessoryView = UIImageView(image: UIImage(named: "Idle"))
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            print(createdGroupList[indexPath.row])
        } else if indexPath.section == 1 {
            print(invitedGroupList[indexPath.row])
        }
    }
}

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var creatorName: String!, creatorRealName: String!
    var memberNames = [(name: String, realName: String)]()
    
    private struct Constants {
        static let CellIdentifer = "Member Cell"
    }
    
    func setupCellWithProjectName(projectName: String, creator: Member, members: [Member]) {
        projectNameLabel.text = projectName
        (creatorName, creatorRealName) = (creator.name, creator.realName)
        memberNames = members.map {
            return ($0.name, $0.realName)
        }
        collectionView.reloadData()
    }
}

extension GroupTableViewCell: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberNames.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifer, forIndexPath: indexPath) as! MemberCollectionViewCell
        if indexPath.row == 0 {
            cell.setupWithName(creatorName, realName: creatorRealName, isCaptain: true)
        } else {
            cell.setupWithName(memberNames[indexPath.row - 1].name, realName: memberNames[indexPath.row - 1].realName, isCaptain: false)
        }
        return cell
    }
}

extension GroupTableViewCell: UICollectionViewDelegate {
    
}

class MemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var captianIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stuNoLabel: UILabel!
    
    func setupWithName(name: String, realName: String, isCaptain: Bool) {
        avatarView.capital = realName
        captianIconImageView.image = isCaptain ? UIImage(named: "Captain") : UIImage(named: "Member")
        nameLabel.text = realName
        stuNoLabel.text = name
    }
    
}
