//
//  ProjectSwitcherViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProjectSwitcherViewController: SwitcherViewController {
    
    var projectID: String!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pvc = segue.destinationViewController as? ProblemViewController {
            pvc.projectID = projectID
        } else if let gvc = segue.destinationViewController as? GroupViewController {
            gvc.projectID = projectID
        }
        super.prepareForSegue(segue, sender: sender)
    }

}
