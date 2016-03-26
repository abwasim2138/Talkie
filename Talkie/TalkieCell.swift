//
//  TalkieCell.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/16/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import AVFoundation

class TalkieCell: UITableViewCell {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var player: AVPlayer!
    var url: NSURL!
    
    func addToPlayer(aPI: AVPlayerItem) {
        self.player = AVPlayer(playerItem: aPI)
        let layer = AVPlayerLayer(player: self.player)
        layer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        dispatch_async(dispatch_get_main_queue(), {
          self.layer.addSublayer(layer)
          self.activityIndicator.stopAnimating()
          self.activityIndicator.hidden = true
        })
    }
    
}
