//
//  AboutUsViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/9/10.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var carousel: iCarousel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        carousel.type = .Rotary
        carousel.pagingEnabled = true
        carousel.bounces = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension AboutUsViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 5
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var retView: AboutUsView!
        //create new view if no view is available for recycling
        if let view = view as? AboutUsView {
            retView = view
        } else {
            retView = AboutUsView(frame: CGRectMake(0, 0,
                CGRectGetWidth(self.view.frame) * 0.70,
                CGRectGetHeight(self.view.frame) * 0.70))

        }
        retView.setupWithIndex(min(max(index, 0), 4))
        return retView
    }
}

extension AboutUsViewController: iCarouselDelegate {
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing) {
            return value * 1.3
        }
        return value
    }
    
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        pageControl.currentPage = min(max(carousel.currentItemIndex, 0), 4)
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        // Open his/her homepage
        UIApplication.sharedApplication().openURL(NSURL(string:
            GlobalConstants.HomePageLinks[min(max(index, 0), 4)])!)
    }
    
}

