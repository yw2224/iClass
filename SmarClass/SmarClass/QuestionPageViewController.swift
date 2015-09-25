//
//  QuestionPageViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/9/7.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import CocoaLumberjack
import UIKit

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
            (quizContent, error) in
            // dismiss HUD
            // MARK: if failed, present HUD
            self.questionList = quizContent
            if self.quizDelegate.Type == .Edit {
                self.setupPageViewController()
            } else {
                // retrieve origin answer from network
                self.retrieveOriginAnswers()
            }
        }
    }
    
    func retrieveOriginAnswers() {
        ContentManager.sharedInstance.originAnswer(quizDelegate.CourseId, quizId: quizDelegate.QuizId) {
            (answerList, error) in
            // MARK: if failed, present HUD
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
        guard index >= 0 && index < questionList.count, let qvc = UIStoryboard.initViewControllerWithIdentifier(Constants.QuestionViewControllerIdentifier) as? QuestionViewController else {return nil}
        qvc.index = index
        qvc.total = questionList.count
        qvc.question = questionList[index]
        qvc.quizDelegate = quizDelegate
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



