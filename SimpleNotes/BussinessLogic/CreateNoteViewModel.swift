//
//  CreateNoteViewModel.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation
import Combine

final class CreateNoteViewModel {
    
    public enum Event {
        case done
        case stateChange(note: Note?, title: String, body: String)
        case back
    }
    
    public enum Action {
        case save(title: String, body: String)
        case updateState(note: Note?, title: String, body: String)
    }
    
    let repository: NotesRepository
    let note: Note?
    var savedAppState: AppState?
    
    var subscriptions = Set<AnyCancellable>()
    
    public let events = PassthroughSubject<Event, Never>()
    public let actions = PassthroughSubject<Action, Never>()
    
    public var isCreateNote: Bool {
        return note == nil
    }
    
    init(repository: NotesRepository, note: Note?) {
        self.repository = repository
        self.note = note
        
        actions
            .sink { [unowned self] action in
                self.handleAction(action)
            }
            .store(in: &subscriptions)
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .save(let title, let body):
            if let note = note {
                repository.updateNote(id: note.id, title: title, body: body)
            } else {
                repository.insertNewNote(Note(title: title, body: body))
            }
            events.send(.done)
        case .updateState(note: let note, title: let title, body: let body):
            events.send(.stateChange(note: note, title: title, body: body))
        }
    }
}
