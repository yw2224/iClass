//
//  FileManager.swift
//  SmartClass
//
//  Created by PengZhao on 15/7/16.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import UIKit
import CocoaLumberjack

/// The FileManager is for later extension dealing with avatars
class FileManager: NSObject {
    
    private struct Constants {
        static let ImageCache = "Image Cache"
    }
    
    class func imageCacheOfName(name: String) -> UIImage? {
        if let data = dataForFileName(Constants.ImageCache, name: name) {
            return UIImage(data: data)
        }
        return nil
    }
    
    class func saveImageOfName(image: UIImage, quality: CGFloat, name: String, override: Bool) {
        guard let data = UIImageJPEGRepresentation(image, quality) else {
            DDLogError("JPEG represent failed")
            return
        }
        saveDataOfFileName(data, folder: Constants.ImageCache, name: name, override: override)
    }
    
    // if file doesn't exist or any error happens
    private class func dataForFileName(folder: String, name: String) -> NSData? {
        let path = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) ).first!
        let manager = NSFileManager.defaultManager()
        guard let filePath = NSURL(fileURLWithPath: path)
                .URLByAppendingPathComponent(folder)
                .URLByAppendingPathComponent(name).path else {return nil}
        
        if manager.fileExistsAtPath(filePath) {
            return NSData(contentsOfFile: filePath)
        }
        return nil
    }
    
    private class func saveDataOfFileName(data: NSData, folder: String, name: String, override: Bool) -> Bool {
        let cachePath = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)).first!
        let url = NSURL(fileURLWithPath: cachePath).URLByAppendingPathComponent(folder)
        let manager = NSFileManager.defaultManager()
        guard let folderPath = url.path else {return false}
        guard let filePath = url.URLByAppendingPathComponent(name).path else {return false}
        
        do {
            if !manager.fileExistsAtPath(folderPath) {
              try manager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
            }
            if !manager.fileExistsAtPath(filePath) || override {
                return data.writeToFile(filePath, atomically: true)
            }
            return true
        } catch let error {
            DDLogError("save file data error: \(error)")
            return false
        }
    }
}
