//
//  TestViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/22.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit
//import CocoaLumberjack
class TestViewController: UIViewController {

	
	
	
	//datas
//	var course:Course? {
//		didSet {
////			handleRefresh(self.refreshControl)
////			DDLogWarn("course set :\(course?.name)")
//		}
//	}
//	var testList :[Test]? {
//		didSet {
//			if self.isViewLoaded() && self.view.window != nil {
//				//reload data
//				self.testTableView.reloadData()
//			}
//		}
//	}
	
	var testListFromNetwork:  ((NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void)!
//	required init(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		testListFromNetwork =
//		{ (request:NSURLRequest, response:NSHTTPURLResponse?, JSON:AnyObject?, error:NSError?) -> Void in
//			
//			if let result = JSON?.valueForKey("result") as? Bool
//			{
//				if result
//				{
//					self.testList = JsonUtil.MJ_Json2Model(JSON: (JSON as? NSDictionary)!, Type: ModelType.Test) as? [Test]
//					self.testTableView.reloadData()
//				}
//			}
//		}
//		
//	}
	
	
	
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var testTableView: UITableView! {
        didSet {
            testTableView.dataSource = self
            testTableView.delegate = self
            testTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    private struct Constants {
        static let CellIdentifier = "TestCell"
        static let HeaderHeight: CGFloat = 44.0
        static let FooterHeight: CGFloat = 44.0
        static let CellHeight: CGFloat = 66.0
		static let ShowDetailSegue = "showTestDetailSegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshControl.tintColor = UIColor(red: 247.0 / 255.0, green: 115.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
        testTableView.addSubview(refreshControl)
		self.testTableView.reloadData()
		refresh()
		
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        testTableView.setContentOffset(CGPointZero, animated: false)
		self.testTableView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        println(testTableView.frame)
//        
//        println(navigationController?.navigationBar.frame.height)
//        println(tabBarController?.navigationController?.navigationBar.frame.height)
//        
//        println(automaticallyAdjustsScrollViewInsets)
//        println(topLayoutGuide.length)
//        
//        println(topLayoutGuide.description)
    }
	
	func refresh(){
		handleRefresh(self.refreshControl)
	}
    func handleRefresh(sender: UIRefreshControl) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
		sender.beginRefreshing()
//		if let parent = self.parentViewController as? MainUITabBarController {
//			self.course = parent.course
//		}
//		if let course = self.course
//		{
//			getTestListData()
//			
//		}
		sender.endRefreshing()
//		dispatch_after(delayTime, dispatch_get_main_queue()) {
//			sender.endRefreshing()
//		}
    }
	

//	func getTestListData(){
//		SCData.test(course!.id.integerValue, testList: &self.testList, completionHandler: self.testListFromNetwork)
//		
//	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
//		if let identifier = segue.identifier {
//			if identifier == Constants.ShowDetailSegue
//			{
//				if let tdvc = segue.destinationViewController as? TestDetailViewController {
//					let indexPath = self.testTableView.indexPathForSelectedRow()
//					if let test = testList?[indexPath!.row] {
//						tdvc.test = test
//						
//					}
//
//				}
//			}
//		}
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

extension TestViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return (testList?.count != nil ) ? testList!.count :0
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! TestTableViewCell
//        cell.configureWithTestType("类别： TCP 基础知识", deadline: NSDate(), percentage: CGFloat(Double(arc4random_uniform(101))))
//		if  indexPath.row < testList?.count {
//			if let test = testList?[indexPath.row]{
//				let btime :NSDate
//				 let btimeString :NSString = test.btime
//					let timeInterval = btimeString.doubleValue
//					btime = NSDate(timeIntervalSince1970:timeInterval)
//					//				DDLogWarn("btime:\(btime)")
////				else {
////					btime  = NSDate()
////				}
//				//calculate percentage
//				
//				let cnt = ModelCRUD.numberOfTAnswersByTestId(test.id.integerValue)
//				let total = ModelCRUD.numberOfTestQuestionByTestId(test.id.integerValue)
//				var percentage : Int = 0
//				if total > 0 {
//					percentage = Int(cnt*100 / total)
//				}else {
//					percentage = 0
//				}
//				NSLog("percentage is:\(percentage)")
//				cell.configureWithTestType(test.name, deadline: btime, percentage: CGFloat(percentage))
//			}
//		}
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "正在进行的小测验："
        } else if section == 1 {
            return "已结束的小测验："
        }
        return nil
    }
}


extension TestViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.HeaderHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.CellHeight
    }
}

class TestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var testTypeLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var percentageBackground: CircleView!
    
    func configureWithTestType(type: String, deadline: NSDate, percentage: CGFloat) {
        testTypeLabel.text = type
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        timeFormatter.dateFormat = "MM-dd"
        deadlineLabel.text = "截止时间： " + timeFormatter.stringFromDate(deadline)
        percentageLabel.text = "\(percentage)%"
        percentageBackground.percentage = percentage
    }
}