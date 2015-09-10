//
//  CloudAnimateTableViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/27.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol RefreshControlHook: class {
    func animationDidStart()
    func animationDidEnd()
}

class CloudAnimateTableViewController: UITableViewController {
    
    var cloudRefresh: RefreshContents!
    var isAnimating = false
    var alpha: CGFloat = 0.0 {
        didSet {
            cloudRefresh.background.alpha = alpha
            cloudRefresh.refreshingImageView.alpha = alpha
            cloudRefresh.spot.alpha = 1.0 - alpha
        }
    }
    var emptyTitle: String {
        get {
            return "网络错误，请下拉以刷新！"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        setupRefreshControl()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetAnimiation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = UIColor.clearColor()
        refreshControl!.backgroundColor = UIColor.clearColor()
        tableView.addSubview(refreshControl!)
        
        cloudRefresh = RefreshContents(frame: refreshControl!.bounds)
        refreshControl!.addSubview(cloudRefresh)
    }
    
    func animateRefreshStep1() {
        isAnimating = true
        
        cloudRefresh.background.image = UIImage(named: "CloudBackground")
        cloudRefresh.refreshingImageView.image = UIImage(named: "Refresh")
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 1.0
            }) {
                [weak self] in
                if $0 {
                    self?.animationDidStart()
            }
        }
    }
    
    func animateRefreshStep2() {
        cloudRefresh.background.image = UIImage(named: "Tick")
        UIView.animateWithDuration(0.6, animations: {
            self.cloudRefresh.background.alpha = 1.0
            }) {
                [weak self] in
                if $0 {
                    self?.resetAnimiation()
            }
        }
    }
    
    func resetAnimiation() {
        cloudRefresh.refreshingImageView.layer.removeAnimationForKey("rotate")
        refreshControl!.endRefreshing()
        isAnimating = false
        alpha = 0
    }
}


extension CloudAnimateTableViewController: UIScrollViewDelegate, RefreshControlHook {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // Get the current size of the refresh controller
        var refreshBounds = refreshControl!.bounds
        
        // Distance the table has been pulled >= 0
        var pullDistance = max(0.0, -refreshControl!.frame.origin.y)
        
        // Calculate the pull ratio, between 0.0-1.0
        var pullRatio = min( max(pullDistance, 0.0), 100.0) / 50.0
        var scaleRatio = 1 + pullRatio
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance;
        
        cloudRefresh.spot.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
        cloudRefresh.frame = refreshBounds
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (refreshControl!.refreshing && !isAnimating) {
            animateRefreshStep1()
        }
    }
    
    func animationDidStart() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = M_PI * 2
        rotate.duration  = 0.9
        rotate.cumulative = true;
        rotate.repeatCount = 1e7;
        
        cloudRefresh.refreshingImageView.layer.addAnimation(rotate, forKey: "rotate")
    }
    
    func animationDidEnd() {
        if !isAnimating {
            return
        }
        UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveLinear, animations: {
            self.cloudRefresh.background.alpha = 0
            self.cloudRefresh.refreshingImageView.alpha = 0
            }) { [weak self] in
                if $0 {
                    self?.animateRefreshStep2()
            }
        }

    }
}

extension CloudAnimateTableViewController: DZNEmptyDataSetSource {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyDataSetBackground")!
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: GlobalConstants.EmptyTitleTintColor
        ]
        return NSAttributedString(string: emptyTitle, attributes: attributes)
    }
}

extension CloudAnimateTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return false
    }
}