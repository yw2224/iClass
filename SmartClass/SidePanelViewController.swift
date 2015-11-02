//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

@objc protocol SidePanelDelegate: class {
    
    optional func sidePanelTappedAtRow(row: Int, sender: AnyObject)
}

class SidePanelViewController: UIViewController {
    
    @IBOutlet weak var personalSettingsTableView: UITableView! {
        didSet {
            personalSettingsTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    private struct Constants {
        static let settingsTableViewText = [
//            "个人中心", "清理缓存", "夜间模式", "意见反馈",
            "关于", "注销账户"
        ]
        static let settingsTableViewIcon = [
//            "PersonalCenter", "CleanCache", "NightMode", "Feedback",
            "About", "Logout"
        ]
        static let CellHeight: CGFloat                     = 40.0
        static let PersonalSettingsTableViewCellIdentifier = "SettingsCell"
    }
    
    // MARK: Inited in the prepareForSegue()
    weak var delegate: SidePanelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SidePanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Constants.settingsTableViewText.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PersonalSettingsTableViewCellIdentifier) as! PersonalSettingsTableViewCell
        
        cell.configureWithImage(Constants.settingsTableViewIcon[indexPath.row], settingLabelText: Constants.settingsTableViewText[indexPath.row])
        return cell
    }
    
}

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CellHeight
    }
    
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        delegate?.sidePanelTappedAtRow?(indexPath.row, sender: cell)
	}
}

class PersonalSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    
    func configureWithImage(image: String, settingLabelText: String) {
        iconImageView.image = UIImage(named: image)
        settingLabel.text = settingLabelText
    }
}