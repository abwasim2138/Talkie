//
//  Gif+CoreDataProperties.swift
//  
//
//  Created by Abdul-Wasai Wasim on 3/15/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Gif {

    @NSManaged var url: String?
    @NSManaged var imagePath: String?

}
