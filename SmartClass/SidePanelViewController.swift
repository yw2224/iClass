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
    
    var sidePanel = SidePanel()
    weak var delegate: SidePanelDelegate?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
}

extension SidePanelViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidePanel.count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(sidePanel.cellID) as! PersonalSettingsTableViewCell
        
        cell.configureWithImageName(sidePanel.iconName(indexPath.row),
            text: sidePanel.text(indexPath.row))
        return cell
    }
    
}

extension SidePanelViewController: UITableViewDelegate {
    
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        delegate?.sidePanelTappedAtRow?(indexPath.row, sender: cell)
	}
}

class PersonalSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    
    func configureWithImageName(name: String, text: String) {
        iconImageView.image = UIImage(named: name)
        settingLabel.text = text
    }
}