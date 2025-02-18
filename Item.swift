//
//  Item.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 30/10/24.
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
