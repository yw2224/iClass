//
//  TestDetailViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
import CocoaLumberjack

enum EditType {
    
    case Edit
    case Inspect
}

protocol QuestionRetrieveDataSource: class {
    
    var Type: EditType {get set}
    var QuizId: String {get}
    var QuizName: String {get}
    var CourseId: String {get}
    var AnswerDictionary: NSMutableDictionary {get set}
}

class QuestionContainerViewController: UIViewController {
    
    var answerDict = NSMutableDictionary()
    // MARK: Init these variables in the presenting view controller's prepareForSegue
    var editType: EditType = .Inspect
    var quiz: Quiz!
    
    private struct Constants {
        static let QuestionViewControllerIdentifier = "Question View Controller"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if editType == .Edit {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAnswers")
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "submitAnswers")
            let answerArray = CoreDataManager.sharedInstance.cachedAnswerForQuiz(QuizId)
            for answer in answerArray {
                answerDict[answer.question_id] = answer
            }
        } else {
            view.backgroundColor = UIColor.flatWhiteColor()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? QuestionPageViewController {
            dest.quizDelegate = self
        }
    }
    
    func cancelAnswers() {
        let alertController = UIAlertController(title: "确定退出测验？", message: "未提交的测验将被保存", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "确认", style: .Destructive) {
            (alertAction) in
            CoreDataManager.sharedInstance.saveInForeground()
            self.navigationController?.popViewControllerAnimated(true)
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func submitAnswers() {
        // present HUD
        var status = [AnswerJSON]()
        for (key, value) in answerDict {
            let answer = value as! Answer
            var originAnswer = [String]()
            for choice in answer.originAnswer.allObjects {
                originAnswer.append((choice as! Choice).content)
            }
            status.append(AnswerJSON(question_id: key as! String, originAnswer: originAnswer))
        }
        ContentManager.sharedInstance.submitAnswer(quiz.course_id, quiz_id: quiz.quiz_id, status: status) { (success, answerList, message) in
            DDLogDebug("\(success) \(answerList)")
            
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}

extension QuestionContainerViewController: QuestionRetrieveDataSource {
    
    var Type: EditType {
        get {
            return editType
        }
        set {
            editType = Type
        }
    }
    
    var QuizId: String {
        get {
            return quiz.quiz_id
        }
    }
    
    var QuizName: String {
        get {
            return quiz.name
        }
    }
    
    var CourseId: String {
        get {
            return quiz.course_id
        }
    }
    
    var AnswerDictionary: NSMutableDictionary {
        get {
            return answerDict
        }
        set {
            answerDict = AnswerDictionary
        }
    }
}

