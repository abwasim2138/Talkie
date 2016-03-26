//
//  UserSettings.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/26/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation
import MapKit

private let SAVE_KEY = "save"

class UserSettings {
    
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    class func saveSettings(bool: Bool) {
        userDefaults.setObject(bool, forKey: SAVE_KEY)
    }
    
    class func getSettings()-> Bool? {
        if let settings = userDefaults.objectForKey(SAVE_KEY) as? Bool {
            return settings
        }else{
            return nil
        }
    }
}