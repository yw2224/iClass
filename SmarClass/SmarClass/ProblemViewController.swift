//
//  ProblemViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/28.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ProblemViewController: CloudAnimateTableViewController {
    
    override var emptyTitle: String {
        get {
            return "尚未添加小测验，下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Problem Cell"
        static let ProblemCellHeight: CGFloat = 66.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var courseID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.ProblemCellHeight
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: This should be improved for performance!
//        course = CoreDataManager.sharedInstance.course(courseID)
//        retrieveQuizList()
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
    }
    
    func retrieveQuizList() {
//        ContentManager.sharedInstance.quizList(course.course_id) {
//            (quizList, error) in
//            self.quizList = quizList
//            self.animationDidEnd()
//        }
    }
    
}

// MARK: RefreshControlHook
extension ProblemViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveQuizList()
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
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier)!
        return cell
    }
}

// MARK: UITableViewDelegate
extension ProblemViewController {
    
}

class ProblemTableViewCell: UITableViewCell {
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
}