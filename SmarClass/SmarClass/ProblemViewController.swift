//
//  ProblemViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProblemViewController: IndexCloudAnimateTableViewController {
    
    var problemList = [Problem]() {
        didSet {
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "大作业题目为空，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Problem Cell"
        static let ProblemCellHeight: CGFloat = 120.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var projectID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.ProblemCellHeight
        
        retrieveProblemList()
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
    
    func retrieveProblemList() {
        ContentManager.sharedInstance.problemList(projectID) {
            (problemList, error) in
            self.problemList = problemList.sort {
                return $0.name < $1.name
            }
            
            self.animationDidEnd()
        }
    }
    
}

// MARK: RefreshControlHook
extension ProblemViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveProblemList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

// MARK: UITableViewDataSource
extension ProblemViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return problemList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! ProblemTableViewCell
        let problem = problemList[indexPath.row]
        cell.setupProblemWithProjectName(problem.name, introduction: problem.deskription, currentGroup: problem.current.integerValue, totalGroup: problem.maxGroupNum.integerValue)
        return cell
    }
}

// MARK: UITableViewDelegate
extension ProblemViewController {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

}

class ProblemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var currentGroupLabel: UILabel!
    @IBOutlet weak var totalGroupLabel: UILabel!
    
    func setupProblemWithProjectName(projectName: String, introduction: String, currentGroup: Int, totalGroup: Int) {
        projectNameLabel.text = projectName
        introLabel.text = introduction
        currentGroupLabel.text = "\(currentGroup)"
        totalGroupLabel.text = "\(totalGroup)"
    }
}