//
//  NotesRepository.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation

final class NotesRepository {
    var notes: [Note]
    
    init() {
      self.notes = UserDefaults.standard.load(key: DefaultKeys.NOTES_KEY, obj: [Note].self) ?? [Note]()
      notes.forEach { print("Note loaded: \($0.title)") }
    }
    
    var pinnedNotes: [Note] { notes.filter { $0.pinned } }
    var notPinnedNotes: [Note] { notes.filter { !$0.pinned } }
    
    public func storeToLocal() {
      UserDefaults.standard.save(key: DefaultKeys.NOTES_KEY, obj: notes)
    }
    
    public func insertNewNote(_ note: Note) {
        notes.append(note)
        storeToLocal()
    }
    
    public func updateNote(id: UUID, title: String, body: String) {
        guard let note = notes.first(where: { item in
            return item.id == id
        }) else {
            return
        }
        
        note.title = title
        note.body = body
        storeToLocal()
    }
    
    public func deleteNote(id: UUID) {
        notes.removeAll(where: { $0.id == id })
        storeToLocal()
    }
    
    public func pinNote(id: UUID) {
        guard let note = notes.first(where: { item in
            return item.id == id
        }) else {
            return
        }
        note.pinned = true
        storeToLocal()
    }
    
    public func unpinNote(id: UUID) {
        guard let note = notes.first(where: { item in
            return item.id == id
        }) else {
            return
        }
        note.pinned = false
        storeToLocal()
    }
}
