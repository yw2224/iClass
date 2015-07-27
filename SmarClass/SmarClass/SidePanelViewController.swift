//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

@objc protocol SidePanelDelegate {
    optional func sidePanelTappedAtRow(row: Int)
}

class SidePanelViewController: UIViewController {
    
    var delegate: SidePanelDelegate?
    
    private struct Constants {
        static let settingsTableViewText = [
            0: ["个人中心"],
            1: ["清理缓存", "夜间模式"],
            2: ["意见反馈", "关于"]
        ]
        static let settingsTableViewIcon = [
            0: ["PersonalCenter"],
            1: ["CleanCache", "NightMode"],
            2: ["Feedback", "About"]
        ]
        static let CellHeight: CGFloat = 40.0
        static let PersonalSettingsTableViewCellIdentifier = "SettingsCell"
		static let LoginStoryBoardIdentifier = "LoginContainerView"
		static let PersonalInfoStoryBoardIdentifier = "PersonalInfoTableView"
		static let PersonalInfoSegue = "PersonalInfoSegue"
    }
    
    @IBOutlet weak var personalSettingsTableView: UITableView! {
        didSet {
            personalSettingsTableView.dataSource = self
            personalSettingsTableView.delegate = self
            personalSettingsTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func unwindToSidePanel(sender: UIStoryboardSegue) {
		
	}
	
	func jumpToLoginPage()
	{
		if let myStoryBoard = self.storyboard{
			if let loginContainerView: LoginContainerViewController = myStoryBoard.instantiateViewControllerWithIdentifier(Constants.LoginStoryBoardIdentifier) as? LoginContainerViewController {
				self.presentViewController(loginContainerView, animated: true, completion: nil)
			}
		}
		
	}
	
	func jumpToPersonalInfoPage()
	{
		if let myStoryBoard = self.storyboard {
			if let personalInfoView : PersonalInfoTableViewController = myStoryBoard.instantiateViewControllerWithIdentifier(Constants.PersonalInfoStoryBoardIdentifier) as? PersonalInfoTableViewController {
				self.presentViewController(personalInfoView, animated: true, completion: nil)
			}
		}
	}
}

extension SidePanelViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Constants.settingsTableViewText.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section >= 0 && section <= 2) {
            return Constants.settingsTableViewText[section]!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PersonalSettingsTableViewCellIdentifier) as! PersonalSettingsTableViewCell
        
        cell.configureWithImage(Constants.settingsTableViewIcon[indexPath.section]![indexPath.row], settingLabelText: Constants.settingsTableViewText[indexPath.section]![indexPath.row])
        return cell
    }
}

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CellHeight
    }
    
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("row selected: \(indexPath.section) \(indexPath.row)")
		if indexPath.section == 2 && indexPath.row == 2 {
			jumpToLoginPage()
		}else if indexPath.section == 0 && indexPath.row == 0{
//			jumpToPersonalInfoPage()
			performSegueWithIdentifier(Constants.PersonalInfoSegue, sender: self)
		}
		
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