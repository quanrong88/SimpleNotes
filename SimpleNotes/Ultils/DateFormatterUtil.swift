//
//  DateFormatterUtil.swift
//  SimpleNotes
//
//  Created by Tạ Minh Quân on 29/07/2023.
//

import Foundation

final class DateFormatterUtil {
    static let shared = DateFormatterUtil()
    
    lazy var dateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
      return dateFormatter
    }()
}
