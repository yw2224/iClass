//
//  LessonTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2016/12/18.
//  Copyright © 2016年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class LessonTableViewController: CloudAnimateTableViewController {

    var courseID : String!
    var lessonList = [Lesson]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override var emptyTitle: String {
        get {
            return "没有课程内容，请下拉以刷新。"
        }
    }
    
    private struct Constants {
        static let CellIdentifier = "Lesson Cell"
        static let LessonCellHeight: CGFloat = 66.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "内容"
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        retrieveLessonList()
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
    
    func block(_: NetworkErrorType?) -> Void {
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*guard
            let cell = sender as? LessonTableViewCell,
            let indexPath = tableView.indexPathForCell(cell) where indexPath.row >= 0 && indexPath.row < lessonList.count,
            let dest = segue.destinationViewController as? LessonFileTableViewController else {return}*/
        if segue.identifier == "Show Lesson File Segue"
        {
            if let dest = segue.destinationViewController as? LessonFileTableViewController
            {
                let indexPath = tableView.indexPathForSelectedRow!
                let lesson = lessonList[indexPath.row]
                dest.lessonID = lesson.lessonID?.stringValue
                dest.lessonName = lesson.lessonName
                dest.courseID = courseID
                //dest.lessonFileList = CoreDataManager.sharedInstance.lessonFileList(lesson.lessonName!)*/
                //print("dest.lessonID:")
                //print(dest.lessonID)
            }
        }
        
        
    }
    
    func retrieveLessonList() {
        ContentManager.sharedInstance.lessonInfo(ContentManager.UserID, token: ContentManager.Token, courseID: courseID) {
            (lessonList, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            print("lessonList here:")
            print(lessonList)
            self.lessonList = lessonList
            self.animationDidEnd()
        }
    }

    
 /*
    func block(_: NetworkErrorType?) -> Void {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContentManager.sharedInstance.lessonInfo(ContentManager.UserID, token: ContentManager.Token, courseID: courseID, block: block)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
 */

    // MARK: - Table view data source


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
extension LessonTableViewController {
    
    override func animationDidStart() {
        super.animationDidStart()
        
        // Remember to call 'animationDidEnd' in the following code
        retrieveLessonList()
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
}

// MARK: UITableViewDataSource
extension LessonTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Lesson Cell") as! LessonTableViewCell
        let lesson = lessonList[indexPath.row]
        cell.setupWithLessonName(lesson.lessonName!, lessonID: lesson.lessonID!)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //let cell = tableView.dequeueReusableCellWithIdentifier("Lesson Cell") as! LessonTableViewCell
        let lessonID = lessonList[indexPath.row].lessonID!.stringValue
        let lessonName = lessonList[indexPath.row].lessonName
        
        //ContentManager.sharedInstance.lessonFileInfo(ContentManager.UserID, token: ContentManager.Token, courseID: self.courseID, lessonID: lessonID , lessonName: lessonName, block: block)
        performSegueWithIdentifier("Show Lesson File Segue", sender: self)
    }
}

// MARK: UITableViewDelegate
extension LessonTableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.LessonCellHeight
    }
}

class LessonTableViewCell: UITableViewCell {

    @IBOutlet weak var lessonIDLabel: UILabel!
    @IBOutlet weak var lessonNameLabel: UILabel!
    
    func setupWithLessonName(lessonName: String, lessonID: NSNumber) {
        lessonNameLabel.text = lessonName
        lessonIDLabel.text = lessonID.stringValue
    }
}
