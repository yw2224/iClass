//
//  PreferenceViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/14.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class PreferenceViewController: ProblemViewController {
    var indexPath: NSIndexPath!
}

// MARK: UITableViewDelegate
extension PreferenceViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let path = self.indexPath, let cell = tableView.cellForRowAtIndexPath(path) {
            cell.accessoryType = .None
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        self.indexPath = indexPath
    }
}