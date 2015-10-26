//
//  PreferenceViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/14.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class PreferenceViewController: ProblemViewController {
    
    var previousIndexPath: NSIndexPath?
    
    // MARK: Inited in the prepareForSegue()
    weak var icvc: InvitationContainerViewController!
    
    override var problemList: [Problem] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Problem Cell"
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension PreferenceViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! ProblemTableViewCell
        let problem = problemList[indexPath.row]
        cell.setupProblemWithProjectName(problem.name, introduction: problem.deskription, currentGroup: problem.groupSize.integerValue - 1, totalGroup: 0)
        
        if icvc.problemID == problem.problem_id {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let pip = previousIndexPath, let cell = tableView.cellForRowAtIndexPath(pip) {
            cell.accessoryType = .None
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        
        // Update data in the delegate
        let problem = problemList[indexPath.row]
        (icvc.problemID, icvc.groupSize, icvc.problemName, icvc.currentStage) =
            (problem.problem_id, problem.groupSize.integerValue - 1, problem.name, 1)
        previousIndexPath = indexPath
    }
}