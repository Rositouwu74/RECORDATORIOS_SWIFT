//
//  Reminder.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 31/10/24.
//

import Foundation

struct Reminder: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var tag: String
    var date: Date?
    var time: Date?
    var deletedAt: Date? // Nueva propiedad para trackear cuando fue borrado
    var isDeleted: Bool // Nueva propiedad para marcar si está borrado
    
    init(text: String, tag: String, date: Date? = nil, time: Date? = nil) {
        self.text = text
        self.tag = tag
        self.date = date
        self.time = time
        self.deletedAt = nil
        self.isDeleted = false
    }
}

