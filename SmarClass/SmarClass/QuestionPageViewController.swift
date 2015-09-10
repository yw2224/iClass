//
//  QuestionPageViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import CocoaLumberjack

class QuestionPageViewController: UIPageViewController {
    
    // MARK: Init thses variables after networking
    var questionList: [Question]!
    weak var quizDelegate: QuestionRetrieveDataSource!
    
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
        // MARK: present HUD
        ContentManager.sharedInstance.quizContent(quizDelegate.QuizId) {
            (success, questionList, message) in
            DDLogDebug("\(success) \(message)")
            // dismiss HUD
            // MARK: if failed, present HUD
            self.questionList = questionList
            if self.quizDelegate.Type == .Edit {
                self.setupPageViewController()
            } else {
                // retrieve origin answer from network
                self.retrieveOriginAnswers()
            }
        }
    }
    
    func retrieveOriginAnswers() {
        ContentManager.sharedInstance.originAnswer(quizDelegate.QuizId) {
            (success, answerList, message) in
            // MARK: if failed, present HUD
            DDLogDebug("\(success) \(message)")
            for answer in answerList {
                self.quizDelegate.AnswerDictionary[answer.question_id] = answer
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
        if (index < 0 || index >= questionList.count) {
            return nil
        }
        
        return {
            let qvc = UIStoryboard.initViewControllerWithIdentifier(Constants.QuestionViewControllerIdentifier) as! QuestionViewController
            qvc.index = index
            qvc.total = self.questionList.count
            qvc.question = self.questionList[index]
            qvc.quizDelegate = self.quizDelegate
            qvc.pageViewController = self
            return qvc
        }()
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
        if let qvc = viewController as? QuestionViewController {
            return questionChildViewControllerAtIndex(qvc.index - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let qvc = viewController as? QuestionViewController {
            return questionChildViewControllerAtIndex(qvc.index + 1)
        }
        return nil
    }
    
}

extension QuestionPageViewController: UIPageViewControllerDelegate {
    
}



