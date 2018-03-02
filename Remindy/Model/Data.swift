//
//  Data.swift
//  Remindy
//
//  Created by Priit Pärl on 02/03/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}

