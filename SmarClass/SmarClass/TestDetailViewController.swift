//
//  TestDetailViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/28.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
//import CocoaLumberjack
//import MBProgressHUD

protocol TestDetailViewControllerAskForAnswersDataSource {
	func testDetailGatherAnswers(viewCOntroller : UIViewController,indexForQuestion index : Int) -> String
}
class TestDetailViewController: UIViewController{
	
	//data
	var test : Test?
	var answers : Dictionary<Int,String> = Dictionary<Int,String>()
	var answerEntities : [Answers]?{
		didSet {
			println("answerentities did set")
		}
	}
	var testQuestionList: [TestQuestion]? {
		didSet {
			tdcvc?.testQuestionList = self.testQuestionList
			if let cnt = self.testQuestionList?.count {
				self.total = cnt
			}
		}
	}

	var total : Int = 0{
		didSet{
			self.popSliderValue = 1
			self.progressLabel.setNeedsDisplay()
		}
	}
	var tdcvc : TestDetailContainerViewController?
	private struct Constants {
		static let EmbeddedSegue = "Embedded Segue"
	}
//	@IBOutlet weak var popoverSlider: PopoverSlider! 
    @IBOutlet weak var progressLabel: UILabel!
	var popSliderValue :Int = 0 {
		didSet {
			self.progressLabel.text = self.popSliderValue.description + " / " + total.description
			self.progressLabel.setNeedsDisplay()
		}
	}
	
	//deleate and datasource
	var askForAnswersDataSource :TestDetailViewControllerAskForAnswersDataSource?
    override func viewDidLoad() {
        super.viewDidLoad()

		
		
		let saveBtn = UIBarButtonItem(title: "提交", style: UIBarButtonItemStyle.Plain, target: self, action: "handleSaveBtn:")
		self.navigationItem.rightBarButtonItem = saveBtn
		
		setQuestionList()
        // Do any additional setup after loading the view.
		if let total = testQuestionList?.count.description{
			progressLabel.text = "1 / " + total
		}
//		popoverSlider.addTarget(self, action: "handleSliderValueChange:", forControlEvents: UIControlEvents.ValueChanged)
//		popoverSlider.continuous = true
//		popoverSlider.maximumValue = Float(total)
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		saveAnswersIntoEntity()
	}
	func saveAnswersIntoEntity(){
		//gather answers
		
	}
	func submitAnswersToServer(){
//		if let testId = test?.id.integerValue{
//			let answers = ModelCRUD.answersByTestId(testId)
//			for answer in answers {
//				SCRequest.submitTestAnswerByTestQuestionId(testId, testQuestionId: answer.0, answer: answer.1)
//					{ (_, _, JSON, _) -> Void in
//						println(JSON)
//				}
//			}
//			SCRequest.submitTestQuestionAnswers(testId, answers: answers)
//				{ (_, _, JSON, _) -> Void in
//				//do nothing
//					NSLog("data submitted : \(JSON)")
//			}
//		}
		
	}
	func showSaveAlertView(){
		//get answers from coreData
		getAnswerEntities()
		var answerString :String = ""
		if answerEntities?.count > 0 {
			for answer in answerEntities!{
				answerString += answer.testQuestionId.stringValue + "." + answer.answer + "\n"
				answers[answer.testQuestionId.integerValue] = answer.answer
			}
		}
		let message = "你的答案是 :\n " + answerString
		var alert = UIAlertController(
			title: "提交答案",
			message: message,
			preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(
			title: "确认",
			style: UIAlertActionStyle.Default)
			{ (action :UIAlertAction!) -> Void in
				//do something
				self.showSavingView()
			})
		alert.addAction(UIAlertAction(
			title: "取消",
			style: UIAlertActionStyle.Cancel)
			{ (action :UIAlertAction!) -> Void in
				//do nothing
			}
		)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func showSavingView(){
//		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//		hud.mode = MBProgressHUDMode.Text
//		hud.labelText = "提交成功"
//		hud.showAnimated(true, whileExecutingBlock: { () -> Void in
//			self.submitAnswersToServer()
//			sleep(2)
//		}) { () -> Void in
//			hud.removeFromSuperview()
//		}
	}
	func handleSaveBtn(sender:UIBarButtonItem){
		if sender.title == "提交"{
			//alert view
			showSaveAlertView()
		}
	}
//	func handleSliderValueChange(sender : PopoverSlider){
//		let value = sender.value
//		let popvalue = sender.popoverView.value
////		DDLogWarn("self.popSliderValue:\(self.popSliderValue) popvalue : \(popvalue)")
//		
//		if popvalue != self.popSliderValue {
//			tdcvc?.jumpToSelectPage(selectIndex: popvalue)
//			self.popSliderValue = popvalue
//			if let total = testQuestionList?.count.description {
//				self.progressLabel.text = self.popSliderValue.description + " / " + total
//			}
//		}
//	}
	func getAnswerEntities(){
		if let test = self.test {
			let testId = test.id.integerValue
			let predicate = NSPredicate(format: "testId == \(testId)")
//			self.answerEntities =  Answers.MR_findAllWithPredicate(predicate) as? [Answers]
		}
	}
	func saveAnswers(sender :UIBarButtonItem) {
		//save answers  and go back to TestViewController
		if let datasource = self.askForAnswersDataSource {
			for index in 1...total{
				 answers[index] = datasource.testDetailGatherAnswers(self, indexForQuestion: index)
			}
			
		}
	}
	func setQuestionList(){
		if self.test != nil{
//			SCData.testQuestion(test!.id.integerValue, testQuestionList: &self.testQuestionList){
//				(_,_,JSON,_) in
//				if JSON?.valueForKey("result") as? Bool == true {
//						self.testQuestionList = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.TestQuestion) as? [TestQuestion]
//				}
//			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.EmbeddedSegue {
			if let mvc  = segue.destinationViewController as? TestDetailContainerViewController {
				tdcvc = mvc
				tdcvc?.pageChangeDelegate = self
			}
		}
	}
	

}

extension TestDetailViewController : UIPageViewControllerPageChangeDelegate {
	func pageChangeToIndex(pageViewController: UIPageViewController, pageIndex: Int) {
		let pvc = pageViewController
//		if pageIndex > 0 && pageIndex <= self.total{
//			if self.popSliderValue != pageIndex {
//				self.popoverSlider.value = Float(pageIndex)
//				self.popSliderValue = pageIndex
//				self.popoverSlider.setNeedsDisplay()
//			}
			
//		}
	}
}
