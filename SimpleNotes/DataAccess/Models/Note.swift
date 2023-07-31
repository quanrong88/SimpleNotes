//
//  Note.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation

class Note: Codable, Identifiable {
  var id = UUID()
  var title: String
  var body: String
  var date = Date()
  var pinned: Bool = false

  init(title: String, body: String) {
    self.title = title
    self.body = body
  }

  deinit {
    print("\(self.title) (\(self.id)) deleted")
  }
}

extension Note: Comparable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func <(lhs: Note, rhs: Note) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func >(lhs: Note, rhs: Note) -> Bool {
        return lhs.date > rhs.date
    }
}
