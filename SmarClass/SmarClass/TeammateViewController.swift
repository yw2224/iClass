//
//  TeammateViewController.swift
//  SmarClass
//
//  Created by PengZhao on 15/10/13.
//  Copyright © 2015年 PKU. All rights reserved.
//

import UIKit

class TeammateViewController: IndexCloudAnimateCollectionViewController {

    var teammateList = [Teammate]() {
        didSet {
            collectionView!.reloadData()
        }
    }
    
    private struct Constants {
        static let CellIdentifier                              = "Teammate Cell"
        static let HeaderIdentifier                            = "Teammate Header"
        static let CollectionCellWidth: CGFloat                = 100.0
        
        static let CollectionCellMinimumItemSpacing: CGFloat   = 10.0
        static let CollectionViewMinimumMarginSpacing: CGFloat = 20.0
        
        static let CollectionViewMinimumLineSpacing: CGFloat   = 40.0
        static let CollectionViewTopMarginSpacing: CGFloat     = 20.0
    }
    
    // MARK: Inited in the prepareForSegue()
    var projectID: String!
    var groupSize: Int!
    weak var icvc: InvitationContainerViewController!
    
    var project: Project!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        project = CoreDataManager.sharedInstance.project(projectID)
        retrieveTeammate()
    }
    
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

    func retrieveTeammate() {
        ContentManager.sharedInstance.teammateList(project.course_id, projectID: project.project_id) {
            (teammateList, error) in
            self.teammateList = teammateList
            self.updateStage()
            
            self.animationDidEnd()
        }
    }
    
    func updateStage() {
        if icvc.teammates.count == icvc.groupSize {
            icvc.currentStage = 2
        }
    }
}

// MARK: UICollectionViewDataSource
extension TeammateViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teammateList.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifier, forIndexPath: indexPath) as! TeammateCollectionViewCell
        let teammate = teammateList[indexPath.row]
        let selected = icvc.teammates.indexOf {
            return $0.encryptID == teammate.encypted_id
        } != nil
        cell.setupWithName(teammate.name, realName: teammate.realName, selected: selected)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.HeaderIdentifier, forIndexPath: indexPath) as! TeammateCollectionViewHeader
            header.setupWithCurrent(icvc.teammates.count, groupSize: groupSize)
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: UICollectionViewDelegate
extension TeammateViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // update data
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TeammateCollectionViewCell
        let teammate = teammateList[indexPath.row]
        if cell.shouldShowImageView {
            if let index = icvc.teammates.indexOf({
                return $0.encryptID == teammate.encypted_id
            }) {
                icvc.teammates.removeAtIndex(index)
            }
        } else {
            guard
                icvc.teammates.indexOf({return $0.encryptID == teammate.encypted_id}) == nil,
                let groupSize = icvc.groupSize where groupSize > icvc.teammates.count
            else {return}
            icvc.teammates.append((teammate.name, teammate.realName, teammate.encypted_id))
        }
        // update cell
        cell.toggleImageView()
        // update header
        let header = collectionView.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! TeammateCollectionViewHeader
        header.setupWithCurrent(icvc.teammates.count, groupSize: groupSize)
        // update stage
        updateStage()
    }
}

extension TeammateViewController: UICollectionViewDelegateFlowLayout {
    
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

// MARK: RefreshControlHook
extension TeammateViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveTeammate()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

class TeammateCollectionViewCell: UICollectionViewCell {

    var shouldShowImageView = false
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stuNoLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    func setupWithName(name: String, realName: String, selected: Bool) {
        avatarView.capital = realName
        nameLabel.text = realName
        stuNoLabel.text = name
        
        if selected {
            selectedImageView.alpha = 1.0
            selectedImageView.transform = CGAffineTransformIdentity
        } else {
            selectedImageView.alpha = 0.0
            selectedImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
        }
        shouldShowImageView = selected
    }
    
    func toggleImageView() {
        if shouldShowImageView {
            UIView.animateWithDuration(0.5, animations: {
                self.selectedImageView.alpha = 0.0
                self.selectedImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
                self.userInteractionEnabled = false
            }) {
                [weak self] in
                if $0 {
                    self?.userInteractionEnabled = true
                }
            }
        } else {
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: {
                self.selectedImageView.alpha = 1.0
                self.selectedImageView.transform = CGAffineTransformIdentity
                self.userInteractionEnabled = false
                }) {
                    [weak self] in
                    if $0 {
                        self?.userInteractionEnabled = true
                    }
            }
        }
        shouldShowImageView = !shouldShowImageView
    }
    
}

class TeammateCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var groupSizeLabel: UILabel!
    
    func setupWithCurrent(current: Int, groupSize: Int) {
        currentLabel.text = "\(current)"
        groupSizeLabel.text = "\(groupSize)"
    }
}