//
//  ImageMemory.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/15/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

class ImageMemory {
    
    
    class func retrieveGif(pathComponent: String)->NSData? {
     
        let path = makePath(pathComponent)
        
        if let data = NSData(contentsOfFile: path) {
            return data
           
        }
        return nil
    }
    

    class func saveGif (data: NSData?, pathComponent: String) {
        let path: String!
        if pathComponent.containsString(".mov") == false {
        path = makePath(pathComponent)
        }else{
        path = pathComponent
        }
        do {
            try data!.writeToFile(path, options: .AtomicWrite)
        }catch let error as NSError {
            print("ERROR IN SAVING \(error.localizedDescription)")
        }
    }
    
    class func deleteGif (pathComponent: String) {
        
        let path = makePath(pathComponent)
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch let error as NSError {
                print("ERROR IN DELETING GIF \(error.localizedFailureReason)")
            }
        }else{
            print("FILE DOES NOT EXIST")
        }
    }
    
    class func makePath(pathComponent: String)-> String {
        var eIndex = pathComponent.startIndex.advancedBy(30)
        if pathComponent.containsString(".mov") {
            eIndex = pathComponent.rangeOfString("//")!.startIndex
        }
        let range = Range(pathComponent.startIndex..<eIndex)
        let ranger = pathComponent.stringByReplacingCharactersInRange(range, withString: "")
        let r = ranger.stringByReplacingOccurrencesOfString("/giphy", withString: "")
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let path = documentsDirectoryURL.URLByAppendingPathComponent(r)
        return path.path!
    }

}