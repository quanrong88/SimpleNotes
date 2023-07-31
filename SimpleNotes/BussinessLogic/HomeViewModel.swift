//
//  HomeViewModel.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation
import Combine

struct NoteCellModel {
    let noteTitle: String
    let noteBody: String
    let noteDate: String
    let note: Note
    
    init(_ note: Note) {
        self.note = note
        self.noteTitle = note.title
        self.noteBody = note.body.trimmingCharacters(in: .whitespaces)
        self.noteDate = DateFormatterUtil.shared.dateFormatter.string(from: note.date)
    }
}

final class HomeViewModel {
    
    public enum Event {
        case dataUpdated
        case openCreateScreen(note: Note?)
        case openOptionsScreen
    }
    
    public enum Action {
        case remove(id: UUID)
        case pin(id: UUID)
        case unpin(id: UUID)
        case updateSortDescription
        case selectNote(note: Note)
        case createNew
        case search(word: String)
        case reloadData
    }
    
    @UserDefault(key: "sorting-type", defaultValue: false)
    var isSortOldest: Bool
    
    let repository: NotesRepository
    var subscriptions = Set<AnyCancellable>()
    var pinNotesCellModel: [NoteCellModel]
    var unpinNoteCellModel: [NoteCellModel]
    var searchCellModel: [NoteCellModel] = []
    
    var isFiltering: Bool = false
    
    public let events = PassthroughSubject<Event, Never>()
    public let actions = PassthroughSubject<Action, Never>()
    
    var totalNotes: Int {
        return repository.notes.count
    }
    
    
    var totalSection: Int {
        if isFiltering {
            return 1
        } else {
            return pinNotesCellModel.isEmpty ? 1 : 2
        }
    }
    
    init(repository: NotesRepository) {
        self.repository = repository
        let sortType = UserDefaults.standard.bool(forKey: "sorting-type")
        pinNotesCellModel = repository.pinnedNotes.sorted(by: { note1, note2 in
            return sortType ? note1 < note2 : note1 > note2
        }).map { NoteCellModel($0) }
        unpinNoteCellModel = repository.notPinnedNotes.sorted(by: { note1, note2 in
            return sortType ? note1 < note2 : note1 > note2
        }).map { NoteCellModel($0) }
        
        actions
            .sink { [unowned self] action in
                self.handleAction(action)
            }
            .store(in: &subscriptions)
    }
    
    func syncData() {
        pinNotesCellModel = repository.pinnedNotes.sorted(by: { note1, note2 in
            return self.isSortOldest ? note1 < note2 : note1 > note2
        }).map { NoteCellModel($0) }
        unpinNoteCellModel = repository.notPinnedNotes.sorted(by: { note1, note2 in
            return self.isSortOldest ? note1 < note2 : note1 > note2
        }).map { NoteCellModel($0) }
        events.send(.dataUpdated)
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .remove(id: let id):
            repository.deleteNote(id: id)
            syncData()
        case .pin(id: let id):
            repository.pinNote(id: id)
            syncData()
        case .unpin(id: let id):
            repository.unpinNote(id: id)
            syncData()
        case .selectNote(note: let note):
            events.send(.openCreateScreen(note: note))
        case .createNew:
            events.send(.openCreateScreen(note: nil))
        case .updateSortDescription:
            events.send(.openOptionsScreen)
        case .search(word: let word):
            searchCellModel.removeAll()
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                if word.isEmpty {
                    self.isFiltering = false
                } else {
                    self.isFiltering = true
                    let filtered = self.repository.notes.filter { note in
                        return note.title.lowercased().contains(word.lowercased()) || note.body.lowercased().contains(word.lowercased())
                    }
                    searchCellModel.append(contentsOf: filtered.map { NoteCellModel($0) })
                }
                self.events.send(.dataUpdated)
            }
        case .reloadData:
            syncData()
        }
    }
    
    func getDataSourceForSection(_ section: Int) -> [NoteCellModel] {
        if isFiltering {
            return searchCellModel
        } else {
            if totalSection == 2 {
                if section == 0 {
                    return pinNotesCellModel
                } else {
                    return unpinNoteCellModel
                }
            } else {
                return unpinNoteCellModel
            }
        }
    }
}
