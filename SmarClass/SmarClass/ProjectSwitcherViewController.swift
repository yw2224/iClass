//
//  ProjectSwitcherViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/5.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProjectSwitcherViewController: SwitcherViewController {
    
    var courseID: String!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pvc = segue.destinationViewController as? ProblemViewController {
            pvc.courseID = courseID
        } else if let gvc = segue.destinationViewController as? GroupViewController {
            gvc.courseID = courseID
        }
        super.prepareForSegue(segue, sender: sender)
    }

}
