//
//  ReminderItem.swift
//  Remindy
//
//  Created by Priit Pärl on 02/03/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import Foundation
import RealmSwift

class ReminderItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "reminderItems")
}
