//
//  PersonalInfoViewController.swift
//  SmartClass
//
//  Created by PengZhao on 15/5/20.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UIViewController {

	@IBOutlet weak var personalTableVIew: UITableView!{
		didSet{
//			personalTableVIew.delegate = self
//			personalTableVIew.dataSource = self
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

//extension PersonalInfoViewController : UITableViewDataSource{
//	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		return 1
//	}
//	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 0
//	}
//	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		return nil
//	}
//}
//extension PersonalInfoViewController:UITableViewDelegate{
//	
//}
