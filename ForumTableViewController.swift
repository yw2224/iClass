//
//  ForumTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/4.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD


class ForumTableViewController: CloudAnimateTableViewController {
    


    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func indexChange(sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            currentSeg = "EX"
            i = 1
            exList.removeAll()
            retrieveExList(currentSeg, page: i)
        case 1:
            currentSeg = "QA"
            i = 1
            exList.removeAll()
            retrieveExList(currentSeg, page: i)
        default:
            break;
        }
    }
    
    var courseID: String!
    var i = 1
    var exList = [EX]() {
        didSet {
            //SVProgressHUD.showInfoWithStatus("loading...")
            tableView.reloadData()
            //SVProgressHUD.dismiss()
        }
    }
    var currentSeg = "EX"
    
    override var emptyTitle: String {
        get {
            return "没有通知，请下拉以刷新。"
        }
    }
    @IBAction func indexChange2(sender: AnyObject?) {
        let segment: UISegmentedControl = sender as! UISegmentedControl
        switch segment.selectedSegmentIndex
        {
        case 0:
            currentSeg = "EX"
            i = 1
            exList.removeAll()
            retrieveExList(currentSeg, page: i)
        case 1:
            currentSeg = "QA"
            i = 1
            exList.removeAll()
            retrieveExList(currentSeg, page: i)
        default:
            break;
        }
    }
    
    @IBAction func newPostButtonTapped(sender: UIButton?) {
        
        performSegueWithIdentifier("ShowNewPostSegue", sender: sender)
    }
    
    
    private func createSubViews(segment: UISegmentedControl){
        segment.selectedSegmentIndex = 0;
        segment.addTarget(self, action: "indexChange2:", forControlEvents: .ValueChanged)
    }
    
    private func createBarItem(newPost: UIButton) {
        newPost.setBackgroundImage(UIImage(named: "add"), forState: .Normal)
        newPost.sizeToFit()
        newPost.addTarget(self, action: "newPostButtonTapped:", forControlEvents: .TouchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: newPost)
        navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveExList(currentSeg, page: i)
        
        var newPost: UIButton! = UIButton()
        var segment = UISegmentedControl(items:["经验分享","答疑解惑"])
        segment.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        
        self.createSubViews(segment)
        self.createBarItem(newPost)
        self.navigationItem.titleView = segment
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToForum(segue: UIStoryboardSegue) {
        // Force refresh the data
        exList.removeAll()
        i = 1
        retrieveExList(self.currentSeg, page: i)
        //tableView.reloadData()
    }

    func retrieveExList(type: String, page: Int) {
        
        ContentManager.sharedInstance.exList(ContentManager.UserID!, token: ContentManager.Token!, courseID: courseID, type: type, page: i) {
            (exList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            self.exList.appendContentsOf(exList)// = notificationList
            //print("exList here:")
            //print(exList)
            self.animationDidEnd()
        }
    }
}

extension ForumTableViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        i = 1
        retrieveExList(currentSeg, page: i)
        // Remember to call 'animationDidEnd' in the following code
        
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

extension ForumTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Forum Cell") as! ForumTableViewCell
        let ex = exList[indexPath.row]
        
        cell.setupWithInfo(ex.postingID!, title: ex.title!, postUserID: ex.postUserID!, like: ex.like!,date:ex.postDate!)
        print("看看这里的时间！！")
        print(ex.postDate)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 150
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var refreshBounds = refreshControl!.bounds
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -refreshControl!.frame.origin.y)
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min(max(pullDistance, 0.0), 100.0) / 50.0
        let scaleRatio = 1 + pullRatio
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance;
        
        cloudRefresh.spot.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
        cloudRefresh.frame = refreshBounds
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (refreshControl!.refreshing && !isAnimating) {
            animateRefreshStep1()
        }

        
        let height: CGFloat = scrollView.frame.size.height;
        let contentYoffset: CGFloat = scrollView.contentOffset.y;
        let distanceFromBottom: CGFloat = scrollView.contentSize.height - contentYoffset;
        
        if (distanceFromBottom < height) {
            i = i + 1;
            retrieveExList(currentSeg, page: i)
            print("end of table!");
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //let cell = tableView.dequeueReusableCellWithIdentifier("Lesson Cell") as! LessonTableViewCell
        performSegueWithIdentifier("ShowPostSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPostSegue"
        {
            if let dest = segue.destinationViewController as? PostTableViewController
            {
                let indexPath = tableView.indexPathForSelectedRow!
                let postID = exList[indexPath.row].postingID!
                
                dest.postID = postID
                //dest.lessonFileList = CoreDataManager.sharedInstance.lessonFileList(lesson.lessonName!)*/
                //print("dest.lessonID:")
                //print(dest.lessonID)
                dest.courseID = self.courseID
                dest.currentSeg = self.currentSeg
            }
        }
        
        else if segue.identifier == "ShowNewPostSegue"
        {
            if let dest = segue.destinationViewController as? NewPostViewController
            {
                dest.courseID = self.courseID
                dest.type = self.currentSeg
            }
        }
        
    }
}

class ForumTableViewCell : UITableViewCell {
    
    //@IBOutlet weak var postIDLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postUserIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //@IBOutlet weak var likeLabel: UILabel!
    
    func setupWithInfo(postID: String, title: String, postUserID: String, like: NSNumber, date: String)
    {
        let titleLen = lengthTrans(title)
        let postIDLen = lengthTrans(postID)
        let postUserIDLen = lengthTrans(postUserID)
        
        titleLabel.frame = CGRectMake(5, 5, titleLen + 50, titleLen + 60)
        //titleLabel.backgroundColor = UIColor.darkGrayColor()
        titleLabel.text = "标题：" + title
        titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        
        //postUserIDLabel.frame = CGRectMake(5, 5, postUserIDLen + 50, postUserIDLen + 60)
        postUserIDLabel.text = "作者：" + postUserID
        
        //likeLabel.text = like.stringValue
      /*  var dateFormatter = NSDateFormatter()
        let dateString = dateFormatter.stringFromDate(date)
        dateLabel.text = dateString*/
        
        /*var timeSta:NSTimeInterval = date.doubleValue
        let datenow = NSDate(timeIntervalSince1970: timeSta/1000.0)
        let dformatter = NSDateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print(dformatter.stringFromDate(datenow))*/
        let index = date.startIndex.advancedBy(11) //swift 2.0+
        let index2 = date.endIndex.advancedBy(-5) //swift 2.0+
        var range = Range<String.Index>(start: index,end: index2)
        var labelfordate: String = date.substringToIndex(date.startIndex.advancedBy(10)) + " " + date.substringWithRange(range)
        dateLabel.text = date.substringToIndex(date.startIndex.advancedBy(10)) + " " + date.substringWithRange(range)

        
    }
    
    func lengthTrans(str: String) -> CGFloat
    {
        let len = str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let tempLen = CGFloat(Float(len))
        return tempLen
    }
}

