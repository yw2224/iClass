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
    var AnswerDictionary: NSMutableDictionary {get set}
    
}

class QuestionContainerViewController: UIViewController {
    
    var answerDict = NSMutableDictionary()
    // MARK: Init these variables in the presenting view controller's prepareForSegue
    var editType: EditType = .Inspect
    var quiz_id: String!
    
    private struct Constants {
        static var NumOfPages = 0
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
        println("answer")
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
            return quiz_id
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

