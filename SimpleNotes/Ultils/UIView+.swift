//
//  UIView+.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var insp_radius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.rounded(cornerRadius: newValue)
        }
    }
    
    func rounded(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
