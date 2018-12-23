//
//  PostTableViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/5.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class Posts {
    var postingID: String = ""
    var postUserName: String = ""
    var title: String = ""
    var content: String = ""
    var postUserID: String = ""
    var like: NSNumber = 0
    var postDate: NSNumber = 0
    var img: String = ""
}

class PostTableViewController: CloudAnimateTableViewController {

    var postID: String!
    var courseID:String!
    var currentSeg:String!

    

    
    var temp = Posts()
    var post: Posts = Posts() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var replys: [Posts] = [Posts]() {
        didSet {
            tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrievePostDetail()
        var newPost: UIButton! = UIButton()
        self.createBarItem(newPost)

    }
    override var emptyTitle: String {
        get {
            return "该帖不存在。"
        }
    }
    
    @IBAction func newPostButtonTappedreply(sender: UIButton?) {
        
        performSegueWithIdentifier("replySegue", sender: sender)
    }
    
    private func createBarItem(newPost: UIButton) {
        newPost.setBackgroundImage(UIImage(named: "add"), forState: .Normal)
        newPost.sizeToFit()
        newPost.addTarget(self, action: "newPostButtonTappedreply:", forControlEvents: .TouchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: newPost)
        navigationItem.setRightBarButtonItem(barButtonItem, animated: true)
    }
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrievePostDetail() {
        self.replys.removeAll()
        ContentManager.sharedInstance.postDetail(ContentManager.UserID, token: ContentManager.Token, postID: postID) {
            (json, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            //var temp = Posts()
            //let str = json["posting_id"].string ?? ""
            self.temp.title = json["title"].string ?? ""
            self.temp.postingID = json["posting_id"].string ?? ""
            self.temp.postUserName = json["postUser_name"].string ?? ""
            self.temp.content = json["content"].string ?? ""
            self.temp.postUserID = json["postUser_id"].string ?? ""
            self.temp.like = json["like"].intValue ?? 0
            self.temp.postDate = json["postDate"].number ?? 0
            self.temp.img = json["img"].string ?? ""
            self.post = self.temp
            //self.replys.append(self.temp)
           
            let jsonArray: [JSON] = json["replys"].arrayValue
            for arrayElement in jsonArray {
                var tmp: Posts = Posts()
                tmp.postingID = arrayElement["reply_id"].string ?? ""
                tmp.postUserName = arrayElement["replyUser_name"].string ?? ""
                tmp.title = self.post.title
                tmp.content = arrayElement["content"].string ?? ""
                tmp.postUserID = arrayElement["replyUser_id"].string ?? ""
                tmp.like = arrayElement["like"].intValue ?? 0
                
                //let str1 = arrayElement["postDate"].string ?? ""
                tmp.postDate = arrayElement["postDate"].number!
                var timeSta:NSTimeInterval = tmp.postDate.doubleValue
                let datenow = NSDate(timeIntervalSince1970: timeSta/1000.0)
                let dformatter = NSDateFormatter()
                dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                print("\(dformatter.stringFromDate(datenow))")
                
                print("postdate = ")
                //print(tmp.postDate)
                print(timeSta)
                //print(hh)
                //print(date)

                self.replys.append(tmp)
            }

            print("self.postingID:" + self.post.postingID)
            print("self.title:" + self.post.title)
            print("self.content" + self.post.content)
            print("self.userID:" + self.post.postUserID)
            for reply in self.replys {
                print("self.postingID:" + reply.postingID)
                print("self.title:" + reply.title)
                print("self.content" + reply.content)
                print("self.userID:" + reply.postUserID)
            }
            //self.tableView.cel
            self.animationDidEnd()
        }
    }

    override func animationDidStart() {
        super.animationDidStart()
        retrievePostDetail()
        // Remember to call 'animationDidEnd' in the following code
        //retrieveExList(i)
    }
    
    override func animationDidEnd() {
        super.animationDidEnd()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowImageSegue"
        {
            print("success in here2")
            if let qvc = segue.destinationViewController as? showImaViewController
            {
                
                
                print("success in here1")
                var data: NSData? = NSData(base64EncodedString: self.temp.img, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                print(data)
                var image: UIImage? = UIImage(data: data!)
                //
                let imageView = UIImageView(image:image)
                imageView.frame = CGRect(x:40, y:200, width:300,height:300)
                //imageView.contentMode = .Center
                imageView.contentMode = .ScaleAspectFit
                qvc.view.addSubview( imageView )
                //qvc.ShowImage = imageView
            }
        }
            
        else if segue.identifier == "replySegue"
        {
            print("该回复啦")
            if  ((sender as? UIButton) != nil){
            if let dest = segue.destinationViewController as? ReplyViewController
            {
               dest.courseID = self.courseID
                dest.type = self.currentSeg
                dest.postingID = self.postID
            }
            }

        }
        
    }

    
    
}

extension PostTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
        case 0:
            return 1
        default:
            print("replys.count")
            print(replys.count)
            return replys.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("setting cell...")
        switch indexPath.section
        {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("Posts Cell", forIndexPath: indexPath) as! PostsTableViewCell
            cell.setupPostInfo(self.post.title, content: self.post.content, like: self.post.like, postDate: self.post.postDate, userID: self.post.postUserName, postID: self.post.postingID, type: "标题：", img: self.post.img, courseID: courseID)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            print("self title:")
            print(self.post.title)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Posts Cell", forIndexPath: indexPath) as! PostsTableViewCell
            let reply = replys[indexPath.row]
            cell.setupPostInfo(reply.title, content: reply.content, like: reply.like, postDate: reply.postDate, userID: reply.postUserName, postID: reply.postingID, type: "回复：",img: "",courseID: courseID)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section
        {
        case 0:
            let len = post.content.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) //=10
            let ret = CGFloat(Float(len))
            return ret + 200
        default:
            let reply = replys[indexPath.row].content
            let rLen = reply.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) //=10
            let rRet = CGFloat(Float(rLen))
            return rRet + 200
        }
        
    }
}

class PostsTableViewCell: UITableViewCell {

    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    //@IBOutlet weak var postIDLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var downloadImg: UIButton!

    
    @IBAction func preparedownload(sender: UIButton) {
        
        
    }
 
    var course_ID : String = ""
    var post_ID : String = ""
    var post_user_ID: String = ""


    @IBAction func love(sender: UIButton) {
        var likeString = likeLabel.text
        var likeNum: Int = Int(likeString!)!
        likeNum = likeNum + 1
        likeLabel.text = likeNum.description
        print(post_user_ID)
        
        
        ContentManager.sharedInstance.ShowMyLove(ContentManager.UserID, token: ContentManager.Token, postuser:post_user_ID,courseID: course_ID, postingID: post_ID, type: "posting"){
            (like, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    //self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
            
            
            
        }
    }
    
    
   
    
    func setupPostInfo(title: String, content: String, like: NSNumber, postDate: NSNumber, userID: String, postID: String, type: String,img:String,courseID:String) {
        
        let titleLen = lengthTrans(title)
        let contentLen = lengthTrans(content)
        let userIDLen = lengthTrans(userID)
        
        //titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.numberOfLines = 0;
        //contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        contentLabel.numberOfLines = 0;
        
        titleLabel.frame = CGRectMake(5, 5, titleLen + 50, titleLen + 60)
        contentLabel.frame = CGRectMake(5, 5, contentLen + 50, contentLen + 70)
        downloadImg!.setTitle("", forState: .Normal)
        //downloadImg!.setTitle("", forState: .Normal)
        if img != "" && type == "标题："{
            downloadImg!.setTitle("加载图片", forState: .Normal)
            //downloadImg!.layer.borderColor = UIColor.blueColor().CGColor
            downloadImg!.setTitleColor(UIColor(red: 138.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                , forState: .Normal)
            downloadImg!.setTitleColor(UIColor(red: 156.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0),forState:.Highlighted)
        }
        
        var timeSta:NSTimeInterval = postDate.doubleValue
        let datenow = NSDate(timeIntervalSince1970: timeSta/1000.0)
        let dformatter = NSDateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print(dformatter.stringFromDate(datenow))

        
        post_ID = postID
        course_ID = courseID
        post_user_ID = userID
        contentLabel.text = content
        titleLabel.text = type + title
        likeLabel.text = like.stringValue
        postDateLabel.text = dformatter.stringFromDate(datenow)
        userIDLabel.text = "作者：" + userID
        //postIDLabel.text = postID
    }
    
    func lengthTrans(str: String) -> CGFloat
    {
        let len = str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let tempLen = CGFloat(Float(len))
        return tempLen
    }
}

