//
//  GifCollectionViewController.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/15/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit
import FLAnimatedImage


private let reuseIdentifier = "Cell"

class GifCollectionViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, AVPlayerViewControllerDelegate, UISearchBarDelegate {

    //MARK: - Properties 
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    
    //CITE: COLOR COLLECTION
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    var indexP: [NSIndexPath]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         setUpUI()
         searchBar.delegate = self
         getGifs()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if tabBarController?.selectedIndex == 0 {
        self.tabBarController?.selectedIndex = 1
        }
    }
    
    
    func setUpUI() {
        let size = (view.frame.size.width / 2.0)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.itemSize = CGSizeMake(size, size)
        
        
        //CITE: http://stackoverflow.com/questions/33390726/change-uisearchbar-text-color-in-ios-9
        let sBar = searchBar.valueForKey("searchField") as? UITextField
        sBar?.textColor = UIColor.whiteColor()
    }
    
    //MARK: - CoreData 
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return CoreDataStackManager.singleton.managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Gif")
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller

    }()
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Move: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
       collectionView.performBatchUpdates({
        
        for indexPath in self.insertedIndexPaths {
            self.collectionView.insertItemsAtIndexPaths([indexPath])
        }
        for indexPath in self.deletedIndexPaths {
            self.collectionView.deleteItemsAtIndexPaths([indexPath])
        }
        for indexPath in self.updatedIndexPaths {
            self.collectionView.reloadItemsAtIndexPaths([indexPath])
        }
        
        }, completion: nil)
        
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEdit" {
            if let indexPath = self.collectionView.indexPathsForSelectedItems() {
            let editVC = segue.destinationViewController as! TalkiePlayerViewController
            let selectedGif = fetchedResultsController.objectAtIndexPath(indexPath[0]) as! Gif
            editVC.gif = selectedGif.url!
            }
        }
    }


    // MARK: UICollectionViewDataSource


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let gif = fetchedResultsController.objectAtIndexPath(indexPath) as! Gif
        configureCell(cell, gif: gif)
    
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, gif: Gif?) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        dispatch_async(dispatch_get_main_queue()) {
            cell.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            var iP: String?
            var imageHolder: NSData?
            self.managedObjectContext.performBlockAndWait({
                imageHolder = gif?.gif
            })
            if let gif = imageHolder {
                dispatch_async(dispatch_get_main_queue(), {
                //CITE: https://github.com/Flipboard/FLAnimatedImage
                let gifImage = FLAnimatedImage(animatedGIFData: gif)
                let imageView = FLAnimatedImageView()
                imageView.frame.size = cell.frame.size
                imageView.contentMode = .ScaleAspectFill
                imageView.animatedImage = gifImage
                cell.addSubview(imageView)
                activityIndicator.removeFromSuperview()
                })
            }else {
                self.managedObjectContext.performBlockAndWait({
                    iP = gif?.imagePath
                })
            }
            guard let string = iP else {
                return
            }
            
            guard let data = NSData(contentsOfURL: NSURL(string: string)!) else {
                return
            }
            let gifImage = FLAnimatedImage(animatedGIFData: data)
            let imageView = FLAnimatedImageView(frame: CGRect(x: 0, y: 0, width: gifImage.size.width, height: gifImage.size.height))
            imageView.animatedImage = gifImage
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            gif!.gif = gifImage.data
            dispatch_async(dispatch_get_main_queue(), {
                cell.addSubview(imageView)
                activityIndicator.removeFromSuperview()
            })
        }
        
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showEdit", sender: self)
    }
    

    //MARK: SEARCHBAR
    
    func getSearchWord()->String {
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchWord = strippedString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        return searchWord
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchGifs(getSearchWord())
        searchBar.resignFirstResponder()
    }
    
    func searchGifs (searchWord: String) {
        deleteGifs()
        GiphyClient.getGifs(searchWord) { (images, error) -> Void in
            
            guard error == nil && images != [] else {
                let message: String
                if error == nil {
                    message = "NO RESULTS"
                }else{
                    message = error!.localizedDescription
                }
                let aVC = UIAlertController(title: "Errrrr", message: message, preferredStyle: .Alert)
                let action = UIAlertAction(title: "GOT IT", style: .Default, handler: nil)
                aVC.addAction(action)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(aVC, animated: true, completion: nil)
                })
                return
            }
            
            
            self.managedObjectContext.performBlock({
            for image in images {
                let vid = image.stringByReplacingOccurrencesOfString(".gif", withString: ".mp4")
                let _ = Gif(imagePath: image, url: vid, context: self.managedObjectContext)
    
            }
            CoreDataStackManager.singleton.saveContext()
            self.collectionView.reloadData()   
            })
            
        }
    }
    
    func deleteGifs () {
        
        for object in fetchedResultsController.fetchedObjects! {
            managedObjectContext.deleteObject(object as! NSManagedObject)
        }
        CoreDataStackManager.singleton.saveContext()
    }
    
    func getGifs() {
        do {
            try fetchedResultsController.performFetch()
        }catch let error as NSError { 
            print("ERROR IN RETRIEVING GIFS \(error.localizedFailureReason)")
        }
        self.fetchedResultsController.delegate = self
    }
    
    
    //MARK: - IBActions 
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        
        if searchBar.text != "" {
        searchGifs(getSearchWord())
        }
    }
    




}
