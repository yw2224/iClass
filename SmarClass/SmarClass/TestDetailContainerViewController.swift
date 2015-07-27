//
//  TestDetailContainerViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/23.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import CoreData
import UIKit

//import CocoaLumberjack

class TestDetailContainerViewController: UIViewController {
	
    var test:Test?
//		didSet {
//			if let test = self.test {
//				SCData.testQuestion(self.test!.id.integerValue, testQuestionList: &self.testQuestionList){
//					(_,_,JSON,_) in
//					self.testQuestionList = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.TestQuestion) as? [TestQuestion]
//				}
//			}
//		}

	var testQuestionList : [TestQuestion]?
	{
		didSet {
			
			setupQuestionViewControllers()
		}
	}
	var qvcList :[QuestionViewController]? {
		didSet {
//			DDLogWarn("set qvclist")
//			addQuestionsToPage()
		}
	}
	var presentIndex : Int? {
		didSet{
//			DDLogWarn("presentIndex set to: \(self.presentIndex)")
		}
	}
    var questionPageViewController: UIPageViewController!
	
	
	var pageChangeDelegate : UIPageViewControllerPageChangeDelegate?
    private struct Constants {
        static let QestionViewControllerIdentifier = "QuestionViewController"
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        questionPageViewController.dataSource = self
        questionPageViewController.delegate = self
//		questionPageViewController.view.frame.size = self.view.frame.size
		self.addChildViewController(questionPageViewController)
		self.view.addSubview(questionPageViewController.view)
		questionPageViewController.willMoveToParentViewController(self)
    }

	func addQuestionsToPage(){
//
		if let cnt = self.qvcList?.count{
			if cnt > 0 {
				questionPageViewController.setViewControllers([self.qvcList![0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
			}
		}
	}
	
  	func setupQuestionViewControllers(){
		if let cnt =  testQuestionList?.count {
//			DDLogWarn("cnt:\(cnt)")
			var qvclist = [QuestionViewController]()
			for index in 0..<cnt {
				//create qvc
//				DDLogWarn("index:\(index)")
				if let tq = testQuestionList?[index]{
					let qvc = UIStoryboard.initViewControllerWithIdentifier(Constants.QestionViewControllerIdentifier) as! QuestionViewController
					qvc.index = index+1
					qvc.testQuestion = testQuestionList![index]
					qvc.askDataSource = self
					qvc.delegate = self
					qvclist.append(qvc)

				}
				if self.qvcList?.count > 0{
//				DDLogWarn("qvclist.count"+self.qvcList!.count.description)
				}
			}
			self.qvcList = qvclist
		}
		addQuestionsToPage()
	}
    
    func questionViewControllerAtIndex(index: Int) -> UIViewController? {

        if index < 0 || index >= 5 {
            return nil
        }
        let qvc = UIStoryboard.initViewControllerWithIdentifier(Constants.QestionViewControllerIdentifier) as! QuestionViewController
        qvc.index = index
        return qvc
		
    }
	

//
	func jumpToSelectPage(#selectIndex :Int)
	{
		if let  pvc = self.questionPageViewController.viewControllers[0] as? QuestionViewController
		{
			let pageIndex = pvc.index
			if let cnt = self.qvcList?.count
			{
				if selectIndex < pageIndex && selectIndex > 0
				{//backward
					
						self.questionPageViewController.setViewControllers([self.qvcList![selectIndex-1]], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
					
				}
				else
				{
					
					if selectIndex <= cnt && selectIndex > pageIndex
					{ //forward
						self.questionPageViewController.setViewControllers([self.qvcList![selectIndex-1]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
					}
				}
			}
		}
	}
	
	
	
	func saveAnswersForQuestionByIndex(choice : String, index : Int){
		if self.testQuestionList != nil {
			if (index - 1) < self.testQuestionList?.count && index > 0{
				let testQuestion = self.testQuestionList![index - 1]
				let tqid = testQuestion.id
				let predicate = NSPredicate(format: "testQuestionId == \(tqid)")
//				let cnt = Answers.MR_numberOfEntitiesWithPredicate(predicate)
//				if cnt.integerValue > 1 {
//					//delete all the answsers and rebuild one
//					ModelCRUD.deleteAnswersByTestQuestionId(tqid.integerValue)
//					let answerEntity:Answers = Answers.MR_createEntity() as! Answers
//					answerEntity.answer = choice
//					answerEntity.testId = testQuestion.testId
//					answerEntity.testQuestionId = tqid
//					NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//
//				}else if cnt == 1 {
//					let answerEntity: Answers = Answers.MR_findFirstWithPredicate(predicate) as! Answers
//					answerEntity.answer = choice
//					NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//				}else if cnt.integerValue <= 0 {
//					//create one and  save it
//					let answerEntity:Answers = Answers.MR_createEntity() as! Answers
//					answerEntity.answer = choice
//					answerEntity.testId = testQuestion.testId
//					answerEntity.testQuestionId = tqid
//					NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//				}
				
			}
		}
	}
	
}
extension TestDetailContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let theIndex = (viewController as? QuestionViewController)?.index {
//            return questionViewControllerAtIndex(theIndex - 1)
			if theIndex > 1{
				return self.qvcList?[theIndex - 1 - 1]
			}
			
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let theIndex = (viewController as? QuestionViewController)?.index {
//            return questionViewControllerAtIndex(theIndex + 1)
			if theIndex < self.qvcList!.count {
				return self.qvcList?[theIndex + 1 - 1 ]
			}
			
        }
        return nil
    }

	
}

extension TestDetailContainerViewController: UIPageViewControllerDelegate {
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		if let pvc = pageViewController.viewControllers[0] as? QuestionViewController {
			let pageIndex = pvc.index
			if let delegate = self.pageChangeDelegate {
				delegate.pageChangeToIndex(self.questionPageViewController, pageIndex: pageIndex)
			}
		}
	}
}

protocol UIPageViewControllerPageChangeDelegate : NSObjectProtocol {
		func pageChangeToIndex(pageViewController:UIPageViewController ,pageIndex: Int )
}

extension TestDetailContainerViewController : QuestionViewControllerAskTotalQuestionDataSource {
	func questionViewController(viewController: QuestionViewController) -> Int {
		return (self.testQuestionList?.count != nil ) ? self.testQuestionList!.count : 0
	}
}
extension TestDetailContainerViewController : QuestionViewControllerDelegate {
	func jumpToQuestionViewControllerIndex(index: Int) {
		self.jumpToSelectPage(selectIndex: index)
	}
	func answerSetForQuestionViewController(viewController: QuestionViewController, index: Int) {
		let qvc = viewController
		if let qvcChoice = qvc.choice {
			if qvcChoice != ""{
				saveAnswersForQuestionByIndex(qvcChoice,index: index)
			}
		}
	}
}
