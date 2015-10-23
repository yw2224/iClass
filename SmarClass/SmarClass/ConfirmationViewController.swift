//
//  ConfirmationViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/14.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class ConfirmationViewController: IndexCollectionViewController {
    
    private struct Constants {
        static let CellIdentifier                              = "Teammate Cell"
        static let HeaderIdentifier                            = "Confirm Header"
        static let FooterIdentifier                            = "Confirm Footer"
        static let CollectionCellWidth: CGFloat                = 100.0
        
        static let CollectionCellMinimumItemSpacing: CGFloat   = 10.0
        static let CollectionViewMinimumMarginSpacing: CGFloat = 20.0
        
        static let CollectionViewMinimumLineSpacing: CGFloat   = 40.0
        static let CollectionViewTopMarginSpacing: CGFloat     = 20.0
    }
    
    // MARK: Inited in the prepareForSegue()
    weak var icvc: InvitationContainerViewController!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataManager.sharedInstance.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func inviteGroup() {
        icvc.inviteGroup()
    }
}

// MARK: UICollectionViewDataSource
extension ConfirmationViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icvc.teammates.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifier, forIndexPath: indexPath) as! TeammateCollectionViewCell
        let teammate = icvc.teammates[indexPath.row]
        cell.setupWithName(teammate.name, realName: teammate.realName, selected: true)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.HeaderIdentifier, forIndexPath: indexPath) as! ConfirmCollectionViewHeader
            header.setupWithProblemName(icvc.problemName ?? "")
            return header
        } else if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: Constants.FooterIdentifier, forIndexPath: indexPath) as! ConfirmCollectionViewFooter
            footer.inviteGroupButton.addTarget(self, action: "inviteGroup", forControlEvents: .TouchUpInside)
            return footer
        }
        return UICollectionReusableView()
    }
}

extension ConfirmationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsetsZero
        inset.top = Constants.CollectionViewTopMarginSpacing
        (inset.left, inset.right, _) = spacingForCollecionViewWidth(CGRectGetWidth(collectionView.frame))
        return inset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return spacingForCollecionViewWidth(CGRectGetWidth(collectionView.frame)).interItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewMinimumLineSpacing
    }
    
    func spacingForCollecionViewWidth(width: CGFloat) -> (leftSpacing: CGFloat, rightSpacing: CGFloat, interItemSpacing: CGFloat) {
        for itemNum in (2 ... 10).reverse() {
            let extraSpacing = width - CGFloat(itemNum) * Constants.CollectionCellWidth - CGFloat(itemNum - 1) * Constants.CollectionCellMinimumItemSpacing
            
            if extraSpacing > 2 * Constants.CollectionViewMinimumMarginSpacing {
                let borderMargin = floor(extraSpacing / 2)
                return (borderMargin, borderMargin, floor(Constants.CollectionCellMinimumItemSpacing))
            }
        }
        let borderMargin = floor((width - Constants.CollectionCellWidth) / 2)
        return (borderMargin, borderMargin, floor(Constants.CollectionCellMinimumItemSpacing))
    }
}

class ConfirmCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var problemNameLabel: UILabel!
    func setupWithProblemName(name: String) {
        problemNameLabel.text = "题目： \(name)"
    }
}

class ConfirmCollectionViewFooter: UICollectionReusableView {
    @IBOutlet weak var inviteGroupButton: UIButton!
}