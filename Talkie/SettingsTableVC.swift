//
//  SettingsTableVC.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/26/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var saveSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let bool = UserSettings.getSettings() {
            saveSwitch.setOn(bool, animated: true)
        }
    }

  
    @IBAction func autoSaveOn(sender: UISwitch) {
        UserSettings.saveSettings(sender.on)
    }
}
