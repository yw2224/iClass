//
//  CloudAnimateCollectionViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/15.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CloudAnimateCollectionViewController: UICollectionViewController  {
    
    var refreshControl: UIRefreshControl!
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
        collectionView!.emptyDataSetSource = self
        collectionView!.emptyDataSetDelegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetAnimiation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.backgroundColor = UIColor.clearColor()
        collectionView!.addSubview(refreshControl)
        collectionView!.alwaysBounceVertical = true
        
        cloudRefresh = RefreshContents(frame: refreshControl.bounds)
        refreshControl.addSubview(cloudRefresh)
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
        refreshControl.endRefreshing()
        isAnimating = false
        alpha = 0
    }
}


extension CloudAnimateCollectionViewController: RefreshControlHook {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // Get the current size of the refresh controller
        var refreshBounds = refreshControl.bounds
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -refreshControl.frame.origin.y)
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min(max(pullDistance, 0.0), 100.0) / 50.0
        let scaleRatio = 1 + pullRatio
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance;
        
        cloudRefresh.spot.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
        cloudRefresh.frame = refreshBounds
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (refreshControl.refreshing && !isAnimating) {
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

extension CloudAnimateCollectionViewController: DZNEmptyDataSetSource {
    
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

extension CloudAnimateCollectionViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return false
    }
}

class IndexCloudAnimateCollectionViewController: CloudAnimateCollectionViewController {
    var _index = 0
}

extension IndexCloudAnimateCollectionViewController: IndexObject {
    var index: Int {
        get {
            return _index
        }
        set {
            _index = newValue
        }
    }
}