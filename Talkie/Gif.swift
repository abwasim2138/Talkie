//
//  Gif.swift
//  
//
//  Created by Abdul-Wasai Wasim on 3/15/16.
//
//

import Foundation
import CoreData
import FLAnimatedImage


class Gif: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imagePath: String, url: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Gif", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.imagePath = imagePath
        self.url = url
    }
    
    var gif: NSData? {
        get {
        return ImageMemory.retrieveGif(imagePath!)
        }set{
            CoreDataStackManager.singleton.managedObjectContext.performBlock { () -> Void in
                guard let iP = self.imagePath else {
                    return
                }
             ImageMemory.saveGif(newValue, pathComponent: iP)
            }
           
        }
    }
    
    override func prepareForDeletion() {
        ImageMemory.deleteGif(self.imagePath!)
    }
}
