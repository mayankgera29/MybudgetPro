//
//  DateFormatter+Ext.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//

import Foundation

extension DateFormatter {

    static let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }()
}
