//
//  Talkie.swift
//  
//
//  Created by Abdul-Wasai Wasim on 3/15/16.
//
//

import Foundation
import CoreData
import UIKit
import FLAnimatedImage


class Talkie: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(shareURL: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Talkie", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
 
        
        self.shareURL = shareURL
        
    }
    
    
    var gif: NSURL? {
        get {
            let path = ImageMemory.makePath(self.shareURL!)
            let u = NSURL(fileURLWithPath: path)
            return u
        }
        set {
            CoreDataStackManager.singleton.managedObjectContext.performBlock {
                let d = NSData(contentsOfURL: newValue!)
                ImageMemory.saveGif(d, pathComponent: self.shareURL!)
            }
            
        }
    }
    
    
    override func prepareForDeletion() {
        ImageMemory.deleteGif(self.shareURL!)
    }

}
