//
//  InformationTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/12/25.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotificationTableViewController: CloudAnimateTableViewController {

    var courseID: String!
    var i: Int! = 1
    var notificationList = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override var emptyTitle: String {
        get {
            return "没有通知，请下拉以刷新。"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "通知"
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        retrieveNotificationList(i)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveNotificationList(page: Int) {
        if page == 1 {
            self.notificationList.removeAll()
        }
        ContentManager.sharedInstance.notificationList(ContentManager.UserID, token: ContentManager.Token, page: page, courseID: courseID) {
            (notificationList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            print("notificationList here:")
            print(notificationList)
            self.notificationList.appendContentsOf(notificationList)// = notificationList
            self.animationDidEnd()
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: RefreshControlHook
extension NotificationTableViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveNotificationList(i)
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

// MARK: UITableViewDataSource
extension NotificationTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Notification Cell") as! NotificationTableViewCell
        let notification = notificationList[indexPath.row]
        let tempLen = notification.content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        print("templen == ")
        print(tempLen)
        let len = CGFloat(Float(tempLen/19))
        cell.setupWithInfo(notification.content!, title: notification.title!, postuser: notification.posterName!, data: notification.createDate!, height: len)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let notification = notificationList[indexPath.row].content
        let len = notification!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) //=10
        let floatLen = (Float(len)) / 3.5
        let ret = CGFloat(floatLen)
        return ret + 200
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
            retrieveNotificationList(i)
            print("end of table!");
        }
    }
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var poseuserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setupWithInfo(content: String, title: String, postuser:String, data:NSNumber, height: CGFloat) {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        contentLabel.numberOfLines = 0;
        contentLabel.frame = CGRectMake(5, 5, 200, height + 70)
       
        //contentLabel.backgroundColor = UIColor.blueColor()
        contentLabel.text = content
        titleLabel.text = title
        poseuserLabel.text = postuser
        
        var timeSta:NSTimeInterval = data.doubleValue
        let datenow = NSDate(timeIntervalSince1970: timeSta/1000.0)
        let dformatter = NSDateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print(dformatter.stringFromDate(datenow))
        
        dateLabel.text = dformatter.stringFromDate(datenow)
        
    }
}
