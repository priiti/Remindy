//
//  ReminderItem.swift
//  Remindy
//
//  Created by Priit Pärl on 19/02/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import Foundation

class ReminderItem: Codable {
    var title: String = ""
    var done: Bool = false
    
    init(title: String) {
        self.title = title
    }
}
