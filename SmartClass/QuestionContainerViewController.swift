//
//  TestDetailViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import CocoaLumberjack
import SVProgressHUD
import UIKit

enum EditType {
    
    case Edit
    case Inspect
}

class QuestionContainerViewController: UIViewController {
    
    var answerDict = NSMutableDictionary()
    
    private struct Constants {
        static let QuestionViewControllerIdentifier = "Question View Controller"
    }
    
    // MARK: Inited in the prepareForSegue()
    var editType: EditType = .Inspect
    var quizID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if editType == .Edit {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAnswers")
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "submitAnswers")
            let answerArray = CoreDataManager.sharedInstance.cachedAnswerForQuiz(quizID)
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
            dest.answerDict = answerDict
            dest.quizID = quizID
            dest.editType = editType
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
        SVProgressHUD.showWithStatus(GlobalConstants.SubmittingAnswerPrompt)
        
        let quiz = CoreDataManager.sharedInstance.quiz(quizID)
        var status = [AnswerJSON]()
        for (key, value) in answerDict {
            let answer = value as! Answer
            let originAnswer: [String] = answer.originAnswer.allObjects.map {
                return ($0 as! Choice).content
            }
            let score = answer.score.integerValue //??
            status.append(AnswerJSON(question_id: key as! String, originAnswer: originAnswer,score:score))
        }
        
        ContentManager.sharedInstance.submitAnswer(quiz.course_id, quizID: quiz.quiz_id, status: status) {
            (answerList, error) in
            SVProgressHUD.popActivity()
            
            if error == nil {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                if case .NetworkUnauthenticated = error! {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.SubmitAnswerErrorPrompt)
                } else if case .NetworkWrongParameter = error! {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.AnswerInconsistencyErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
    }
}

