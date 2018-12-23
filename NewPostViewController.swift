//
//  NewPostViewController.swift
//  SmartClass
//
//  Created by W1 on 2017/1/5.
//  Copyright © 2017年 PKU. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func dismissKeyboard() {
        view.endEditing(true)
    }

    var courseID: String!
    var type: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let panGesture = UIPanGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
@IBAction func postphoto(sender: UIButton) {
        let actionSheet = UIAlertController(title: "上传头像", message: nil, preferredStyle: .ActionSheet)
        let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        
        let takePhotos = UIAlertAction(title: "拍照", style: .Destructive, handler: {
            (action: UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.delegate = self
                picker.allowsEditing = true
                self.presentViewController(picker, animated: true, completion: nil)
                
            }
            else
            {
                print("模拟其中无法打开照相机,请在真机中使用");
            }
            
        })
        let selectPhotos = UIAlertAction(title: "相册选取", style: .Default, handler: {
            (action:UIAlertAction)
            -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
        })
        actionSheet.addAction(cancelBtn)
        actionSheet.addAction(takePhotos)
        actionSheet.addAction(selectPhotos)
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        
        var photo_content: String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength);
        print(photo_content)
        
        let title = titleTextField.text
        let content = contentTextField.text
        
        ContentManager.sharedInstance.newPost(ContentManager.UserID, token: ContentManager.Token, name: ContentManager.UserName, courseID: self.courseID, title: title, content: content, postType: self.type,img:photo_content) {
            (newPost, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
        
        print("upload photo success")
        
        dismissViewControllerAnimated(true, completion: nil)
        //dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("BackToForumSegue", sender: self)
    }

   
    @IBAction func post(sender: UIButton) {
        let title = titleTextField.text
        let content = contentTextField.text
        
        print("postType:" + self.type)
        ContentManager.sharedInstance.newPost(ContentManager.UserID, token: ContentManager.Token, name: ContentManager.UserName, courseID: self.courseID, title: title, content: content, postType: self.type,img:"") {
            (newPost, error) in
            if let error = error {
                if case .NetworkUnauthenticated = error {
                    self.promptLoginViewController()
                } else if case .NetworkServerError = error {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.ProjectListRetrieveErrorPrompt)
                } else {
                    SVProgressHUD.showErrorWithStatus(GlobalConstants.RetrieveErrorPrompt)
                }
            }
        }
        
        performSegueWithIdentifier("BackToForumSegue", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BackToForumSegue"
        {
            if let dest = segue.destinationViewController as? ForumTableViewController
            {
                dest.courseID = courseID
                dest.currentSeg = type
            }

        }
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

