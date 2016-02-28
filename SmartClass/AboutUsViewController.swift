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
    
    private struct Constants {
        static let Items = 5
        static func index(x : Int) -> Int {
            return max(min(x, Items), Items - 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        carousel.type = .Rotary
        carousel.pagingEnabled = true
        carousel.bounces = false
    }

}

extension AboutUsViewController: iCarouselDataSource {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return Constants.Items
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
        retView.setupWithIndex(Constants.index(index))
        return retView
    }
}

extension AboutUsViewController: iCarouselDelegate {
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Spacing {
            return value * 1.3
        }
        return value
    }
    
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        pageControl.currentPage = Constants.index(carousel.currentItemIndex)
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        // Open his/her homepage
        UIApplication.sharedApplication().openURL(NSURL(string:
            GlobalConstants.HomePageLinks[Constants.index(index)])!)
    }
    
}

