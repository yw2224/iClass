//
//  QuestionViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/5.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

enum QuestionType: String {
    
    case TrueFalse = "true/false"
    case SingleChoice = "single choice"
    case MultipleChoice = "multiple choice"
    case BlankFilling = "blank filling"
    case ShortAnswer = "short answer"
    
}

class QuestionViewController: IndexViewController {
    
    var total: Int!
    var question: Question!
    weak var quizDelegate: QuestionRetrieveDataSource!
    weak var pageViewController: QuestionPageViewController!
    var questionType: QuestionType? {
        get {
            return QuestionType(rawValue: question.type)
        }
    }
    
    private struct Constants {
        static let QuestionCellHeight: CGFloat = 66.0
        static let QuestionHeaderCell = "Header Cell"
        static let QuestionChoiceCell = "Choice Cell"
        static let QuestionTextCell = "Text Cell"
    }
	
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.QuestionCellHeight
        
        indexLabel.text = "\(index + 1)"
        totalLabel.text = "\(total)"
        nameLabel.text  = question.content
        
        if quizDelegate.Type == .Inspect {
            tableView.backgroundColor = UIColor.flatWhiteColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}

extension QuestionViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return {
            if let type = QuestionType(rawValue: self.question.type) {
                switch type {
                case .TrueFalse, .SingleChoice, .MultipleChoice:
                    return self.question.options.allObjects.count + 1
                case .BlankFilling, .ShortAnswer:
                    return 2
                }
            }
            return 1 // Header view (i.e., question content) occupy one row
        }()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        if index == 0 {
            return headerCell()
        } else if let type = QuestionType(rawValue: question.type) {
            var cell: UITableViewCell!
            switch type {
            case .TrueFalse, .SingleChoice, .MultipleChoice:
                cell = choiceCell()
                let text: String = {
                    (index) in
                    var ret = ""
                    self.question.options.enumerateObjectsUsingBlock {
                        (option, stop) in
                        if let opt = option as? Option {
                            if opt.no.integerValue == (index - 1) {
                                ret = opt.content
                                stop.memory = true
                            }
                        }
                    }
                    return ret
                }(index)
                (cell as! ChoiceTableViewCell).setupWithNumber(index, text: text)
            case .BlankFilling, .ShortAnswer:
                cell = textCell()
                (cell as! TextTableViewCell).setupWithText("", indexPath: indexPath)
                (cell as! TextTableViewCell).textField.delegate = self
            }
            
            if quizDelegate.Type == .Inspect {
//                        cell.accessoryView right answer
            }
            setupCellAnswer(cell, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func headerCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionHeaderCell) as! UITableViewCell
        let typeText: String = {
            if let type = self.questionType {
                return [
                    QuestionType.TrueFalse: "判断题",
                    QuestionType.SingleChoice: "单选题",
                    QuestionType.MultipleChoice: "多选题",
                    QuestionType.BlankFilling: "填空题",
                    QuestionType.ShortAnswer: "简答题"][type]!
            }
            return ""
        }()
        (cell as! QuestionHeaderTableViewCell).setupWithText(question.content + "\t\(typeText)")
        return cell
    }
    
    func choiceCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionChoiceCell) as! UITableViewCell
        return cell
    }
    
    func textCell() -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(Constants.QuestionTextCell) as! UITableViewCell
    }
    
    func setupCellAnswer(cell: UITableViewCell, indexPath: NSIndexPath) {
        if let answer = quizDelegate.AnswerDictionary[question.question_id] as? Answer {
            if let cell = cell as? ChoiceTableViewCell {
                answer.originAnswer.enumerateObjectsUsingBlock{ (choice, stop) -> Void in
                    let choice = choice as! Choice
                    if choice.content == "\(indexPath.row - 1)" {
                        cell.setChoiceViewSelected(true)
                        stop.memory = true
                    }
                }
            } else if let cell = cell as? TextTableViewCell {
                if let choice = answer.originAnswer.allObjects.first as? Choice {
                    cell.textField.text = choice.content
                }
            }
        }
    }
}

extension QuestionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.QuestionCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if quizDelegate.Type == .Inspect {
            return
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? HeaderTableViewCell {
            return
        }

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextTableViewCell {
            return
        }
        
        let selected: Bool = {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChoiceTableViewCell {
                return !cell.choiceViewSelected()
            }
            return false
        }()
        // If the question is not 'multiple-choice', unselect other cell
        cancelCellsInSection(indexPath.section)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChoiceTableViewCell {
            cell.setChoiceViewSelected(selected)
            // Update Answers
            updateAnswersWithIndexPath(indexPath)
            // Auto increment, if the question is not of 'multuple choice'
            autoIncreaseTableView()
        }
    }
    
    func cancelCellsInSection(section: Int) {
        if let type = questionType {
            if type == .MultipleChoice {
                return
            }
            
            for i in 1 ..< tableView.numberOfRowsInSection(section) {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: section)) as? ChoiceTableViewCell {
                    cell.setChoiceViewSelected(false)
                }
            }
        }
    }
    
    func autoIncreaseTableView() {
        if let type = questionType {
            if type == .MultipleChoice {
                return
            }
            
            if type == .BlankFilling || type == .ShortAnswer {
                if let choice = (quizDelegate.AnswerDictionary[question.question_id] as? Answer)?.originAnswer.allObjects.first as? Choice {
                    if choice.content == "" {
                        return
                    }
                }
            }
            
            if let count = (quizDelegate.AnswerDictionary[question.question_id] as? Answer)?.originAnswer.count {
                if count == 0 {
                    return
                }
            }
            
            if index < total - 1 {
                pageViewController.setViewControllers([pageViewController.questionChildViewControllerAtIndex(index + 1)!], direction: .Forward, animated: true, completion: nil)
            } else {
                // present HUD for the first time
            }
        }
    }
    
    func updateAnswersWithIndexPath(indexPath: NSIndexPath) {
        let index = indexPath.row
        let question_id = question.question_id
        let answerEntity: Answer = {
            if let answer = self.quizDelegate.AnswerDictionary[question_id] as? Answer {
                return answer
            }
            let answer = Answer.MR_createEntity()
            answer.quiz_id = self.quizDelegate.QuizId
            answer.question_id = question_id
            return answer
        }()
        if let type = questionType {
            switch type {
            case .BlankFilling, .ShortAnswer:
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextTableViewCell {
                    answerEntity.originAnswer = NSSet(array:
                        Choice.objectFromStringArray([cell.textField.text]))
                }
            case .SingleChoice, .TrueFalse, .MultipleChoice:
                var array = [String]()
                for i in 1 ..< tableView.numberOfRowsInSection(indexPath.section) {
                    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: indexPath.section)) as? ChoiceTableViewCell {
                        if cell.choiceViewSelected() {
                            array.append("\(i - 1)")
                        }
                    }
                }
                answerEntity.originAnswer = NSSet(array:
                    Choice.objectFromStringArray(array))
            }
            quizDelegate.AnswerDictionary[question_id] = answerEntity
        }
    }
}

class QuestionHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    func setupWithText(text: String) {
        headerLabel.text = text
    }
}

class ChoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var choiceView: ChoiceView!
    @IBOutlet weak var choiceLabel: UILabel!
    
    func setupWithNumber(number: Int, text: String) {
        choiceView.numberIndex = number
        choiceLabel.text = text
    }
    
    func choiceViewSelected() -> Bool {
        return choiceView.selected
    }
    
    func setChoiceViewSelected(selected: Bool) {
        choiceView.selected = selected
    }
}

class TextTableViewCell: UITableViewCell {
    
    var indexPath: NSIndexPath!
    @IBOutlet weak var textField: UITextField!
    
    func setupWithText(text: String, indexPath IndexPath: NSIndexPath) {
        indexPath = IndexPath
        textField.text = text
        textField.placeholder = "请输入答案…"
    }
}

extension QuestionViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return quizDelegate.Type == .Edit
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Cell -> ContentView -> TextField
        if let ttvc = textField.superview?.superview as? TextTableViewCell {
            updateAnswersWithIndexPath(ttvc.indexPath)
        }
        autoIncreaseTableView()
    }
    
}