//
//  AppCoordinator.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 30/07/2023.
//

import Foundation
import UIKit
import Combine
import Sheeeeeeeeet

enum AppState: Codable {
    case home
    case editing(note: Note?, title: String, body: String)
}

final class AppCoordinator {
    public var window: UIWindow
    let navigationController: UINavigationController
    let repository: NotesRepository
    
    var subscriptions = Set<AnyCancellable>()
    
    var homeVC: HomeVC
    var createNoteVC: CreateNoteVC?
    var appState: AppState
    
    public init(window: UIWindow) {
        self.window = window
        self.repository = NotesRepository()
        self.appState = UserDefaults.standard.load(key: "app-state", obj: AppState.self) ?? .home

        let homeVM = HomeViewModel(repository: repository)
        homeVC = HomeVC(viewModel: homeVM)
        
        self.navigationController = UINavigationController(rootViewController: homeVC)
        
        homeVM.events
            .sink { event in
                switch event {
                case .openCreateScreen(note: let note):
                    self.openCreateNoteView(note)
                    self.appState = .editing(note: note, title: note?.title ?? "", body: note?.body ?? "")
                case .openOptionsScreen:
                    self.openOptionSelectView()
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        if case .editing(let note, _, _) = appState {
            openCreateNoteView(note)
            UserDefaults.standard.removeObject(forKey: "app-state")
        }
    }
    
    public func start() {
        window.rootViewController = navigationController
    }
    
    public func finish() {
        UserDefaults.standard.save(key: "app-state", obj: appState)
    }
    
    private func openCreateNoteView(_ note: Note?) {
        var animated = true
        let createNoteVM = CreateNoteViewModel(repository: repository, note: note)
        if case .editing(_, _, _) = appState {
            createNoteVM.savedAppState = appState
            animated = false
        }
        createNoteVC = CreateNoteVC(viewModel: createNoteVM)
        self.navigationController.pushViewController(createNoteVC!, animated: animated)
        
        createNoteVM.events
            .sink { event in
                switch event {
                case .done:
                    self.navigationController.popViewController(animated: true)
                    self.homeVC.viewModel.actions.send(.reloadData)
                case .stateChange(note: let note, title: let title, body: let body):
                    self.appState = .editing(note: note, title: title, body: body)
                case .back:
                    self.createNoteVC = nil
                    self.appState = .home
                    print("reset")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func openOptionSelectView() {
        let currentValue = homeVC.viewModel.isSortOldest
        
        let item1 = SingleSelectItem(title: "Newest to oldest (Default)", isSelected: !currentValue, value: 0)
        let item2 = SingleSelectItem(title: "Oldest to newest", isSelected: currentValue, value: 1)
        let button = CancelButton(title: "Cancel")
        
        let items = [item1, item2, button]
        let menu = Menu(title: "Sort notes by (Date created)", items: items)
        
        let sheet = menu.toActionSheet { _, item in
            if let value = item.value as? Int {
                switch value {
                case 0:
                    self.homeVC.viewModel.isSortOldest = false
                case 1:
                    self.homeVC.viewModel.isSortOldest = true
                default:
                    break
                }
                self.homeVC.viewModel.actions.send(.reloadData)
            }
            
        }
        sheet.present(in: navigationController, from: nil)
    }
    
}
