//
//  GroupViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//


import MGSwipeTableCell
import SVProgressHUD
import UIKit

class GroupViewController: CloudAnimateTableViewController {

    var createdGroupList = [Group]()
    var invitedGroupList = [Group]()
    var groupID: String? {
        didSet {
            // MARK: We should disable the 'INVITE' bar button here
        }
    }
    
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
        let cmp: (Group, Group) -> Bool = {
            if $0.status != $1.status {
                // Whatever group is accepted, put it up front
                let accept = GroupStatus.Accept.rawValue
                if $0.status == accept || $1.status == accept {
                    return $0.status == accept
                }
                return $0.status < $1.status
            } else {
                if $0.name != $1.name {
                    return $0.name < $1.name
                }
                return $0.creator.name < $1.creator.name
            }
        }
        
        ContentManager.sharedInstance.groupList(projectID) {
            (groupID, creatorList, memberList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.GroupListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            
            self.createdGroupList = creatorList.sort(cmp)
            self.invitedGroupList = memberList.sort(cmp)
            self.groupID = groupID
            self.tableView.reloadData()
            
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

// UITableViewDataSource. UITableViewDelegate
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
        if GroupStatus(rawValue: group.status.integerValue) == .Pending && indexPath.section == 1 {
            let acceptButton = MGSwipeButton(title: "接受", icon: nil, backgroundColor: UIColor.flatLimeColor(), padding: 20)
            let declineButton = MGSwipeButton(title: "拒绝", icon: nil, backgroundColor: UIColor.flatRedColor(), padding: 20)
            let settings = MGSwipeExpansionSettings()
            settings.buttonIndex = 0
            settings.animationDuration = 0.1
            cell.rightButtons = [acceptButton, declineButton]
            cell.rightSwipeSettings.transition = .Drag
            cell.rightExpansion = settings
            cell.delegate = self
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? MGSwipeTableCell else {return}
        cell.showSwipe(.RightToLeft, animated: true)
    }
}

extension GroupViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let indexPath = tableView.indexPathForCell(cell) else {return false}
        let group = indexPath.section  == 0 ? createdGroupList[indexPath.row] : invitedGroupList[indexPath.row]
        let block: (NetworkErrorType?) -> Void = {
            error in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkForbiddenAccess = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.GroupOperationRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            // Acts as refresing
            self.retrieveGroupList(self.projectID)
        }
        if index == 0 { // Accept some group
            ContentManager.sharedInstance.groupAccept(projectID, groupID: group.group_id, block: block)
        } else if index == 1 { // Decline some group
            ContentManager.sharedInstance.groupDecline(projectID, groupID: group.group_id, block: block)
        }
        return true
    }
}

class GroupTableViewCell: MGSwipeTableCell {
    
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
