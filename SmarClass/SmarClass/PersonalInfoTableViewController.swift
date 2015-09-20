//
//  PersonalInfoTableViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/20.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PersonalInfoTableViewController: UITableViewController {
	private struct InnerConstants {
		static let cellIdentifiers = [
			0:"avatarCell",
			1:"usernameCell",
			2:"realnameCell",
			3:"notificationCell",
			4:"passwordCell"
		]
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
    }


	@IBAction func unwindToPersonalInfoPage(sender:UIStoryboardSegue){
	//do nothing
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 5
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InnerConstants.cellIdentifiers[indexPath.row]!, forIndexPath: indexPath) 

		switch indexPath.row {
		case 0:
			return cell as! AvatarCell
		case 1:
			let usernameCell = cell as! UsernameCell
			usernameCell.usernameLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
			return cell as! UsernameCell
		case 2:
			let realnameCell = cell as! RealnameCell
			realnameCell.realnameLabel.text = NSUserDefaults.standardUserDefaults().valueForKey("realname") as? String
			return cell as! RealnameCell
		case 3:
			let ncell = cell as! NotificationCell
			ncell.notificationNumberLabel.text = "1"
			return cell as! NotificationCell
		case 4:
			return cell as! PasswordCell
		default:
			return cell
		}

    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RealnameCell {
			showChangeRealNameAlertView(cell)
		}

	}
	func showChangeRealNameAlertView(cell:RealnameCell){
		var alert = UIAlertController(
			title: "修改真实姓名", message: "请输入真实姓名", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addTextFieldWithConfigurationHandler
			{ (textField:UITextField!) -> Void in
				textField.placeholder="请输入真实姓名"
				textField.borderStyle = UITextBorderStyle.RoundedRect
				textField.clearButtonMode = UITextFieldViewMode.WhileEditing
				NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("alertTextFieldDidChange:"), name: UITextFieldTextDidChangeNotification, object: nil)
		}
		var action = UIAlertAction(
			title: "确定",
			style: UIAlertActionStyle.Default)
			{ (action:UIAlertAction) -> Void in
				if let textfield = alert.textFields?.first as? UITextField{
					let realname = textfield.text
					self.modifyRealName(realname)
				}
		}
		alert.addAction(UIAlertAction(
			title: "取消",
			style: UIAlertActionStyle.Cancel,
			handler: { (action:UIAlertAction) -> Void in
				//do nothing
		}))
		alert.addAction(action)
		self.presentViewController(alert, animated: true) { () -> Void in
			//do nothing
		}
	}
	func modifyRealName(realname:String){
//		SCRequest.changeRealName(realname, completionHandler:
//			{ (_, _, JSON, _) -> Void in
//				println(JSON)
//				if (JSON?.valueForKey("result") as? Bool) == true {
//					NSUserDefaults.standardUserDefaults().setValue(realname, forKey: "realname")
//					self.tableView.reloadData()
//				}
//		})
	}
	
	func alertTextFieldDidChange(notification:NSNotification){
		if let alert = self.presentedViewController as? UIAlertController {
			if let textfield = alert.textFields?.first as? UITextField {
				
			}
		}
	}
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

}


class AvatarCell:UITableViewCell{
	
	@IBOutlet weak var avatar: UIImageView!
}

class UsernameCell : UITableViewCell {
	
	@IBOutlet weak var usernameLabel: UILabel!
}

class RealnameCell : UITableViewCell {
	
	@IBOutlet weak var realnameLabel: UILabel!
}

class NotificationCell : UITableViewCell {
	
	@IBOutlet weak var notificationNumberLabel: UILabel!
}

class PasswordCell : UITableViewCell {
	
}








