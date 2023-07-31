//
//  HomeVC.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import UIKit
import Combine

class HomeVC: UIViewController {
    
    @IBOutlet weak var homeSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newNoteItem: UIBarButtonItem!
    @IBOutlet weak var notesAmountItem: UIBarButtonItem!
    
    let viewModel: HomeViewModel
    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        setupGestures()
        homeSearchBar.delegate = self
        updateUI()
        setupNavigationBar()
        bindingViewModel()
    }
    
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let moreButtonImage = UIImage(systemName: "ellipsis.circle")?.withRenderingMode(.alwaysTemplate)

        let moreButton = UIBarButtonItem(image: moreButtonImage, style: .plain, target: self, action: #selector(showMoreOptions))
        moreButton.tintColor = UIColor.systemYellow
        let rightBarItems: [UIBarButtonItem] = [moreButton]
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    func bindingViewModel() {
        viewModel.events
            .sink { event in
                switch event {
                case .dataUpdated:
                    self.updateUI()
                default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc
    private func showMoreOptions() {
        viewModel.actions.send(.updateSortDescription)
    }
    
    
    @IBAction func createNoteButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.actions.send(.createNew)
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.notesAmountItem.title = "\(self.viewModel.totalNotes) Notes"
        }
    }
    
    func setupGestures() {
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchBarDismissKeyboardTouchOutside))
      gestureRecognizer.cancelsTouchesInView = false
      view.addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func searchBarDismissKeyboardTouchOutside() {
      homeSearchBar.endEditing(true)
    }
}

extension HomeVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.totalSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getDataSourceForSection(section).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      guard tableView.numberOfSections == 2 else {
        return ""
      }
      return section == 0 ? "Pinned" : "Notes"
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
          fatalError("Error dequeing")
        }
        
        let cellModel = viewModel.getDataSourceForSection(indexPath.section)[indexPath.row]
        cell.updateCellModel(cellModel)
        
        return cell
    }
}

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteActionCompletion: (UIContextualAction, UIView, @escaping (Bool) -> Void) -> Void = { [unowned self] _, _, completion in
            defer {
              completion(true)
            }
            let cellModel = viewModel.getDataSourceForSection(indexPath.section)[indexPath.row]
            viewModel.actions.send(.remove(id: cellModel.note.id))
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: deleteActionCompletion)
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.image?.withTintColor(UIColor.yellow)
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinActionCompletion: (UIContextualAction, UIView, @escaping (Bool) -> Void) -> Void = { [unowned self] _, _, completion in
            defer {
              completion(true)
            }
            let cellModel = viewModel.getDataSourceForSection(indexPath.section)[indexPath.row]
            if tableView.numberOfSections == 2, indexPath.section == 0 {
                self.viewModel.actions.send(.unpin(id: cellModel.note.id))
            } else {
                self.viewModel.actions.send(.pin(id: cellModel.note.id))
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil, handler: pinActionCompletion)
        let pinImageName = tableView.numberOfSections > 1 && indexPath.section == 0 ? "pin.slash.fill" : "pin.fill"
        pinAction.image = UIImage(systemName: pinImageName)
        pinAction.backgroundColor = UIColor.systemOrange.withAlphaComponent(1)
        let actions = [pinAction]

        let swipeConfig = UISwipeActionsConfiguration(actions: viewModel.isFiltering ? [] : actions)
        swipeConfig.performsFirstActionWithFullSwipe = true
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = viewModel.getDataSourceForSection(indexPath.section)[indexPath.row]
        viewModel.actions.send(.selectNote(note: cellModel.note))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 80
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      homeSearchBar.resignFirstResponder()
    }
}

extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.actions.send(.search(word: searchText))
    }
}
