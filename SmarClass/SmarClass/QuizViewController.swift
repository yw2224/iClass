//
//  TestViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import CocoaLumberjack

class QuizViewController: CloudAnimateTableViewController {

    var course_id: String!
    var quizList = [Quiz]() {
        didSet {
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "尚未添加小测验，下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Quiz Cell"
        static let QuizCellHeight: CGFloat = 66.0
        static let PercentageViewTag = 1
        static let ShowQuizDetailSegue = "Show Quiz Detail Segue"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        retrieveQuizList()
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
        if let qcvc = segue.destinationViewController as? QuestionContainerViewController,
            let cell = sender as? QuizTableViewCell {
                let indexPath = tableView.indexPathForCell(cell)!
                let quiz = quizList[indexPath.row]
                qcvc.quiz = quiz
                qcvc.editType = quiz.correct.integerValue == -1 ? .Edit : .Inspect
        }
    }
    
    func retrieveQuizList() {
        ContentManager.sharedInstance.quizList(course_id) {
            (success, quizList, message) in
            DDLogDebug("\(success) \(message)")
            self.quizList = quizList
            self.animationDidEnd()
        }
    }

}

extension QuizViewController: RefreshControlHook {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveQuizList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

extension QuizViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! QuizTableViewCell
        let quiz = quizList[indexPath.row]
        let percentage: CGFloat = {
            (quiz: Quiz) -> CGFloat in
            let correct = CGFloat(quiz.correct.integerValue)
            let total = CGFloat(quiz.total.integerValue)
            return correct == -1 ? -1 : correct * 1.0 / total // -1 means this quiz is not finished
        }(quiz)
        cell.setupWithTestName(quiz.name,
            deadline: quiz.to,
            percentage: percentage)
        return cell
    }
}

extension QuizViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.QuizCellHeight
    }
}

class QuizTableViewCell: UITableViewCell {
    
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var percentageView: PercentageView!
    
    func setupWithTestName(name: String, deadline: NSDate, percentage: CGFloat) {
        testNameLabel.text = name
        let timeFormatter: NSDateFormatter = {
            let f = NSDateFormatter()
            f.locale = NSLocale(localeIdentifier: "zh_CN")
            f.dateFormat = "MM-dd"
            return f
        }()
        deadlineLabel.text = "截止时间： " + timeFormatter.stringFromDate(deadline)
        percentageView.percentage = percentage
    }
}