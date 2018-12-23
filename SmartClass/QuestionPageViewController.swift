//
//  QuestionPageViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import CocoaLumberjack
import SVProgressHUD
import UIKit

class QuestionPageViewController: UIPageViewController {
    
    var questionList: [Question]!
    
    // MARK: Inited in the prepareForSegue()
    var editType: EditType!
    var answerDict: NSMutableDictionary!
    var quizID: String!
    
    private struct Constants {
        static let QuestionViewControllerIdentifier = "Question View Controller"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        retrieveQuizContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveQuizContent() {
        let quiz = CoreDataManager.sharedInstance.quiz(quizID)
        ContentManager.sharedInstance.quizContent(quiz.quiz_id) {
            (quizContent, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkForbiddenAccess = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.DataInconsistentErrorPrompt)
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.QuizContentRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            self.questionList = quizContent
            if self.editType == EditType.Edit {
                self.setupPageViewController()
            } else {
                // retrieve origin answer from network
                self.retrieveOriginAnswers()
            }
        }
    }
    
    func retrieveOriginAnswers() {
        let quiz = CoreDataManager.sharedInstance.quiz(quizID)
        ContentManager.sharedInstance.originAnswer(quiz.course_id, quizID: quiz.quiz_id) {
            (answerList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.OriginAnswerRetrieveErrorPrompt)
                } else if case .NetworkForbiddenAccess = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.DataInconsistentErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            
            for answer in answerList {
                self.answerDict[answer.question_id] = answer
            }
            self.setupPageViewController()
        }
    }
    
    func setupPageViewController() {
        if questionList.count <= 0 {
            return
        }
        
        dataSource = self
        delegate   = self
        setViewControllers([questionChildViewControllerAtIndex(0)!], direction: .Forward, animated: true, completion: nil)
    }
    
    func questionChildViewControllerAtIndex(index: Int) -> QuestionViewController? {
        guard index >= 0 && index < questionList.count, let qvc = UIStoryboard.initViewControllerWithIdentifier(Constants.QuestionViewControllerIdentifier) as? QuestionViewController else {return nil}
        let quiz = CoreDataManager.sharedInstance.quiz(quizID)
        qvc.index = index
        qvc.total = questionList.count
        qvc.quizName = quiz.name
        qvc.questionID = questionList[index].question_id
        qvc.editType = editType
        qvc.answerDict = answerDict
        qvc.pageViewController = self
        
        return qvc
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QuestionPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let qvc = viewController as? QuestionViewController else {return nil}
        return questionChildViewControllerAtIndex(qvc.index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let qvc = viewController as? QuestionViewController else {return nil}
        return questionChildViewControllerAtIndex(qvc.index + 1)
    }
    
}

extension QuestionPageViewController: UIPageViewControllerDelegate {
    
}



