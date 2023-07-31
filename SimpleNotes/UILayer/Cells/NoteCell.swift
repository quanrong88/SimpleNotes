//
//  NoteCell.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet private weak var noteTitleLabel: UILabel!
    @IBOutlet private weak var noteBodyLabel: UILabel!
    @IBOutlet private weak var noteDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellModel(_ viewModel: NoteCellModel) {
        noteTitleLabel.text = viewModel.noteTitle
        noteBodyLabel.text = viewModel.noteBody
        noteDateLabel.text = viewModel.noteDate
    }
    
}
