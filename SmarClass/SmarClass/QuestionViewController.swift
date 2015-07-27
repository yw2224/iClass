//
//  QuestionViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/5.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import CoreData
import UIKit
//import CocoaLumberjack

protocol QuestionViewControllerAskTotalQuestionDataSource {
	func questionViewController(viewController : QuestionViewController) ->Int
}
protocol QuestionViewControllerDelegate {
	func jumpToQuestionViewControllerIndex(index:Int)
	func answerSetForQuestionViewController(viewController:QuestionViewController,index:Int)
//	func submitAnswer(viewController : UIViewController, AnswerForIndex  answer: String, index : Int)
}
class QuestionViewController: IndexViewController, UITableViewDataSource, UITableViewDelegate {
	
	var testQuestion :TestQuestion? {
		didSet{
			if  (testQuestion != nil && questionTableView != nil) {
				self.questionTableView.reloadData()
			}
		}
	}
	
    @IBOutlet weak var questionTableView: UITableView! {
        didSet {
            questionTableView.tableFooterView = UIView(frame: CGRectZero)
            questionTableView.rowHeight = UITableViewAutomaticDimension
			questionTableView.sectionHeaderHeight = UITableViewAutomaticDimension
			questionTableView.sizeToFit()
			        }
    }
	var askDataSource : QuestionViewControllerAskTotalQuestionDataSource?
	var delegate : QuestionViewControllerDelegate?
    private struct Constants {
        static let CellIdentifier = "QuestionCell"
		static let AnswerDict = [1:"A",2:"B",3:"C",4:"D"]
    }
	var choice : String? {
		didSet {
			self.delegate?.answerSetForQuestionViewController(self, index: self.index)
			self.questionTableView.reloadData()
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		questionTableView.dataSource = self
		questionTableView.delegate = self
		questionTableView.rowHeight = UITableViewAutomaticDimension
		questionTableView.tableFooterView?.userInteractionEnabled = true
		questionTableView.tableFooterView?.multipleTouchEnabled = true
//		loadAnswers()
		questionTableView.reloadData()
    }

	 override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		//save the answers 
//		self.delegate?.answerSetForQuestionViewController(self, index: self.index)
		
	}
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
	}
//	func saveAnswerEntity(){
//		//check if answerEntity already existed
//		if  (self.testQuestion != nil && self.choice != nil){
//			let tq = self.testQuestion!
//			let tqId = tq.id
//				NSLog("tqid:\(tqId))")
//			let predicate = NSPredicate(format: " testQuestionId == \(tqId)")
////			let cnt = Answers.MR_numberOfEntitiesWithPredicate(predicate)
//			NSLog("cnt:\(cnt)")
//			if cnt.integerValue > 0 {
//				let entities = Answers.MR_findAllWithPredicate(predicate) as! [Answers]
//				if cnt.integerValue > 1 {
//					//delete the entities with only one left
//					for i in 0..<(cnt.integerValue - 1) {
//						let entity = entities[i]
//						NSLog("delete answerEntity:\(entity.testQuestionId) : \(i) :\(entity.answer)")
//						entity.MR_deleteEntity()
//						NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//					}
//					
//				}
//				
//			
//			let tmp  = Answers.MR_numberOfEntitiesWithPredicate(predicate)
//				NSLog("tmp number: \(tmp)")
//			if let answerEntity :Answers = Answers.MR_findFirstWithPredicate(predicate) as? Answers {
//				//update the entity:
//				if let ans  =  self.choice  {
//					NSLog("entity answer in update: \(answerEntity.answer)")
//					if  answerEntity.answer != ""{
//						let entityAns = answerEntity.answer
//						if entityAns == ans {
//							return
//						}else{
//							answerEntity.answer = ans
//							NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//							return
//						}
//					} else {
//						answerEntity.answer = ans
//						NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//						return
//					}
//				}
//			}
//		}//end cnt > 0
//				//create new entity
//			else if let  answerEntity: Answers = Answers.MR_createEntity() as? Answers{
//				if let testId = self.testQuestion?.testId {
//					answerEntity.testId = testId
//				}
//				if let tqId = self.testQuestion?.id {
//					answerEntity.testQuestionId = tqId
//				}
//				if let ans = self.choice {
//					answerEntity.answer = ans
//					NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
//					NSLog("answer saved : \(answerEntity.testQuestionId)")
//					return
//				}
//				
//			}//end of else if answerEntity
//			
//		}//end of tq
//	}
//	func loadAnswers(){
//		NSLog("------------loading answers...")
//		if let tq = self.testQuestion {
//			let predicate = NSPredicate(format: " testQuestionId == \(tq.id)")
//			if Answers.MR_numberOfEntitiesWithPredicate(predicate).integerValue > 0 {
//				let answerEntity: Answers = Answers.MR_findFirstWithPredicate(predicate) as! Answers
//				self.choice = answerEntity.answer
//				NSLog("self.choice is \(self.choice)")
//			}
//		}
//	}
}


extension QuestionViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! QuestionTableViewCell

		cell.questionTextField.text = testQuestion?.choice
		if Constants.AnswerDict[indexPath.row + 1 ] == self.choice {
			cell.selectView.setSelected()
		}
        return cell
    }
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return testQuestion?.content
	}
	func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		var str = "选择的答案是："
		if let choice = self.choice {
			str += choice
		}
		return str
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let answer = Constants.AnswerDict[ indexPath.row + 1 ]
		if let cell = tableView.cellForRowAtIndexPath(indexPath) as? QuestionTableViewCell{
			//set all cell unselected
			clearSelection()
			cell.selectView.setSelected()
			
		}
		
		self.choice = answer
	}
	func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) as? QuestionTableViewCell{
			cell.selectView.setUnSelected()
			
		}

	}
	func clearSelection(){
		for row in 0...3 {
		let indexPath = NSIndexPath(forRow: row, inSection: 0)
			if let cell = self.questionTableView.cellForRowAtIndexPath(indexPath) as? QuestionTableViewCell{
				cell.selectView.setUnSelected()
				
			}
			
		}
	}
//	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//		
////		let footerSwitch = UISwitch(frame: CGRectMake(215.0, 5, 80, 45))
////		footerView.addSubview(footerSwitch)
//		return createFooterView( )
//	}
	func createFooterView() -> UIView {
		let screenRect = UIScreen.mainScreen().applicationFrame
		let footerView = UIView(frame: CGRectMake(0, 0, screenRect.size.width, 44.0))
//		DDLogError("screenRect.size:width: \(screenRect.size.width) ; height: \(screenRect.size.height) ")
		footerView.autoresizesSubviews = true
		footerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
		footerView.userInteractionEnabled = true
		footerView.hidden = false
		footerView.multipleTouchEnabled = true
		footerView.opaque = false
		footerView.contentMode = UIViewContentMode.ScaleToFill
		let btnWidth : CGFloat = screenRect.size.width/6
		let btnHeight :CGFloat = 30
		let margin :CGFloat = 10
		let nextBtn = UIButton(frame: CGRectMake(screenRect.size.width - btnWidth - margin, margin, btnWidth, btnHeight))
		nextBtn.backgroundColor = UIColor.blueColor()
		nextBtn.opaque = false
		nextBtn.setTitle("下一题", forState: UIControlState.Normal)
		nextBtn.addTarget(self, action: "jumpToNext:", forControlEvents: UIControlEvents.TouchUpInside)
		nextBtn.multipleTouchEnabled = true
		nextBtn.userInteractionEnabled = true
		if let maxIndex = self.askDataSource?.questionViewController(self)
		{
			if self.index < maxIndex{
				footerView.addSubview(nextBtn)
			}
		}
		let preBtn = UIButton(frame: CGRectMake(margin, margin, btnWidth, btnHeight))
		preBtn.backgroundColor = UIColor.orangeColor()
		preBtn.opaque = false
		preBtn.setTitle("上一题", forState: UIControlState.Normal)
		preBtn.addTarget(self, action: "jumpToPrevious:", forControlEvents: UIControlEvents.TouchUpInside)
		if self.index > 1{
			footerView.addSubview(preBtn)
		}
		footerView.bringSubviewToFront(nextBtn)
		footerView.bringSubviewToFront(preBtn)
		return footerView
	}
	
	func jumpToNext(sender : UIButton){
		let index = self.index
//		DDLogWarn("self index @jumptonext:\(index)")
		delegate?.jumpToQuestionViewControllerIndex(index + 1)
	}
	func jumpToPrevious(sender:UIButton){
		delegate?.jumpToQuestionViewControllerIndex(self.index - 1)
	}

}

class QuestionTableViewCell: UITableViewCell {
	
	@IBOutlet weak var selectView: ChoiceView!

	@IBOutlet weak var questionTextField: UITextView!
	
}
