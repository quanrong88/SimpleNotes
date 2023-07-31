//
//  CreateNoteVC.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 30/07/2023.
//

import UIKit

class CreateNoteVC: UIViewController {
    
    @IBOutlet private weak var bodyTextView: UITextView!
    @IBOutlet private weak var noteTitleLabel: UITextField!
    
    let viewModel: CreateNoteViewModel
    
    init(viewModel: CreateNoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CreateNoteVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupNoteIfEditing()
        setupKeyboardNotifications()
        noteTitleLabel.delegate = self
        bodyTextView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noteTitleLabel.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.events.send(.back)
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let moreButtonImage = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        doneButton.tintColor = UIColor.systemYellow

        let rightBarItems = [doneButton]
        navigationItem.rightBarButtonItems = rightBarItems
        navigationItem.backBarButtonItem?.tintColor = UIColor.systemYellow
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
    }

    @objc
    private func doneButtonAction() {
        guard var title = noteTitleLabel.text?.trimmingCharacters(in: .whitespaces) else { return }
        guard var body = bodyTextView.text?.trimmingCharacters(in: .whitespaces) else { return }

        if title == "" {
          title = "Unnamed note"
        }

        if body == "" {
          body = "No content"
        }
        
        viewModel.actions.send(.save(title: title, body: body))
      
    }
    
    private func setupNoteIfEditing() {
        if case .editing(let note, let title, let body) = viewModel.savedAppState {
            noteTitleLabel.text = title
            bodyTextView.text = body
        } else if let note = viewModel.note {
            noteTitleLabel.text = note.title
            bodyTextView.text = note.body
        }
    }
    
    
    private func setupKeyboardNotifications() {
      let notificationCenter = NotificationCenter.default
      notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
      notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc
    func adjustKeyboard(notification: Notification) {
        guard let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenFrame: CGRect = keyboardValue.cgRectValue
        
        let keyboardConvertedFrame = view.convert(keyboardScreenFrame, to: view.window)
        
        let textViewBottomInset = keyboardConvertedFrame.height
        bodyTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: textViewBottomInset, right: 0)
        bodyTextView.scrollIndicatorInsets = bodyTextView.contentInset
        let selectedRange = bodyTextView.selectedRange
        bodyTextView.scrollRangeToVisible(selectedRange)
    }
    
}

extension CreateNoteVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      jumpToNextTextField(textField)
      return true
    }

    func jumpToNextTextField(_ textField: UITextField) {
      switch textField {
        case noteTitleLabel:
          bodyTextView.becomeFirstResponder()
        default:
          return
      }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.actions.send(.updateState(note: viewModel.note, title: textField.text ?? "", body: bodyTextView.text ?? ""))
        return true
    }
}

extension CreateNoteVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.actions.send(.updateState(note: viewModel.note, title: noteTitleLabel.text ?? "", body: textView.text ?? ""))
    }
}
