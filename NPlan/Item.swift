//
//  Item.swift
//  NPlan
//
//  Created by HUANG SONG on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
