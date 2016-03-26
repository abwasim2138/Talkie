//
//  TalkieTableVC.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/25/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation


//CITE: VIRTUAL TOURIST
class TalkieTableVC: UITableViewController, NSFetchedResultsControllerDelegate {

    private var urlTalkie: NSURL!
    private var selectedCell: TalkieCell?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getTalkies()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TalkieCell
        
        let talkie = fetchedResultsController.objectAtIndexPath(indexPath) as! Talkie
        
        configureCell(cell, talkie: talkie)

        return cell
    }
    
    func configureCell(cell: TalkieCell, talkie: Talkie?) {

        dispatch_async(dispatch_get_main_queue()) {
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
        
            cell.alpha = 0.7
            var imageHolder: NSURL?
            self.managedObjectContext.performBlockAndWait({
                imageHolder = talkie?.gif
            })
            
            if let gif = imageHolder {
                let a = AVAsset(URL: gif)
                cell.url = gif
                let item = AVPlayerItem(asset: a)
                cell.addToPlayer(item)
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if selectedCell != nil {
            selectedCell?.alpha = 0.7
        }
        
       let cell = tableView.cellForRowAtIndexPath(indexPath) as! TalkieCell
        cell.player.seekToTime(kCMTimeZero)
        cell.player.play()
        cell.alpha = 1.0
        selectedCell = cell
        urlTalkie = cell.url
    }




    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return true
    }


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let talkie = fetchedResultsController.objectAtIndexPath(indexPath) as! Talkie
            managedObjectContext.deleteObject(talkie)
            CoreDataStackManager.singleton.saveContext()
        }
    }


    //MARK: - CoreData
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return CoreDataStackManager.singleton.managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Talkie")
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        
    }()
    

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Move: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        tableView.endUpdates()
        
    }
    
    
    func getTalkies() {
        do {
            try fetchedResultsController.performFetch()
        }catch let error as NSError {
            print("ERROR IN RETRIEVING GIFS \(error.localizedFailureReason)")
        }
        self.fetchedResultsController.delegate = self
    }

    
    @IBAction func shareTalkie(sender: UIBarButtonItem) {
        if let urlTalkie = urlTalkie {
            let activityController = UIActivityViewController(activityItems: [urlTalkie], applicationActivities: nil)
            activityController.completionWithItemsHandler = { (activity, success, array, error) in
                if success {
                    print("SUCESS")
                }
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.presentViewController(activityController, animated: true, completion: nil)
            })
 
        }
    }









}
