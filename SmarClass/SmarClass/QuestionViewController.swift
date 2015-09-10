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
        nameLabel.text  = quizDelegate.QuizName
        
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
        var cell: UITableViewCell!
        if index == 0 {
            cell = headerCell()
        } else if let type = QuestionType(rawValue: question.type) {
            switch type {
            case .TrueFalse, .SingleChoice, .MultipleChoice:
                cell = choiceCell(indexPath)
            case .BlankFilling, .ShortAnswer:
                cell = textCell(indexPath)
            }
        }
        setupCellAnswer(cell, indexPath: indexPath)
        if quizDelegate.Type == .Inspect {
            setupCellCorrectAnswer(cell, indexPath: indexPath)
        }
        return cell
    }
    
    func headerCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionHeaderCell) as! QuestionHeaderTableViewCell
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
        cell.setupWithText(question.content + "\t\(typeText)")
        return cell
    }
    
    func choiceCell(indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionChoiceCell) as! ChoiceTableViewCell
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
        cell.setupWithNumber(index, text: text)
        return cell
    }
    
    func textCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionTextCell) as! TextTableViewCell
        cell.setupWithText("", indexPath: indexPath)
        cell.textField.delegate = self
        return cell
    }
    
    func setupCellAnswer(cell: UITableViewCell, indexPath: NSIndexPath) {
        if let answer = quizDelegate.AnswerDictionary[question.question_id] as? Answer {
            if let cell = cell as? ChoiceTableViewCell {
                answer.originAnswer.enumerateObjectsUsingBlock{ (choice, stop) in
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
    
    func setupCellCorrectAnswer(cell: UITableViewCell, indexPath: NSIndexPath) {
        let index = indexPath.row
        if let answer = quizDelegate.AnswerDictionary[question.question_id] as? Answer {
            if let cell = cell as? ChoiceTableViewCell {
                question.correctAnswer.enumerateObjectsUsingBlock{ (choice, stop) in
                    let choice = choice as! Choice
                    if choice.content == "\(indexPath.row - 1)" {
                        cell.setChoiceViewCorrected(true)
                        stop.memory = true
                    }
                }
            } else if let cell = cell as? TextTableViewCell {
                if let choice = question.correctAnswer.allObjects.first as? Choice {
                    cell.setTextFieldCorrectText(choice.content)
                }
            }
        }
    }
}

extension QuestionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.QuestionCellHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if quizDelegate.Type == .Inspect {
            if let score = (quizDelegate.AnswerDictionary[question.question_id] as? Answer)?.score {
                let status = score.integerValue > 0
                tableView.tableHeaderView?.backgroundColor = status ?
                    UIColor(red: 228.0 / 255.0, green: 250.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0) :
                    UIColor(red: 246.0 / 255.0, green: 225.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
            }
        }
        return 0
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
        choiceView.correct = false
        choiceLabel.text = text
    }
    
    func choiceViewSelected() -> Bool {
        return choiceView.selected
    }
    
    func setChoiceViewSelected(selected: Bool) {
        choiceView.selected = selected
    }
    
    func setChoiceViewCorrected(correct: Bool) {
        if correct {
            choiceView.correct = true
        }
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
    
    func setTextFieldCorrectText(text: String) {
        let attributeText = NSMutableAttributedString(string: textField.text + "\t\(text)")
        attributeText.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber(integer: 2), range: NSMakeRange(0, count(textField.text)))
        textField.attributedText = attributeText
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