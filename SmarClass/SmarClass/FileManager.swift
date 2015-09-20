//
//  FileManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit

class FileManager: NSObject {
    
    private struct Constants {
        static let ImageCache = "Image Cache"
    }
    
    class func imageCacheOfName(name: String) -> UIImage? {
        let data = dataForFileName(Constants.ImageCache, name: name)
        if let theData = data {
            let image = UIImage(data: theData)
            return image
        }
        return nil
    }
    
    class func saveImageOfName(image: UIImage, quality: CGFloat, name: String, override: Bool) {
        let data = UIImageJPEGRepresentation(image, quality)
        saveDataOfFileName(data, folder: Constants.ImageCache, name: name, override: override)
    }
    
    // if file doesn't exist or any error happens
    private class func dataForFileName(folder: String, name: String) -> NSData? {
        var path = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) ).first!
        path = path.stringByAppendingPathComponent(folder)
                   .stringByAppendingPathComponent(name)
        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(path) {
            let data = NSData(contentsOfFile: path)
            return data
        }
        return nil
    }
    
    private class func saveDataOfFileName(data: NSData, folder: String, name: String, override: Bool) {
        var path = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) ).first!
        path = path.stringByAppendingPathComponent(folder)
        let manager = NSFileManager.defaultManager()
        // create directory
        if (!manager.fileExistsAtPath(path)) {
            var error:  NSError?
            if !manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil) || error != nil {
                return
            }
        }
        path = path.stringByAppendingPathComponent(name)
        if !manager.fileExistsAtPath(path) || override {
            data.writeToFile(path, atomically: true)
        }
    }
}
