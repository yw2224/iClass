//
//  ProjectViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/13.
//  Copyright © 2015年 PKU. All rights reserved.
//

import SVProgressHUD
import UIKit

class ProjectViewController: CloudAnimateTableViewController {
    
    var projectList = [Project]() {
        didSet {
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "没有课程项目，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Project Cell"
        static let ProjectCellHeight: CGFloat = 66.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        retrieveProjectList()
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard
            let cell = sender as? ProjectTableViewCell,
            let indexPath = tableView.indexPathForCell(cell) where indexPath.row >= 0 && indexPath.row < projectList.count,
            let dest = segue.destinationViewController as? ProjectContainerViewController else {return}
        let project = projectList[indexPath.row]
        dest.projectID = project.project_id
        dest.title = project.name
    }
    
    func retrieveProjectList() {
        ContentManager.sharedInstance.projectList(courseID) {
            (projectList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            self.projectList = projectList
            self.animationDidEnd()
        }
    }
    
}

// MARK: RefreshControlHook
extension ProjectViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveProjectList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

// MARK: UITableViewDataSource
extension ProjectViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! ProjectTableViewCell
            let project = projectList[indexPath.row]
            cell.setupWithProjectName(project.name, deadline: project.to)
            return cell
        }
}

// MARK: UITableViewDelegate
extension ProjectViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.ProjectCellHeight
    }
}

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak internal var deadlineLabel: UILabel!

    func setupWithProjectName(name: String, deadline: NSDate) {
        let timeFormatter: NSDateFormatter = {
            let f = NSDateFormatter()
            f.locale = NSLocale(localeIdentifier: "zh_CN")
            f.dateFormat = "MM-dd"
            return f
        }()
        projectNameLabel.text = name
        deadlineLabel.text = "组队截止时间： " + timeFormatter.stringFromDate(deadline)
    }
}