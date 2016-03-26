//
//  TalkiePlayerViewController.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/11/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices
import AssetsLibrary
import Photos

class TalkiePlayerViewController: AVPlayerViewController, AVAudioRecorderDelegate {

    var gif = String()
    private var recorder: AVAudioRecorder?
    private var newTalkie: NSURL?
    private var composition: AVMutableComposition?
    private let session = AVAudioSession.sharedInstance()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.player = AVPlayer(URL: NSURL(string: gif)!)

        addSwiper(.Up, selector: #selector(TalkiePlayerViewController.recordSound))
        addSwiper(.Down, selector: #selector(TalkiePlayerViewController.cancel))
    
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TalkiePlayerViewController.playerDidEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if self.composition != nil {
        prepareForSharing()
        }
    }
    
    func addSwiper(direction: UISwipeGestureRecognizerDirection, selector: Selector) {
        let swiper = UISwipeGestureRecognizer(target: self, action: selector)
        swiper.direction = direction
        self.view.addGestureRecognizer(swiper)
    }

    func cancel () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func recordSound () {
        
        //CITE: PITCH_PERFECT
        view.backgroundColor = UIColor.grayColor()
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recording.wav"
        let pathArray = [dirPath,recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        session.requestRecordPermission { (success) -> Void in
            
            if success {
                do {
                    try self.session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
                    do {
                        try self.session.setActive(true)
             
                        let settings = [AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Max.rawValue))]
                        if let filePath = filePath {
                            do {
                                self.recorder = try AVAudioRecorder(URL: filePath, settings: settings)
                                self.recorder!.delegate = self
                                self.recorder!.meteringEnabled = true
                                self.recorder!.prepareToRecord()
                                self.recorder!.record()
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.player?.seekToTime(kCMTimeZero)
                                    self.player?.play()
                                })
                                
                            }catch let error as NSError{
                                print("error in recording audio \(error.localizedDescription)")
                            }
                        }
                    }catch{
                        print("error in settingActive")
                    }
                }catch{
                    print("error in settingSession")
                }
            }else{
                print("ERROR")
            }
        }
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
           combineAudioWithGif(recorder.url)
        }
    }
    
    func playerDidEnd () {
        self.recorder?.stop()
        view.backgroundColor = UIColor.blackColor()
    }
    
    private func combineAudioWithGif(audio: NSURL) {
        let videoAsset = AVAsset(URL: NSURL(string: gif)!)
        let audioAsset = AVAsset(URL: audio)
        let composition = AVMutableComposition()
        let video = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        do {
            try video.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo).first!, atTime: CMTime(seconds: 4.0, preferredTimescale: CMTimeScale()))
        }catch let error as NSError {
            print(error)
        }
        
        let audio = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audio.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio).first!, atTime: kCMTimeZero)
        }catch let error as NSError {
            print(error)
        }
        let item = AVPlayerItem(asset: composition)
        self.player = AVPlayer(playerItem: item)
        self.composition = composition
        
    }
    
    func prepareForSharing() {
        
        //CITE: https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html  // https://www.raywenderlich.com/94404/play-record-merge-videos-ios-swift
        
        let kDateFormatter = NSDateFormatter()
        kDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let exporter = AVAssetExportSession(asset: composition!, presetName: AVAssetExportPresetHighestQuality)!
        
        if let pathExtension = UTTypeCopyPreferredTagWithClass(AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension) {
            
            let range = Range(gif.startIndex..<gif.startIndex.advancedBy(30))
            let ranger = gif.stringByReplacingCharactersInRange(range, withString: "")
            let r = ranger.stringByReplacingOccurrencesOfString("/giphy.mp4", withString: "")

            exporter.outputURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).URLByAppendingPathComponent("\(r)\(kDateFormatter.stringFromDate(NSDate()))").URLByAppendingPathExtension(pathExtension.takeRetainedValue() as String)
        
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = AVVideoComposition(propertiesOfAsset: composition!)
            exporter.exportAsynchronouslyWithCompletionHandler({
                dispatch_async(dispatch_get_main_queue(), {
                    switch exporter.status {
                    case .Completed:
                        
                        self.newTalkie = exporter.outputURL!
                    
                        self.saveTalkie()
                       
                    case .Failed:
                        print("EXPORT FAILED")
                    default:
                        print("EXPORT DEFAULT")
                    }
                })
            })
            
        }

    }
    
    
    
    func saveTalkie () {
        if let newTalkie = newTalkie {
            
            CoreDataStackManager.singleton.managedObjectContext.performBlock({
            let o = Talkie(shareURL: newTalkie.path!, context: CoreDataStackManager.singleton.managedObjectContext)
            o.gif = newTalkie
            CoreDataStackManager.singleton.saveContext()
            })

        //SAVE TO PHOTOS LIBRARY
        if let shouldSave = UserSettings.getSettings() {
            guard shouldSave == true else {
                return
            }
    
        //CITE: https://developer.apple.com/library/ios/samplecode/UsingPhotosFramework/Listings/SamplePhotosApp_AAPLRootListViewController_m.html
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(newTalkie)
            }, completionHandler: { (success, error) in
                if success {
                    print("SUCCESS")
                }else {
                    print(error)
                }
        })
            }
        
        }
    }

}
