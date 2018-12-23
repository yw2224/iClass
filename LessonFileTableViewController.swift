//
//  LessonFileTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/12/23.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class LessonFileTableViewController: CloudAnimateTableViewController {

    var lessonID: String!
    var lessonName: String!
    var courseID: String!
    
    var lessonFileList = [File]() {
        didSet {
            tableView.reloadData()
        }
    }
    override var emptyTitle: String {
        get {
            return "没有课时资料，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Lesson File Cell"
        static let LessonCellHeight: CGFloat = 66.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "资料"
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        retrieveLessonFileList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return lessonFileList.count
    }
    
    func retrieveLessonFileList() {
        print("my courseID:")
        print(courseID)
        print(lessonName)
        print(lessonID)
        
        ContentManager.sharedInstance.lessonFileInfo(ContentManager.UserID, token: ContentManager.Token, courseID: self.courseID, lessonID: lessonID , lessonName: lessonName) {
            (lessonFileList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            //print("lessonFileList here:")
            //print(lessonFileList)
            self.lessonFileList = lessonFileList
            self.animationDidEnd()
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Lesson File Cell") as! LessonFileTableViewCell
        
        let file = lessonFileList[indexPath.row]
        cell.setupWithFileName(file.fileName!, userName: file.userName!)
        return cell
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Content Segue"
        {
            if let dest = segue.destinationViewController as? ImageViewController
            {
                let indexPath = tableView.indexPathForSelectedRow!
                let lessonFile = lessonFileList[indexPath.row]
                dest.url = "http://" + lessonFile.url!
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        performSegueWithIdentifier("Show Content Segue", sender: self)
    }
}

extension LessonFileTableViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveLessonFileList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

class LessonFileTableViewCell: UITableViewCell {
   
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    func setupWithFileName(fileName: String, userName: String) {
        fileNameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        fileNameLabel.text = fileName
        userNameLabel.text = userName
    }
}
