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
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }

}

extension QuestionViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = QuestionType(rawValue: question.type) else {return 1}
        switch type {
            case .TrueFalse, .SingleChoice, .MultipleChoice:
                return self.question.options.allObjects.count + 1
            case .BlankFilling, .ShortAnswer:
                return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let type = QuestionType(rawValue: question.type) else {fatalError()}
        
        let index = indexPath.row
        var cell: UITableViewCell!
        if index == 0 {
            cell = headerCell()
        } else {
            switch type {
            case .TrueFalse, .SingleChoice, .MultipleChoice:
                cell = choiceCell(indexPath)
            case .BlankFilling, .ShortAnswer:
                cell = textCell(indexPath)
            }
            setupCellAnswer(cell, indexPath: indexPath)
            if quizDelegate.Type == .Inspect {
                setupCellCorrectAnswer(cell, indexPath: indexPath)
            }
        }

        return cell
    }
    
    func headerCell() -> UITableViewCell {
        guard let type = QuestionType(rawValue: question.type) else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionHeaderCell) as! QuestionHeaderTableViewCell
        let typeText = [
            QuestionType.TrueFalse: "判断题",
            QuestionType.SingleChoice: "单选题",
            QuestionType.MultipleChoice: "多选题",
            QuestionType.BlankFilling: "填空题",
            QuestionType.ShortAnswer: "简答题"][type] ?? ""
        cell.setupWithText(question.content + "\t\(typeText)")
        return cell
    }
    
    func choiceCell(indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuestionChoiceCell) as! ChoiceTableViewCell
        let text: String = {
            for option in question.options.allObjects where (option as! Option).no.integerValue == (index - 1) {
                return (option as! Option).content
            }
            return ""
        }()
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
        guard let answer = quizDelegate.AnswerDictionary[question.question_id] as? Answer else {return}
        if let cell = cell as? ChoiceTableViewCell {
            for choice in answer.originAnswer.allObjects
                    where (choice as! Choice).content == "\(indexPath.row - 1)" {
                cell.setChoiceViewSelected(true)
                break
            }
        } else if
            let cell = cell as? TextTableViewCell,
            let choice = answer.originAnswer.allObjects.first as? Choice {
            cell.textField.text = choice.content
        }
    }
    
    func setupCellCorrectAnswer(cell: UITableViewCell, indexPath: NSIndexPath) {
        if let cell = cell as? ChoiceTableViewCell {
            for choice in question.correctAnswer.allObjects
                where (choice as! Choice).content == "\(indexPath.row - 1)" {
                    cell.setChoiceViewCorrected(true)
                    break
            }
        } else if
            let cell = cell as? TextTableViewCell,
            let choice = question.correctAnswer.allObjects.first as? Choice {
                cell.setTextFieldCorrectText(choice.content)
        }
    }
}

extension QuestionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.QuestionCellHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard
            quizDelegate.Type == .Inspect,
            let score = (quizDelegate.AnswerDictionary[question.question_id] as? Answer)?.score
            else {return 0}
        let status = score.integerValue > 0
        tableView.tableHeaderView?.backgroundColor = status ?
            GlobalConstants.QuestionCorrectTableViewTitleColor :
            GlobalConstants.QuestionWrongTableViewTitleColor
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard
            quizDelegate.Type == .Edit,
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChoiceTableViewCell
            else {return}
        
        let selected = !cell.choiceViewSelected()
        // If the question is not 'multiple-choice', unselect other cell
        cancelCellsInSection(indexPath.section)
        
        cell.setChoiceViewSelected(selected)
        // Update Answers
        updateAnswersWithIndexPath(indexPath)
        // Auto increment, if the question is not of 'multuple choice'
        autoIncreaseTableView()
    }
    
    func cancelCellsInSection(section: Int) {
        guard let type = questionType where type != .MultipleChoice else {return}
        for i in 1 ..< tableView.numberOfRowsInSection(section) {
            guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: section)) as? ChoiceTableViewCell else {
                break
            }
            cell.setChoiceViewSelected(false)
        }
    }
    
    func autoIncreaseTableView() {
        guard let type = questionType where type != QuestionType.MultipleChoice else {return}
        guard let originAnswer = (quizDelegate.AnswerDictionary[question.question_id] as? Answer)?.originAnswer else {return}
        
        if type == .BlankFilling || type == .ShortAnswer {
            guard let choice = originAnswer.allObjects.first as? Choice where choice.content != ""
                else {return}
        }
        if (type == .SingleChoice || type == .TrueFalse) && originAnswer.count == 0 {
            return
        }
        
        if index < total - 1 {
            pageViewController.setViewControllers([pageViewController.questionChildViewControllerAtIndex(index + 1)!], direction: .Forward, animated: true, completion: nil)
        } else {
            // present HUD for the first time
        }
    }
    
    func updateAnswersWithIndexPath(indexPath: NSIndexPath) {
        guard let type = questionType else {return}
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
        
        switch type {
        case .BlankFilling, .ShortAnswer:
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextTableViewCell {
                answerEntity.originAnswer = NSSet(array:
                    Choice.objectFromStringArray([cell.textField.text ?? ""]))
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
        let attributeText = NSMutableAttributedString(string: textField.text ?? "" + "\t\(text)")
        attributeText.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber(integer: 2), range: NSMakeRange(0, textField.text?.characters.count ?? 0))
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