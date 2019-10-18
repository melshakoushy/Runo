//
//  Location.swift
//  Runo
//
//  Created by Mahmoud Elshakoushy on 10/14/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    @objc dynamic public private(set) var longitude = 0.0
    @objc dynamic public private(set) var latitude = 0.0
    
    convenience init(longitude: Double , latitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
