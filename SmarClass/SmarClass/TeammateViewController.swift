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
        static let CollectionCellWidth: CGFloat                = 100.0
        
        static let CollectionCellMinimumItemSpacing: CGFloat   = 20.0
        static let CollectionViewMinimumMarginSpacing: CGFloat = 20.0
        
        static let CollectionViewMinimumLineSpacing: CGFloat   = 40.0
        static let CollectionViewTopMarginSpacing: CGFloat     = 20.0
    }
    
    var projectID: String!
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
            
            self.animationDidEnd()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Teammate Cell", forIndexPath: indexPath) as! TeammateCollectionViewCell
        let teammate = teammateList[indexPath.row]
        cell.setupWithName(teammate.name, realName: teammate.realName, id: teammate.encypted_id)
        return cell
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
    
    var id: String!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stuNoLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    func setupWithName(name: String, realName: String, id: String) {
        avatarView.capital = realName
        nameLabel.text = realName
        stuNoLabel.text = name
        self.id = id
    }
    
}